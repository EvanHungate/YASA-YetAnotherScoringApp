import { GameState, RatioNeeds, GameStateSnapshot, SavedGameState } from '../types/GameState';
import AsyncStorage from '@react-native-async-storage/async-storage';

const SAVED_GAME_KEY = 'savedGameState';

// Create initial game state
export const createInitialGameState = (): GameState => ({
  teamAName: 'Team',
  teamBName: 'Opposition',
  scoreA: 0,
  scoreB: 0,
  breaksA: 0,
  breaksB: 0,
  pullingTeam: 'a',
  initialPuller: 'a',
  rotationCycle: [],
  rotationIndex: 0,
  rotationStart: 'O',
  useLineRolling: false,
  openCount: 7,
  fmpCount: 7,
  openCursor: 0,
  fmpCursor: 0,
  targetPoints: 15,
  totalPoints: 0,
  halftimeReached: false,
  gameStarted: false,
  showHalftimeModal: false,
  showWinnerModal: false,
  winningTeam: '',
  history: [],
});

// Build rotation cycle based on starting ratio
export const buildRotation = (startRatio: 'O' | 'F'): string[] => {
  const A = startRatio;
  const B = startRatio === 'O' ? 'F' : 'O';
  return [`${A}2`, `${B}1`, `${B}2`, `${A}1`];
};

// Get player needs for a given ratio label
export const ratioNeeds = (label: string): RatioNeeds => {
  const isO = label.startsWith('O');
  return {
    o: isO ? 4 : 3,
    f: isO ? 3 : 4,
  };
};

// Start a new game
export const startGame = (state: GameState): GameState => {
  const newState: GameState = {
    ...state,
    rotationCycle: buildRotation(state.rotationStart),
    scoreA: 0,
    scoreB: 0,
    breaksA: 0,
    breaksB: 0,
    pullingTeam: state.initialPuller,
    halftimeReached: false,
    rotationIndex: 0,
    totalPoints: 0,
    openCursor: 0,
    fmpCursor: 0,
    history: [],
    showHalftimeModal: false,
    showWinnerModal: false,
    winningTeam: '',
    gameStarted: true,
  };

  // Save initial state
  saveState(newState);
  return newState;
};

// Handle scoring
export const score = (state: GameState, team: 'a' | 'b'): GameState => {
  // 1. Save history
  const snapshot: GameStateSnapshot = {
    scoreA: state.scoreA,
    scoreB: state.scoreB,
    breaksA: state.breaksA,
    breaksB: state.breaksB,
    pullingTeam: state.pullingTeam,
    halftimeReached: state.halftimeReached,
    rotationIndex: state.rotationIndex,
    totalPoints: state.totalPoints,
    openCursor: state.openCursor,
    fmpCursor: state.fmpCursor,
  };

  let newState = { ...state, history: [...state.history, snapshot] };

  // 2. Update score
  if (team === 'a') {
    newState.scoreA += 1;
  } else {
    newState.scoreB += 1;
  }
  newState.totalPoints += 1;

  // 3. Check for break
  if (team === newState.pullingTeam) {
    if (team === 'a') {
      newState.breaksA += 1;
    } else {
      newState.breaksB += 1;
    }
  }

  // 4. Advance rotation and lines
  newState = advanceLines(newState);
  newState.rotationIndex = (newState.rotationIndex + 1) % 4;

  // 5. Update pulling team
  newState.pullingTeam = team;

  // 6. Check halftime
  if (!newState.halftimeReached && (newState.scoreA === 8 || newState.scoreB === 8)) {
    newState.halftimeReached = true;
    newState.showHalftimeModal = true;
    return newState;
  }

  // 7. Check for win
  const currentScore = team === 'a' ? newState.scoreA : newState.scoreB;
  if (currentScore >= newState.targetPoints) {
    newState.winningTeam = team;
    newState.showWinnerModal = true;
    clearSavedState();
  } else {
    saveState(newState);
  }

  return newState;
};

// Continue from halftime
export const continueFromHalftime = (state: GameState): GameState => {
  let newState = {
    ...state,
    showHalftimeModal: false,
    pullingTeam: state.initialPuller === 'a' ? ('b' as const) : ('a' as const),
  };

  // Check for win after halftime
  if (newState.scoreA >= newState.targetPoints) {
    newState.winningTeam = 'a';
    newState.showWinnerModal = true;
    clearSavedState();
  } else if (newState.scoreB >= newState.targetPoints) {
    newState.winningTeam = 'b';
    newState.showWinnerModal = true;
    clearSavedState();
  } else {
    saveState(newState);
  }

  return newState;
};

// Advance line cursors
export const advanceLines = (state: GameState): GameState => {
  if (!state.useLineRolling || state.rotationIndex >= state.rotationCycle.length) {
    return state;
  }

  const label = state.rotationCycle[state.rotationIndex];
  const needs = ratioNeeds(label);

  return {
    ...state,
    openCursor: (state.openCursor + needs.o) % state.openCount,
    fmpCursor: (state.fmpCursor + needs.f) % state.fmpCount,
  };
};

