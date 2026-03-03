import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';

const Layout = ({ onLogout }) => (
  <div className="min-h-screen bg-[#F8FAFF] font-['Inter'] flex">
    <Sidebar onLogout={onLogout} />
    <main className="flex-1 ml-64 p-8">
      <Outlet />
    </main>
  </div>
);

export default Layout;