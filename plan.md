# Ultimate Frisbee Scorekeeper - Game Logic Documentation

 

## Overview

This document describes the complete game logic for an Ultimate Frisbee scorekeeper app designed for Apple Watch.

 

## Core Concepts

 

### Teams

- Two teams: Team A and Team B

- Each team has:

  - Name (customizable)

  - Score (points)

  - Break count (points scored while pulling)

  - Pulling/Receiving status

 

### Game Setup

User configures:

- **Team Names**: Custom names for each team

- **First Pull**: Which team pulls first

- **Start Ratio**: Which gender ratio starts (Open or FMP)

- **Line Counts**: Number of players in Open line and FMP line (default 7 each)

- **Target Points**: Game ends when a team reaches this score (default 15)

 

## Pulling and Receiving

 

### Basic Rules

- The team that **pulls** is on defense

- The team that **receives** is on offense

- After each point, the team that **scored** pulls next

- At halftime, the team that pulled first switches to receiving

 

### Break Tracking

A **break** occurs when the pulling team (defense) scores.

- Track breaks separately for each team

- Increment break count when `scoringTeam === pullingTeam`

 

## Gender Ratio Rotation

 

### Rotation Cycle

The rotation follows a 4-point cycle based on the starting ratio:

 

**If starting with Open (O):**

```

Point 1: O2 (4 Open, 3 FMP)

Point 2: F1 (3 Open, 4 FMP)

Point 3: F2 (3 Open, 4 FMP)

Point 4: O1 (4 Open, 3 FMP)

[Cycle repeats]

```

 

**If starting with FMP (F):**

```

Point 1: F2 (3 Open, 4 FMP)

Point 2: O1 (4 Open, 3 FMP)

Point 3: O2 (4 Open, 3 FMP)

Point 4: F1 (3 Open, 4 FMP)

[Cycle repeats]

```

 

### Building the Rotation

```javascript

function buildRotation(startRatio) {

  const A = startRatio;  // First ratio

  const B = startRatio === 'O' ? 'F' : 'O';  // Opposite ratio

  return [`${A}2`, `${B}1`, `${B}2`, `${A}1`];

}

```

 

### Ratio Label Meanings

- **O1**: Open first time (4 Open, 3 FMP)

- **O2**: Open second time (4 Open, 3 FMP)

- **F1**: FMP first time (3 Open, 4 FMP)

- **F2**: FMP second time (3 Open, 4 FMP)

 

### Player Needs per Ratio

```javascript

function ratioNeeds(label) {

  const isO = label && label.startsWith('O');

  return {

    o: isO ? 4 : 3,  // Open players needed

    f: isO ? 3 : 4   // FMP players needed

  };

}

```

 

## Line Rolling

 

### Concept

Line rolling ensures all players get equal playing time by rotating through the roster in order.

 

### State Variables

- `openCount`: Total number of Open players (e.g., 7)

- `fmpCount`: Total number of FMP players (e.g., 7)

- `openCursor`: Current position in Open roster (0 to openCount-1)

- `fmpCursor`: Current position in FMP roster (0 to fmpCount-1)

 

### Determining Current Line

For the current ratio, calculate which players are on the field:

 

```javascript

function updateLineDisplay() {

  const label = rotationCycle[rotationIndex];  // e.g., "O2"

  const needs = ratioNeeds(label);  // e.g., {o: 4, f: 3}

 

  // Get Open players starting from cursor

  const openLine = [];

  for (let i = 0; i < Math.min(needs.o, openCount); i++) {

    openLine.push(((openCursor + i) % openCount) + 1);

  }

 

  // Get FMP players starting from cursor

  const fmpLine = [];

  for (let i = 0; i < Math.min(needs.f, fmpCount); i++) {

    fmpLine.push(((fmpCursor + i) % fmpCount) + 1);

  }

 

  // Display: "O: 1,2,3,4 | F: 5,6,7"

  return `O: ${openLine.join(',')} | F: ${fmpLine.join(',')}`;

}

```

 

### Advancing Lines After Each Point

After a point is scored, advance the cursors:

 

```javascript

function advanceLines() {

  const label = rotationCycle[rotationIndex];

  const needs = ratioNeeds(label);

 

  // Move cursors forward by the number of players used

  openCursor = (openCursor + needs.o) % openCount;

  fmpCursor = (fmpCursor + needs.f) % fmpCount;

}

```

 

**Example:**

- Line has 7 Open and 7 FMP players

- Point 1 (O2): Uses players O: 1,2,3,4 and F: 1,2,3

- After point, cursors advance: openCursor = 4, fmpCursor = 3

- Point 2 (F1): Uses players O: 5,6,7 and F: 4,5,6,7

