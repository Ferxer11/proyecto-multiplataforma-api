import axios from 'axios';

// URL de tu API en Render
const API_URL = 'https://proyecto-multiplataforma-api.onrender.com/api';

const api = axios.create({
  baseURL: API_URL,
  timeout: 60000, // 60 segundos (Render free a veces tarda)
});

export default api;