// Get current line display
export const currentLineDisplay = (state: GameState): string => {
  if (!state.useLineRolling || !state.gameStarted || state.rotationIndex >= state.rotationCycle.length) {
    return '';
  }

  const label = state.rotationCycle[state.rotationIndex];
  const needs = ratioNeeds(label);

  // Get Open players
  const openLine: number[] = [];
  for (let i = 0; i < Math.min(needs.o, state.openCount); i++) {
    openLine.push(((state.openCursor + i) % state.openCount) + 1);
  }

  // Get FMP players
  const fmpLine: number[] = [];
  for (let i = 0; i < Math.min(needs.f, state.fmpCount); i++) {
    fmpLine.push(((state.fmpCursor + i) % state.fmpCount) + 1);
  }

  return `O: ${openLine.join(',')} | F: ${fmpLine.join(',')}`;
};

// Get current ratio label
export const currentRatioLabel = (state: GameState): string => {
  if (!state.gameStarted || state.rotationIndex >= state.rotationCycle.length) {
    return '';
  }
  return state.rotationCycle[state.rotationIndex];
};

// Undo last action
export const undo = (state: GameState): GameState => {
  if (state.history.length === 0) {
    return state;
  }

  const last = state.history[state.history.length - 1];
  const newHistory = state.history.slice(0, -1);

  return {
    ...state,
    scoreA: last.scoreA,
    scoreB: last.scoreB,
    breaksA: last.breaksA,
    breaksB: last.breaksB,
    pullingTeam: last.pullingTeam,
    halftimeReached: last.halftimeReached,
    rotationIndex: last.rotationIndex,
    totalPoints: last.totalPoints,
    openCursor: last.openCursor,
    fmpCursor: last.fmpCursor,
    history: newHistory,
    showHalftimeModal: false,
    showWinnerModal: false,
    winningTeam: '',
  };
};

// Reset game
export const resetGame = (state: GameState): GameState => {
  clearSavedState();
  return {
    ...state,
    gameStarted: false,
    scoreA: 0,
    scoreB: 0,
    breaksA: 0,
    breaksB: 0,
    pullingTeam: state.initialPuller,
    halftimeReached: false,
    rotationIndex: 0,
    totalPoints: 0,
    openCursor: 0,
    fmpCursor: 0,
    history: [],
    showHalftimeModal: false,
    showWinnerModal: false,
    winningTeam: '',
  };
};

// Persistence functions
export const saveState = async (state: GameState): Promise<void> => {
  if (!state.gameStarted) return;

  const savedState: SavedGameState = {
    teamAName: state.teamAName,
    teamBName: state.teamBName,
    scoreA: state.scoreA,
    scoreB: state.scoreB,
    breaksA: state.breaksA,
    breaksB: state.breaksB,
    pullingTeam: state.pullingTeam,
    initialPuller: state.initialPuller,
    rotationCycle: state.rotationCycle,
    rotationIndex: state.rotationIndex,
    rotationStart: state.rotationStart,
    useLineRolling: state.useLineRolling,
    openCount: state.openCount,
    fmpCount: state.fmpCount,
    openCursor: state.openCursor,
    fmpCursor: state.fmpCursor,
    targetPoints: state.targetPoints,
    totalPoints: state.totalPoints,
    halftimeReached: state.halftimeReached,
    timestamp: new Date().toISOString(),
  };

  try {
    await AsyncStorage.setItem(SAVED_GAME_KEY, JSON.stringify(savedState));
  } catch (error) {
    console.error('Error saving game state:', error);
  }
};

export const loadSavedState = async (): Promise<GameState | null> => {
  try {
    const data = await AsyncStorage.getItem(SAVED_GAME_KEY);
    if (!data) return null;

    const savedState: SavedGameState = JSON.parse(data);

    // Check if stale (older than 24 hours)
    const hoursSinceLastSave =
      (Date.now() - new Date(savedState.timestamp).getTime()) / (1000 * 60 * 60);
    if (hoursSinceLastSave > 24) {
      await clearSavedState();
      return null;
    }

    // Restore state
    return {
      teamAName: savedState.teamAName,
      teamBName: savedState.teamBName,
      scoreA: savedState.scoreA,
      scoreB: savedState.scoreB,
      breaksA: savedState.breaksA,
      breaksB: savedState.breaksB,
      pullingTeam: savedState.pullingTeam,
      initialPuller: savedState.initialPuller,
      rotationCycle: savedState.rotationCycle,
      rotationIndex: savedState.rotationIndex,
      rotationStart: savedState.rotationStart,
      useLineRolling: savedState.useLineRolling,
      openCount: savedState.openCount,
      fmpCount: savedState.fmpCount,
      openCursor: savedState.openCursor,
      fmpCursor: savedState.fmpCursor,
      targetPoints: savedState.targetPoints,
      totalPoints: savedState.totalPoints,
      halftimeReached: savedState.halftimeReached,
      gameStarted: true,
      showHalftimeModal: false,
      showWinnerModal: false,
      winningTeam: '',
      history: [],
    };
  } catch (error) {
    console.error('Error loading game state:', error);
    return null;
  }
};

export const hasSavedGame = async (): Promise<boolean> => {
  try {
    const data = await AsyncStorage.getItem(SAVED_GAME_KEY);
    if (!data) return false;

    const savedState: SavedGameState = JSON.parse(data);
    const hoursSinceLastSave =
      (Date.now() - new Date(savedState.timestamp).getTime()) / (1000 * 60 * 60);
    return hoursSinceLastSave <= 24;
  } catch (error) {
    return false;
  }
};

export const clearSavedState = async (): Promise<void> => {
  try {
    await AsyncStorage.removeItem(SAVED_GAME_KEY);
  } catch (error) {
    console.error('Error clearing saved state:', error);
  }
};
