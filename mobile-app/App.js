import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

import HomeScreen from './src/screens/HomeScreen';
import AlumnosScreen from './src/screens/AlumnosScreen';
import ProfesoresScreen from './src/screens/ProfesoresScreen';
import MateriasScreen from './src/screens/MateriasScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home">
        <Stack.Screen
          name="Home"
          component={HomeScreen}
          options={{ title: 'Proyecto Escolar' }}
        />
        <Stack.Screen
          name="Alumnos"
          component={AlumnosScreen}
          options={{ headerStyle: { backgroundColor: '#007AFF' }, headerTintColor: 'white' }}
        />
        <Stack.Screen
          name="Profesores"
          component={ProfesoresScreen}
          options={{ headerStyle: { backgroundColor: '#34C759' }, headerTintColor: 'white' }}
        />
        <Stack.Screen
          name="Materias"
          component={MateriasScreen}
          options={{ headerStyle: { backgroundColor: '#FF9500' }, headerTintColor: 'white' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}