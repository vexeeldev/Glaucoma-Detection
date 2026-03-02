import { useState } from 'react';
import {
  BrowserRouter,
  Routes,
  Route,
  Navigate,
} from 'react-router-dom';

/* ===== ADMIN ===== */
import MainLayout from './admin/Layouts/MainLayout';
import DashboardPage from './admin/pages/DashboardPage';
import UserPage from './admin/pages/UserPage';
import DoctorPage from './admin/pages/DoctorPage';
import AppointmentPage from './admin/pages/AppointmentPage';
import ExaminationPage from './admin/pages/ExaminationPage';
import MLModelPage from './admin/pages/MLModelPage';
import ActivityLogPage from './admin/pages/ActivityLogPage';

/* ===== LABS ===== */
import Layout from './labs/components/Layout';
import Dashboard from './labs/pages/Dashboard';
import Examination from './labs/pages/Examination';
import History from './labs/pages/History';

// ===== LOGIN =====
import Login from './auth/Login';

const ProtectedRoute = ({ isLoggedIn, children }) => {
  if (!isLoggedIn) return <Navigate to="/login" replace />;
  return children;
};

export default function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  return (
    <BrowserRouter>
      <Routes>

        {/* Login (shared) */}
        <Route
          path="/login"
          element={
            isLoggedIn
              ? <Navigate to="/admin/dashboard" replace />
              : <Login onLogin={() => setIsLoggedIn(true)} />
          }
        />

        {/* ===== ADMIN AREA ===== */}
        <Route
          path="/admin"
          element={
            <ProtectedRoute isLoggedIn={isLoggedIn}>
              <MainLayout onLogout={() => setIsLoggedIn(false)} />
            </ProtectedRoute>
          }
        >
          <Route path="dashboard" element={<DashboardPage />} />
          <Route path="users" element={<UserPage />} />
          <Route path="doctors" element={<DoctorPage />} />
          <Route path="appointments" element={<AppointmentPage />} />
          <Route path="examinations" element={<ExaminationPage />} />
          <Route path="ml" element={<MLModelPage />} />
          <Route path="logs" element={<ActivityLogPage />} />
        </Route>

        {/* ===== LABS AREA ===== */}
        <Route
          path="/labs"
          element={
            <ProtectedRoute isLoggedIn={isLoggedIn}>
              <Layout />
            </ProtectedRoute>
          }
        >
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="pemeriksaan" element={<Examination />} />
          <Route path="riwayat" element={<History />} />
        </Route>

        <Route path="*" element={<Navigate to="/login" replace />} />

      </Routes>
    </BrowserRouter>
  );
}