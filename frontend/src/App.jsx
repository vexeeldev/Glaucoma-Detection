import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';

/* ===== IMPORT COMPONENT & PAGES ===== */
import Login from './auth/Login';
import MainLayout from './admin/Layouts/MainLayouts';
import DashboardPage from './admin/pages/DashboardPage';
import UserPage from './admin/pages/UserPage';
import DoctorPage from './admin/pages/DoctorPage';
import AppointmentPage from './admin/pages/AppointmentPage';
import ExaminationPage from './admin/pages/ExaminationPage';
import MLModelPage from './admin/pages/MLModelPage';
import ActivityLogPage from './admin/pages/ActivityLogPage';

import Layout from './labs/components/Layout';
import Dashboard from './labs/pages/Dashboard';
import Examination from './labs/pages/Examination';
import History from './labs/pages/History';

// Komponen Proteksi Route
const ProtectedRoute = ({ isLoggedIn, children }) => {
  if (!isLoggedIn) return <Navigate to="/login" replace />;
  return children;
};

export default function App() {
  // Ambil status login dari localStorage (biar gak hilang pas refresh)
  const [isLoggedIn, setIsLoggedIn] = useState(
    localStorage.getItem('isLoggedIn') === 'true'
  );
  const [userRole, setUserRole] = useState(
    localStorage.getItem('userRole') || null
  );

  const handleLogin = (role) => {
    setIsLoggedIn(true);
    setUserRole(role);
    localStorage.setItem('isLoggedIn', 'true');
    localStorage.setItem('userRole', role);
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setUserRole(null);
    localStorage.clear(); // Hapus data login
  };

  return (
    <BrowserRouter>
      <Routes>
        {/* HALAMAN LOGIN */}
        <Route
          path="/login"
          element={
            isLoggedIn ? (
              // Jika sudah login, lempar ke dashboard sesuai role masing-masing
              <Navigate to={userRole === 'admin' ? "/admin/dashboard" : "/labs/dashboard"} replace />
            ) : (
              <Login onLogin={handleLogin} />
            )
          }
        />

        {/* ===== ADMIN AREA ===== */}
        <Route
          path="/admin"
          element={
            <ProtectedRoute isLoggedIn={isLoggedIn}>
              <MainLayout onLogout={handleLogout} />
            </ProtectedRoute>
          }
        >
          {/* Default path untuk /admin adalah dashboard */}
          <Route index element={<Navigate to="dashboard" replace />} />
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
              <Layout onLogout={handleLogout} />
            </ProtectedRoute>
          }
        >
          <Route index element={<Navigate to="dashboard" replace />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="pemeriksaan" element={<Examination />} />
          <Route path="riwayat" element={<History />} />
        </Route>

        {/* CATCH ALL */}
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}