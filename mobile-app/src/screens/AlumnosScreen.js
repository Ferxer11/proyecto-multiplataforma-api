import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, StyleSheet, ActivityIndicator, SafeAreaView } from 'react-native';
import api from '../services/api';

export default function AlumnosScreen() {
  const [alumnos, setAlumnos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    cargarAlumnos();
  }, []);

  const cargarAlumnos = async () => {
    try {
      const response = await api.get('/alumnos');
      setAlumnos(response.data.data);
    } catch (err) {
      setError('Error al cargar alumnos: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color="#007AFF" />
        <Text style={styles.loadingText}>Cargando alumnos...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.centered}>
        <Text style={styles.errorText}>{error}</Text>
      </View>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.header}>Total: {alumnos.length} alumnos</Text>
      <FlatList
        data={alumnos}
        keyExtractor={(item) => item.numero_cuenta.toString()}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <Text style={styles.nombre}>
              {item.nombre} {item.apellido_paterno} {item.apellido_materno}
            </Text>
            <Text style={styles.detalle}>Cuenta: {item.numero_cuenta}</Text>
            <Text style={styles.detalle}>📧 {item.correo_electronico}</Text>
            <Text style={styles.detalle}>📱 {item.telefono}</Text>
          </View>
        )}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f5f5f5' },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20 },
  loadingText: { marginTop: 10, color: '#666' },
  errorText: { color: 'red', textAlign: 'center' },
  header: { padding: 15, fontSize: 16, fontWeight: '600', backgroundColor: '#007AFF', color: 'white' },
  card: { backgroundColor: 'white', padding: 15, marginVertical: 5, marginHorizontal: 10, borderRadius: 10 },
  nombre: { fontSize: 16, fontWeight: 'bold', marginBottom: 5 },
  detalle: { fontSize: 14, color: '#555', marginTop: 2 },
});