import { useState, useEffect } from 'react';
import { Bell } from 'lucide-react';
import { MENU_ITEMS } from './Sidebar';

const Header = ({ activeMenu }) => {
  const [time, setTime] = useState(new Date().toLocaleString('id-ID'));

  useEffect(() => {
    const timer = setInterval(() => setTime(new Date().toLocaleString('id-ID')), 1000);
    return () => clearInterval(timer);
  }, []);

  const currentLabel = MENU_ITEMS.find((m) => m.id === activeMenu)?.label ?? '';

  return (
    <header className="h-[80px] bg-white border-b sticky top-0 z-30 px-8 flex items-center justify-between shadow-sm">
      <div>
        <h2 className="text-xl font-black text-gray-800 uppercase tracking-tight">
          {currentLabel}
        </h2>
        <p className="text-xs text-gray-400 font-medium">
          GlaucoScan v2.1.0 • RS Mata Jakarta
        </p>
      </div>

      <div className="flex items-center gap-6">
        <div className="text-right hidden sm:block">
          <p className="text-xs text-gray-400 font-bold uppercase">Waktu Sistem</p>
          <p className="text-sm font-mono font-bold text-gray-700">{time}</p>
        </div>
        <div className="w-px h-8 bg-gray-100" />
        <div className="flex items-center gap-4">
          <button className="relative p-2 text-gray-400 hover:text-gray-600 transition-colors">
            <Bell size={22} />
            <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full border-2 border-white" />
          </button>
          <div className="w-10 h-10 rounded-full bg-gray-100 border-2 border-white shadow-sm overflow-hidden">
            <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Admin" alt="Admin" />
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
