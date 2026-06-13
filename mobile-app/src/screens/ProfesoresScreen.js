import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, StyleSheet, ActivityIndicator, SafeAreaView } from 'react-native';
import api from '../services/api';

export default function ProfesoresScreen() {
  const [profesores, setProfesores] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    cargarProfesores();
  }, []);

  const cargarProfesores = async () => {
    try {
      const response = await api.get('/profesores');
      setProfesores(response.data.data);
    } catch (err) {
      setError('Error al cargar profesores: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color="#34C759" />
        <Text style={styles.loadingText}>Cargando profesores...</Text>
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
      <Text style={styles.header}>Total: {profesores.length} profesores</Text>
      <FlatList
        data={profesores}
        keyExtractor={(item, index) => (item.id_profesor || index).toString()}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <Text style={styles.nombre}>
              {item.nombre} {item.apellido_paterno} {item.apellido_materno}
            </Text>
            <Text style={styles.detalle}>RFC: {item.rfc}</Text>
            <Text style={styles.detalle}>📧 {item.correo_electronico}</Text>
            <Text style={styles.detalle}>📱 {item.telefono}</Text>
            <Text style={styles.detalle}>💰 Sueldo: ${item.sueldo}</Text>
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
  header: { padding: 15, fontSize: 16, fontWeight: '600', backgroundColor: '#34C759', color: 'white' },
  card: { backgroundColor: 'white', padding: 15, marginVertical: 5, marginHorizontal: 10, borderRadius: 10 },
  nombre: { fontSize: 16, fontWeight: 'bold', marginBottom: 5 },
  detalle: { fontSize: 14, color: '#555', marginTop: 2 },
});