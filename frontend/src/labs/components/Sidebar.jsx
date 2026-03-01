import { useNavigate, useLocation } from 'react-router-dom';
import { Eye, LayoutDashboard, ClipboardList, History, LogOut } from 'lucide-react';

const NAV_ITEMS = [
  { label: 'Dashboard',    path: '/dashboard',   icon: LayoutDashboard },
  { label: 'Pemeriksaan',  path: '/pemeriksaan', icon: ClipboardList },
  { label: 'Riwayat',      path: '/riwayat',     icon: History },
];

const Sidebar = ({ onLogout }) => {
  const navigate  = useNavigate();
  const { pathname } = useLocation();

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

      <div className="p-6 mt-auto">
        <div className="flex items-center gap-3 mb-6 p-3 bg-white/10 rounded-xl">
          <div className="w-10 h-10 rounded-full bg-blue-300 flex items-center justify-center text-blue-900 font-bold">
            BS
          </div>
          <div>
            <p className="text-sm font-semibold">dr. Budi Santoso</p>
            <p className="text-xs opacity-70">Spesialis Mata</p>
          </div>
        </div>
        <button
          onClick={onLogout}
          className="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-red-500/20 text-red-100 transition-all border border-red-400/30"
        >
          <LogOut size={20} /> Keluar
        </button>
      </div>
    </div>
  );
};

export default Sidebar;
