// Game state types for Ultimate Frisbee scorekeeper

export interface GameStateSnapshot {
  scoreA: number;
  scoreB: number;
  breaksA: number;
  breaksB: number;
  pullingTeam: 'a' | 'b';
  halftimeReached: boolean;
  rotationIndex: number;
  totalPoints: number;
  openCursor: number;
  fmpCursor: number;
}

export interface RatioNeeds {
  o: number; // Open players needed
  f: number; // FMP players needed
}

export interface SavedGameState {
  teamAName: string;
  teamBName: string;
  scoreA: number;
  scoreB: number;
  breaksA: number;
  breaksB: number;
  pullingTeam: 'a' | 'b';
  initialPuller: 'a' | 'b';
  rotationCycle: string[];
  rotationIndex: number;
  rotationStart: 'O' | 'F';
  useLineRolling: boolean;
  openCount: number;
  fmpCount: number;
  openCursor: number;
  fmpCursor: number;
  targetPoints: number;
  totalPoints: number;
  halftimeReached: boolean;
  timestamp: string; // ISO date string
}

export interface GameState {
  // Team configuration
  teamAName: string;
  teamBName: string;

  // Scores and breaks
  scoreA: number;
  scoreB: number;
  breaksA: number;
  breaksB: number;

  // Pulling
  pullingTeam: 'a' | 'b';
  initialPuller: 'a' | 'b';

  // Rotation
  rotationCycle: string[];
  rotationIndex: number;
  rotationStart: 'O' | 'F';

  // Line rolling
  useLineRolling: boolean;
  openCount: number;
  fmpCount: number;
  openCursor: number;
  fmpCursor: number;

  // Game state
  targetPoints: number;
  totalPoints: number;
  halftimeReached: boolean;
  gameStarted: boolean;
  showHalftimeModal: boolean;
  showWinnerModal: boolean;
  winningTeam: 'a' | 'b' | '';

  // History for undo
  history: GameStateSnapshot[];
}
