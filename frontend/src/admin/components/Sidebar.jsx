import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Users,
  Stethoscope,
  Calendar,
  Microscope,
  Cpu,
  ClipboardList,
  LogOut,
  Eye,
} from 'lucide-react';

// Pastikan path di sini sesuai dengan yang ada di App.jsx kamu
export const MENU_ITEMS = [
  { id: 'dashboard',    label: 'Dashboard',             path: '/admin/dashboard',    icon: LayoutDashboard },
  { id: 'users',        label: 'Manajemen User',         path: '/admin/users',        icon: Users },
  { id: 'doctors',      label: 'Manajemen Dokter',       path: '/admin/doctors',      icon: Stethoscope },
  { id: 'appointments', label: 'Manajemen Appointment',  path: '/admin/appointments', icon: Calendar },
  { id: 'examinations', label: 'Manajemen Pemeriksaan',  path: '/admin/examinations', icon: Microscope },
  { id: 'ml',           label: 'ML Model',               path: '/admin/ml',           icon: Cpu },
  { id: 'logs',         label: 'Activity Log',           path: '/admin/logs',         icon: ClipboardList },
];

// Hapus 'activeMenu' dan 'setMenu' dari parameter props di bawah ini
const Sidebar = ({ onLogout }) => (
  <div className="w-[240px] bg-[#1565C0] text-white flex flex-col fixed h-screen z-40">
    {/* Logo */}
    <div className="p-8">
      <div className="flex items-center gap-3 mb-1">
        <div className="p-2 bg-white/20 rounded-xl backdrop-blur-sm">
          <Eye size={24} strokeWidth={2.5} />
        </div>
        <h1 className="text-2xl font-black tracking-tight">GlaucoScan</h1>
      </div>
      <p className="text-xs font-bold text-blue-200 uppercase tracking-widest ml-12">Web Admin</p>
    </div>

    {/* Navigation */}
    <nav className="flex-1 px-4 py-4 space-y-1 overflow-y-auto">
      {MENU_ITEMS.map((item) => (
        <NavLink
          key={item.id}
          to={item.path}
          // Fungsi onClick={() => setMenu(...)} SUDAH DIHAPUS agar tidak error
          className={({ isActive }) => `
            w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all font-semibold text-sm
            ${isActive 
              ? 'bg-white text-[#1565C0] shadow-lg shadow-black/10 scale-105' 
              : 'text-blue-100 hover:bg-white/10'}
          `}
        >
          {({ isActive }) => (
            <>
              <item.icon size={20} strokeWidth={isActive ? 2.5 : 2} />
              {item.label}
            </>
          )}
        </NavLink>
      ))}
    </nav>

    {/* User info + Logout */}
    <div className="p-4 border-t border-white/10 space-y-2">
      <div className="bg-white/10 p-4 rounded-2xl flex items-center gap-3">
        <div className="w-10 h-10 rounded-full bg-blue-400 flex items-center justify-center font-bold border-2 border-white/20 text-xs">
          AS
        </div>
        <div>
          <p className="text-xs font-bold">Admin Sistem</p>
          <p className="text-[10px] text-blue-200 uppercase">Super Admin</p>
        </div>
      </div>
      <button
        onClick={onLogout}
        className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-red-100 hover:bg-red-500/20 font-bold text-sm transition-all"
      >
        <LogOut size={20} /> Logout
      </button>
    </div>
  </div>
);

export default Sidebar;