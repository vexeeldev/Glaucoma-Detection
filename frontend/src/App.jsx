import { useState } from 'react';
import {
  BrowserRouter,
  Routes,
  Route,
  Navigate,
} from 'react-router-dom';

import Layout from './labs/components/Layout';
import Login from './labs/pages/Login';
import Dashboard from './labs/pages/Dashboard';
import Examination from './labs/pages/Examination';
import History from './labs/pages/History';

// Guard: redirect ke /login jika belum autentikasi
const ProtectedRoute = ({ isLoggedIn, children }) => {
  if (!isLoggedIn) return <Navigate to="/login" replace />;
  return children;
};

const App = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  return (
    <BrowserRouter>
      <Routes>
        {/* Halaman Login — redirect ke dashboard jika sudah login */}
        <Route
          path="/login"
          element={
            isLoggedIn
              ? <Navigate to="/dashboard" replace />
              : <Login onLogin={() => setIsLoggedIn(true)} />
          }
        />

        {/* Halaman yang butuh autentikasi — dibungkus Layout sebagai Outlet */}
        <Route
          element={
            <ProtectedRoute isLoggedIn={isLoggedIn}>
              <Layout onLogout={() => setIsLoggedIn(false)} />
            </ProtectedRoute>
          }
        >
          <Route path="/dashboard"    element={<Dashboard />} />
          <Route path="/pemeriksaan"  element={<Examination />} />
          <Route path="/riwayat"      element={<History />} />
        </Route>

        {/* Fallback — arahkan ke login */}
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;