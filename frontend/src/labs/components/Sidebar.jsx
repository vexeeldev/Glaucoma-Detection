import { useNavigate, useLocation } from 'react-router-dom';
import { Eye, LayoutDashboard, ClipboardList, History, LogOut } from 'lucide-react';
import axios from 'axios';

const NAV_ITEMS = [
  { label: 'Dashboard',    path: '/labs/dashboard',   icon: LayoutDashboard },
  { label: 'Pemeriksaan',  path: '/labs/pemeriksaan', icon: ClipboardList },
  { label: 'Riwayat',      path: '/labs/riwayat',     icon: History },
];

const Sidebar = ({ onLogout }) => {
  const navigate  = useNavigate();
  const { pathname } = useLocation();
  
  // Ambil data user dari localStorage
  const userData = JSON.parse(localStorage.getItem('user')) || {};
  const userName = userData.name || 'User';
  const userLevel = userData.admin?.admin_level || 'Staff';
  const initial = userName.substring(0, 2).toUpperCase();

  const handleLogout = async () => {
    const token = localStorage.getItem('token');
    try {
      if (token) {
        await axios.post('http://localhost:8000/api/labs/logout', {}, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          }
        });
      }
    } catch (err) {
      console.error("Logout gagal di server:", err);
    } finally {
      localStorage.clear();
      onLogout();
      navigate('/login');
    }
  };

  return (
    <div className="w-64 bg-[#1565C0] text-white flex flex-col h-screen fixed left-0 top-0 z-10">
      <div className="p-6 flex items-center gap-3 border-b border-blue-400/30">
        <div className="bg-white p-2 rounded-lg">
          <Eye className="text-[#1565C0]" size={24} />
        </div>
        <span className="text-xl font-bold tracking-tight">GlaucoScan</span>
      </div>

      <nav className="flex-1 mt-6 px-4">
        <ul className="space-y-2">
          {NAV_ITEMS.map(({ label, path, icon: Icon }) => (
            <li key={path}>
              <button
                onClick={() => navigate(path)}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${
                  pathname === path
                    ? 'bg-white/20 font-semibold'
                    : 'hover:bg-white/10 opacity-80'
                }`}
              >
                <Icon size={20} /> {label}
              </button>
            </li>
          ))}
        </ul>
      </nav>

      {/* FOOTER SIDEBAR: INFO USER OTOMATIS */}
      <div className="p-6 mt-auto">
        <div className="flex items-center gap-3 mb-6 p-3 bg-white/10 rounded-xl overflow-hidden">
          <div className="w-10 h-10 shrink-0 rounded-full bg-blue-300 flex items-center justify-center text-blue-900 font-bold">
            {initial}
          </div>
          <div className="overflow-hidden">
            <p className="text-sm font-semibold truncate">{userName}</p>
            <p className="text-[10px] opacity-70 uppercase font-black tracking-wider">
              {userLevel}
            </p>
          </div>
        </div>
        <button
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-red-500/20 text-red-100 transition-all border border-red-400/30 font-bold"
        >
          <LogOut size={20} /> Keluar
        </button>
      </div>
    </div>
  );
};

export default Sidebar;