import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Eye, EyeOff, Loader2, ShieldCheck, Activity, 
  Stethoscope, ChevronRight, Lock, AlertCircle 
} from 'lucide-react';
import axios from 'axios';

const Login = ({ onLogin }) => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [role, setRole] = useState('labs'); // State tombol yang diklik
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errorMsg, setErrorMsg] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg('');

    try {
      // 1. Tembak API Laravel
      const response = await axios.post('http://localhost:8000/api/labs/login', {
        email: email,
        password: password
      });

      if (response.data.success) {
        const { token, user } = response.data.data;
        const realLevel = user.admin.admin_level; // Ambil level asli dari DB (misal: 'adminops')

        // 2. LOGIKA VALIDASI SILANG (SINKRONISASI TOMBOL VS DATABASE)
        // Jika user pilih 'Admin' di tombol, tapi di DB dia 'adminops' (Khusus Lab)
        if (role === 'admin' && realLevel === 'adminops') {
          setErrorMsg('Akses Ditolak. Akun Anda terdaftar sebagai Lab Teknisi, silakan masuk melalui portal Lab.');
          setLoading(false);
          return; // Stop di sini, jangan biarkan masuk
        }

        // Jika user pilih 'Lab Teknisi' tapi ternyata dia bukan 'adminops' (misal Superadmin)
        if (role === 'labs' && realLevel !== 'adminops') {
          setErrorMsg('Akses Ditolak. Akun Anda bukan bagian dari Lab Teknisi.');
          setLoading(false);
          return;
        }

        // 3. JIKA LOLOS VALIDASI: Simpan Data & Pindah Halaman
        localStorage.setItem('token', token);
        localStorage.setItem('user', JSON.stringify(user));
        onLogin(role);

        if (role === 'labs') {
          navigate('/labs/dashboard');
        } else {
          navigate('/admin/dashboard');
        }
      }
    } catch (err) {
      // Handle error (401 Unauthorized, 403 Forbidden, dsb)
      const message = err.response?.data?.message || 'Email atau password salah.';
      setErrorMsg(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen bg-slate-50 font-sans">
      {/* Panel Kiri: Visual UI */}
      <div className="hidden lg:flex lg:w-[55%] relative overflow-hidden bg-[#0f172a] items-center justify-center p-12">
        <div className="absolute top-[-10%] left-[-10%] w-[50%] h-[50%] bg-blue-600/20 rounded-full blur-[120px]"></div>
        <div className="relative z-10 max-w-xl text-white">
          <div className="mb-10 inline-flex items-center gap-3 px-4 py-2 bg-white/5 border border-white/10 rounded-full backdrop-blur-md">
            <ShieldCheck className="text-blue-400" size={18} />
            <span className="text-blue-100 text-sm font-medium">AI-Powered Eye Diagnostics v2.4</span>
          </div>
          <h1 className="text-6xl font-extrabold mb-6 leading-tight italic">
            Presisi AI untuk <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-cyan-300">Kesehatan Mata.</span>
          </h1>
          <p className="text-lg text-slate-400 mb-12">
            Verifikasi identitas Anda untuk mengakses database pasien dan hasil analisis AI GlaucoScan.
          </p>
        </div>
      </div>

      {/* Panel Kanan: Login Form */}
      <div className="w-full lg:w-[45%] flex items-center justify-center p-6 bg-white">
        <div className="w-full max-w-md">
          <div className="mb-10">
            <div className="w-14 h-14 bg-blue-600 rounded-2xl flex items-center justify-center mb-6 shadow-xl shadow-blue-100">
                <Eye className="text-white" size={32} />
            </div>
            <h2 className="text-3xl font-bold text-slate-900 mb-2 italic">GlaucoScan</h2>
            <p className="text-slate-500 font-medium">Gerbang Akses Portal Medis.</p>
          </div>

          {/* Alert Pesan Error */}
          {errorMsg && (
            <div className="mb-6 p-4 bg-red-50 border border-red-100 rounded-2xl flex items-center gap-3 text-red-600 animate-in fade-in slide-in-from-top-2">
              <AlertCircle size={20} className="shrink-0" />
              <span className="text-sm font-bold leading-tight">{errorMsg}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Role Switcher - Penentu Gerbang Masuk */}
            <div className="p-1.5 bg-slate-100 rounded-2xl flex mb-8 border border-slate-200 shadow-inner">
              <button
                type="button"
                onClick={() => setRole('admin')}
                className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-xl text-sm font-black transition-all ${
                  role === 'admin' ? 'bg-white text-blue-600 shadow-md' : 'text-slate-500 hover:text-slate-700'
                }`}
              >
                <Stethoscope size={18} /> Admin
              </button>
              <button
                type="button"
                onClick={() => setRole('labs')}
                className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-xl text-sm font-black transition-all ${
                  role === 'labs' ? 'bg-white text-blue-600 shadow-md' : 'text-slate-500 hover:text-slate-700'
                }`}
              >
                <Activity size={18} /> Lab Teknisi
              </button>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-black text-slate-700 ml-1">Email Institusi</label>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="nama@rsmata.id"
                className="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 outline-none transition-all font-semibold"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-black text-slate-700 ml-1">Kata Sandi</label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full px-5 pr-14 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 outline-none transition-all font-semibold"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-blue-600 transition-colors"
                >
                  {showPassword ? <EyeOff size={22} /> : <Eye size={22} />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-600 text-white py-4 rounded-2xl font-black text-lg shadow-xl shadow-blue-200 hover:bg-blue-700 active:scale-[0.98] transition-all flex items-center justify-center gap-3 disabled:opacity-70 mt-4"
            >
              {loading ? (
                <><Loader2 className="animate-spin" size={24} /><span>Memverifikasi...</span></>
              ) : (
                <><span className="ml-5 italic">Otorisasi Masuk</span><ChevronRight size={24} /></>
              )}
            </button>
          </form>

          <div className="mt-12 pt-8 border-t border-slate-100 flex flex-col items-center gap-4 text-center">
             <div className="flex items-center gap-2 text-slate-300 text-[10px] font-black uppercase tracking-widest">
                <Lock size={12} />
                <span>AES-256 Cloud Secure Access</span>
             </div>
             <p className="text-[10px] text-slate-400 font-bold italic">© 2026 Divisi IT RS Mata Sejahtera Lamongan.</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;