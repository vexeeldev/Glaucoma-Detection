import Sidebar from '../components/Sidebar';
import Header from '../components/Header';

/**
 * MainLayout
 * Wraps every authenticated page with sidebar + header.
 * Pass children (the active page) as a prop.
 */
const MainLayout = ({ children, activeMenu, setMenu, onLogout }) => (
  <div className="flex min-h-screen bg-[#F5F7FA] font-['Inter']">
    <Sidebar activeMenu={activeMenu} setMenu={setMenu} onLogout={onLogout} />

    <div className="flex-1 ml-[240px]">
      <Header activeMenu={activeMenu} />

      <main className="p-8">{children}</main>
    </div>
  </div>
);

export default MainLayout;