- After point: openCursor = 7 (wraps to 0), fmpCursor = 7 (wraps to 0)

 

## Scoring Flow

 

### When a Team Scores

 

1. **Save History** (for undo functionality)

   - Save current state: scores, breaks, pullingTeam, rotationIndex, cursors

 

2. **Update Score**

   - Increment scoring team's score

   - Increment total point counter

 

3. **Check for Break**

   - If `scoringTeam === pullingTeam`, increment break count

 

4. **Update Pulling Team**

   - Scoring team pulls next: `pullingTeam = scoringTeam`

 

5. **Advance Rotation**

   - Move to next ratio: `rotationIndex = (rotationIndex + 1) % 4`

   - Advance line cursors based on players used

 

6. **Check Halftime**

   - If either team reaches 8 points and halftime not yet reached:

     - Set `halftimeReached = true`

     - Show halftime modal

     - When user continues, switch pulling team to opposite of initial puller

 

7. **Check for Win**

   - If scoring team's score >= target points:

     - Show winner modal

     - End game

 

## Undo Functionality

 

### History Tracking

Before each score, save complete game state:

 

```javascript

history.push({

  scoreA: score.a,

  scoreB: score.b,

  breaksA: breaks.a,

  breaksB: breaks.b,

  pullingTeam,

  halftimeReached,

  rotationIndex,

  totalPoints,

  openCursor,

  fmpCursor

});

```

 

### Undo Operation

Pop the last state from history and restore all values:

 

```javascript

function undo() {

  const last = history.pop();

  if (!last) return;

 

  score.a = last.scoreA;

  score.b = last.scoreB;

  breaks.a = last.breaksA;

  breaks.b = last.breaksB;

  pullingTeam = last.pullingTeam;

  halftimeReached = last.halftimeReached;

  rotationIndex = last.rotationIndex;

  totalPoints = last.totalPoints;

  openCursor = last.openCursor;

  fmpCursor = last.fmpCursor;

}

```

 

## Halftime Logic

 

### When Halftime is Reached

- Triggered when either team reaches 8 points

- Only happens once per game

- Display modal: "Halftime - 8 points reached"

 

### When User Continues from Halftime

- Switch pulling team: `pullingTeam = otherTeam(initialPuller)`

- This ensures the team that received first now pulls

 

## Game Reset

 

Reset all state to initial values:

```javascript

score.a = 0;

score.b = 0;

breaks.a = 0;

breaks.b = 0;

pullingTeam = initialPuller;

halftimeReached = false;

rotationIndex = 0;

totalPoints = 0;

openCursor = 0;

fmpCursor = 0;

history = [];

```

 

## Display Updates

 

### Main Game Screen Shows:

- **Ratio Display**: Current ratio label (e.g., "O2")

- **Line Display**: Current players (e.g., "O: 1,2,3,4 | F: 5,6,7")

- **Scores**: Both team scores

- **Team Names**: Customized names

- **Status**: Which team is pulling/receiving

- **Score Buttons**: +1 for each team

 

### Menu/Stats Display:

- Current point number

- Target points

- Each team's break count

 

## Edge Cases

 

### No Halftime Scenario

If target is less than 8 (e.g., game to 7), halftime never triggers.

 

### Wraparound in Line Rolling

When cursor reaches end of roster, wrap to 0 using modulo:

- `(cursor + count) % totalPlayers`

 

### Undo After Halftime

Undo properly restores `halftimeReached` flag, allowing halftime to trigger again if the same point is replayed.

 

## Summary of State Variables

 

```javascript

// Scores

score = { a: 0, b: 0 }

breaks = { a: 0, b: 0 }

 

// Pulling

pullingTeam = 'a' or 'b'

initialPuller = 'a' or 'b'

 

// Rotation

rotationCycle = ['O2', 'F1', 'F2', 'O1']  // or starts with F

rotationIndex = 0 to 3

rotationStart = 'O' or 'F'

 

// Line Rolling

openCount = 7

fmpCount = 7

openCursor = 0 to (openCount - 1)

fmpCursor = 0 to (fmpCount - 1)

 

// Game State

targetPoints = 15

totalPoints = 0

halftimeReached = false

gameStarted = false

history = []  // Array of game state snapshots

```

 

## Implementation Checklist

 

- [ ] Setup screen with all configuration options

- [ ] Start button initializes game state

- [ ] Score buttons trigger scoring flow

- [ ] Display updates after each action

- [ ] Ratio rotation follows 4-point cycle

- [ ] Line rolling advances cursors correctly

- [ ] Halftime modal at 8 points

- [ ] Winner modal when target reached

- [ ] Undo button restores previous state

- [ ] Reset button returns to setup screen

- [ ] Break tracking counts defensive scores

- [ ] Pulling/receiving status updates correctly