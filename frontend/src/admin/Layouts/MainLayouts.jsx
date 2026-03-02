import React from 'react';
import { Outlet } from 'react-router-dom'; // PENTING: Ganti children dengan ini
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';

/**
 * MainLayout
 * Menggunakan Outlet agar Route anak (Dashboard, User, dll) 
 * bisa muncul secara otomatis di area <main>.
 */
const MainLayout = ({ onLogout }) => (
  <div className="flex min-h-screen bg-[#F5F7FA] font-['Inter']">
    {/* activeMenu dan setMenu dihapus karena Sidebar sudah pakai NavLink */}
    <Sidebar onLogout={onLogout} />

    <div className="flex-1 ml-[240px]">
      {/* Header bisa tetap ada, tapi logic activeMenu di dalamnya 
          mungkin perlu disesuaikan atau dihapus jika tidak dipakai */}
      <Header />

      <main className="p-8">
        {/* TEMPAT HALAMAN MUNCUL */}
        <Outlet /> 
      </main>
    </div>
  </div>
);

export default MainLayout;