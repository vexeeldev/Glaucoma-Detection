import axios from 'axios';

// 1. Atur URL dasar biar gak ngetik http://localhost terus
const instance = axios.create({
  baseURL: 'http://localhost:8000/api',
});

// 2. Request Interceptor: Otomatis tempelkan Token di setiap kiriman
instance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    config.headers.Accept = 'application/json';
    return config;
  },
  (error) => Promise.reject(error)
);

// 3. Response Interceptor: Kalau Server bilang 401, otomatis Logout
instance.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      // Jika token mati/invalid, hapus semua & lempar ke login
      localStorage.clear();
      window.location.href = '/login'; 
    }
    return Promise.reject(error);
  }
);

export default instance;