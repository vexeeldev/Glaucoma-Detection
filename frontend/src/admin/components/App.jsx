import { useState } from 'react';

import MainLayout      from './layouts/MainLayout';
import LoginPage       from './pages/LoginPage';
import DashboardPage   from './pages/DashboardPage';
import UserPage        from './pages/UserPage';
import DoctorPage      from './pages/DoctorPage';
import AppointmentPage from './pages/AppointmentPage';
import ExaminationPage from './pages/ExaminationPage';
import MLModelPage     from './pages/MLModelPage';
import ActivityLogPage from './pages/ActivityLogPage';

const renderPage = (activeMenu) => {
  switch (activeMenu) {
    case 'dashboard':    return <DashboardPage />;
    case 'users':        return <UserPage />;
    case 'doctors':      return <DoctorPage />;
    case 'appointments': return <AppointmentPage />;
    case 'examinations': return <ExaminationPage />;
    case 'ml':           return <MLModelPage />;
    case 'logs':         return <ActivityLogPage />;
    default:             return <DashboardPage />;
  }
};

export default function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [activeMenu, setActiveMenu] = useState('dashboard');

  if (!isLoggedIn) {
    return <LoginPage onLogin={() => setIsLoggedIn(true)} />;
  }

  return (
    <MainLayout
      activeMenu={activeMenu}
      setMenu={setActiveMenu}
      onLogout={() => setIsLoggedIn(false)}
    >
      {renderPage(activeMenu)}
    </MainLayout>
  );
}
