import React, { useEffect, useState } from 'react';
import { StyleSheet, View, Alert } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { GameProvider, useGame } from './src/context/GameContext';
import SetupScreen from './src/screens/SetupScreen';
import GameScreen from './src/screens/GameScreen';
import ControlsScreen from './src/screens/ControlsScreen';

function AppContent() {
  const { state, checkForSavedGame, loadSaved } = useGame();
  const [showControls, setShowControls] = useState(false);

  useEffect(() => {
    // Check for saved game on launch
    const init = async () => {
      const hasSaved = await checkForSavedGame();
      if (hasSaved && !state.gameStarted) {
        Alert.alert(
          'Resume Game?',
          'You have a game in progress. Would you like to resume it?',
          [
            { text: 'Resume', onPress: () => loadSaved() },
            { text: 'New Game', style: 'cancel' },
          ]
        );
      }
    };
    init();
  }, []);

  if (!state.gameStarted) {
    return <SetupScreen />;
  }

  if (showControls) {
    return <ControlsScreen onBack={() => setShowControls(false)} />;
  }

  return (
    <GameScreen
      onShowControls={() => setShowControls(true)}
    />
  );
}

export default function App() {
  return (
    <GameProvider>
      <View style={styles.container}>
        <StatusBar style="light" />
        <AppContent />
      </View>
    </GameProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
});
