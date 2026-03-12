import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Eye, EyeOff, Loader2, ShieldCheck, Activity, 
  Stethoscope, ChevronRight, Lock 
} from 'lucide-react';

const Login = ({ onLogin }) => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [role, setRole] = useState('admin');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    setLoading(true);

    // Simulasi API Call
    setTimeout(() => {
      setLoading(false);
      
      // 1. Simpan status di State Utama (App.jsx)
      onLogin(role);

      // 2. Arahkan URL secara fisik
      if (role === 'admin') {
        navigate('/admin/dashboard');
      } else {
        navigate('/labs/dashboard');
      }
    }, 1500);
  };

  return (
    <div className="flex min-h-screen bg-slate-50 font-sans">
      {/* Panel Kiri: Visual (Hidden on Mobile) */}
      <div className="hidden lg:flex lg:w-[55%] relative overflow-hidden bg-[#0f172a] items-center justify-center p-12">
        <div className="absolute top-[-10%] left-[-10%] w-[50%] h-[50%] bg-blue-600/20 rounded-full blur-[120px]"></div>
        <div className="relative z-10 max-w-xl text-white">
          <div className="mb-10 inline-flex items-center gap-3 px-4 py-2 bg-white/5 border border-white/10 rounded-full backdrop-blur-md">
            <ShieldCheck className="text-blue-400" size={18} />
            <span className="text-blue-100 text-sm font-medium">AI-Powered Eye Diagnostics v2.4</span>
          </div>
          <h1 className="text-6xl font-extrabold mb-6 leading-tight">
            Presisi AI untuk <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-cyan-300">Kesehatan Mata.</span>
          </h1>
          <p className="text-lg text-slate-400 mb-12">
            GlaucoScan membantu praktisi medis mendeteksi indikasi glaukoma dengan akurasi 98.7%.
          </p>
        </div>
      </div>

      {/* Panel Kanan: Form */}
      <div className="w-full lg:w-[45%] flex items-center justify-center p-6 bg-white">
        <div className="w-full max-w-md">
          <div className="mb-10">
            <div className="w-14 h-14 bg-blue-600 rounded-2xl flex items-center justify-center mb-6 shadow-lg shadow-blue-200">
                <Eye className="text-white" size={32} />
            </div>
            <h2 className="text-3xl font-bold text-slate-900 mb-2 italic">GlaucoScan</h2>
            <p className="text-slate-500">Silakan akses portal Anda.</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Role Switcher */}
            <div className="p-1 bg-slate-100 rounded-xl flex mb-8">
              <button
                type="button"
                onClick={() => setRole('admin')}
                className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-semibold transition-all ${
                  role === 'admin' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500'
                }`}
              >
                <Stethoscope size={16} /> Admin
              </button>
              <button
                type="button"
                onClick={() => setRole('labs')}
                className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-semibold transition-all ${
                  role === 'labs' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500'
                }`}
              >
                <Activity size={16} /> Lab Teknisi
              </button>
            </div>

            {/* Email */}
            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700">Email Institusi</label>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="nama@rsmata.id"
                className="w-full pl-4 py-3.5 bg-slate-50 border border-slate-200 rounded-xl focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all"
              />
            </div>

            {/* Password */}
            <div className="space-y-2">
              <div className="flex justify-between items-center">
                <label className="text-sm font-semibold text-slate-700">Kata Sandi</label>
                <button type="button" className="text-xs font-medium text-blue-600 hover:underline">Lupa sandi?</button>
              </div>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full pl-4 pr-12 py-3.5 bg-slate-50 border border-slate-200 rounded-xl focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-600 text-white py-4 rounded-xl font-bold text-lg shadow-xl shadow-blue-100 hover:bg-blue-700 active:scale-[0.99] transition-all flex items-center justify-center gap-3 disabled:opacity-70"
            >
              {loading ? (
                <><Loader2 className="animate-spin" size={20} /><span>Memverifikasi...</span></>
              ) : (
                <><span className="ml-5">Masuk ke Portal</span><ChevronRight size={20} /></>
              )}
            </button>
          </form>

          <div className="mt-12 pt-8 border-t border-slate-100 flex flex-col items-center gap-4 text-center">
             <div className="flex items-center gap-2 text-slate-400 text-xs">
                <Lock size={12} />
                <span>Enkripsi AES-256 Bit Terjamin</span>
             </div>
             <p className="text-xs text-slate-400">© 2026 IT Division RS Mata Sejahtera.</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;