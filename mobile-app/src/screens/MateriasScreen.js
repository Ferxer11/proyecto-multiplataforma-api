import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, StyleSheet, ActivityIndicator, SafeAreaView } from 'react-native';
import api from '../services/api';

export default function MateriasScreen() {
  const [materias, setMaterias] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    cargarMaterias();
  }, []);

  const cargarMaterias = async () => {
    try {
      const response = await api.get('/asignaturas');
      setMaterias(response.data.data);
    } catch (err) {
      setError('Error al cargar materias: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color="#FF9500" />
        <Text style={styles.loadingText}>Cargando materias...</Text>
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
      <Text style={styles.header}>Total: {materias.length} materias</Text>
      <FlatList
        data={materias}
        keyExtractor={(item, index) => (item.id_asignatura || index).toString()}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <Text style={styles.nombre}>{item.nombre}</Text>
            <Text style={styles.detalle}>Clave: {item.clave_asignatura}</Text>
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
  header: { padding: 15, fontSize: 16, fontWeight: '600', backgroundColor: '#FF9500', color: 'white' },
  card: { backgroundColor: 'white', padding: 15, marginVertical: 5, marginHorizontal: 10, borderRadius: 10 },
  nombre: { fontSize: 16, fontWeight: 'bold', marginBottom: 5 },
  detalle: { fontSize: 14, color: '#555', marginTop: 2 },
});