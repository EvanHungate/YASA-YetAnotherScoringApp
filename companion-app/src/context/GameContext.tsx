import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { GameState } from '../types/GameState';
import {
  createInitialGameState,
  startGame,
  score,
  undo,
  resetGame,
  continueFromHalftime,
  currentLineDisplay,
  currentRatioLabel,
  loadSavedState,
  hasSavedGame,
} from '../logic/gameLogic';

interface GameContextType {
  state: GameState;
  startGame: () => void;
  score: (team: 'a' | 'b') => void;
  undo: () => void;
  resetGame: () => void;
  continueFromHalftime: () => void;
  currentLineDisplay: () => string;
  currentRatioLabel: () => string;
  updateState: (updates: Partial<GameState>) => void;
  checkForSavedGame: () => Promise<boolean>;
  loadSaved: () => Promise<void>;
}

const GameContext = createContext<GameContextType | undefined>(undefined);

export const GameProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [state, setState] = useState<GameState>(createInitialGameState());

  const checkForSavedGame = async (): Promise<boolean> => {
    return await hasSavedGame();
  };

  const loadSaved = async (): Promise<void> => {
    const savedState = await loadSavedState();
    if (savedState) {
      setState(savedState);
    }
  };

  const contextValue: GameContextType = {
    state,
    startGame: () => setState(startGame(state)),
    score: (team: 'a' | 'b') => setState(score(state, team)),
    undo: () => setState(undo(state)),
    resetGame: () => setState(resetGame(state)),
    continueFromHalftime: () => setState(continueFromHalftime(state)),
    currentLineDisplay: () => currentLineDisplay(state),
    currentRatioLabel: () => currentRatioLabel(state),
    updateState: (updates) => setState({ ...state, ...updates }),
    checkForSavedGame,
    loadSaved,
  };

  return <GameContext.Provider value={contextValue}>{children}</GameContext.Provider>;
};

export const useGame = (): GameContextType => {
  const context = useContext(GameContext);
  if (!context) {
    throw new Error('useGame must be used within a GameProvider');
  }
  return context;
};
