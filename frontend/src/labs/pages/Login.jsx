import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Eye, EyeOff, EyeIcon, Loader2 } from 'lucide-react';

const Login = ({ onLogin }) => {
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = (e) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      onLogin();
      navigate('/dashboard', { replace: true });
    }, 1000);
  };

  return (
    <div className="flex h-screen bg-white font-['Inter']">
      {/* Left Panel */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-[#1565C0] to-[#42A5F5] items-center justify-center p-12 text-white relative overflow-hidden">
        <div className="absolute top-0 right-0 -mr-20 -mt-20 w-80 h-80 bg-white/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-0 left-0 -ml-20 -mb-20 w-80 h-80 bg-blue-900/20 rounded-full blur-3xl"></div>

        <div className="relative text-center max-w-md">
          <div className="bg-white p-6 rounded-3xl inline-block mb-8 shadow-2xl">
            <Eye className="text-[#1565C0]" size={64} />
          </div>
          <h1 className="text-5xl font-bold mb-4">GlaucoScan</h1>
          <p className="text-xl font-light opacity-90 leading-relaxed">
            Sistem Deteksi Glaukoma Berbasis AI Terintegrasi RS Mata Sejahtera
          </p>
        </div>
      </div>

      {/* Right Panel */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-8">
        <div className="max-w-md w-full">
          <h2 className="text-3xl font-bold text-gray-900 mb-2">Selamat Datang</h2>
          <p className="text-gray-500 mb-8">Silakan masuk ke akun medis Anda</p>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
              <input
                type="email"
                required
                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all"
                placeholder="dokter@rsmata.id"
              />
            </div>
            <div className="relative">
              <label className="block text-sm font-medium text-gray-700 mb-2">Password</label>
              <input
                type={showPassword ? 'text' : 'password'}
                required
                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all"
                placeholder="••••••••"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-4 top-10 text-gray-400 hover:text-gray-600"
              >
                {showPassword ? <EyeOff size={20} /> : <EyeIcon size={20} />}
              </button>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-[#1565C0] text-white py-4 rounded-xl font-semibold shadow-lg hover:bg-blue-700 active:scale-[0.98] transition-all flex items-center justify-center gap-2"
            >
              {loading ? <Loader2 className="animate-spin" size={20} /> : 'Masuk'}
            </button>
          </form>

          <p className="mt-8 text-center text-sm text-gray-400">
            © 2025 RS Mata Sejahtera IT Division. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;