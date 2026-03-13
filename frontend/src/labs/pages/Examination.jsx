import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import {
  ArrowLeft, ChevronRight, CheckCircle, AlertCircle, Clock,
  Calendar, User, Info, FileText, Upload, Search, Download,
  Eye, Loader2,
} from 'lucide-react';
import {
  PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer,
} from 'recharts';
import { COLORS } from '../data/constants';

const Examination = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const appointmentId = searchParams.get('appointment_id');

  const [examStep, setExamStep] = useState(1);
  const [mlLoading, setMlLoading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);

  // --- STATE DATA REAL ---
  const [patient, setPatient] = useState(null);
  const [loadingPatient, setLoadingPatient] = useState(true);
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewUrl, setPreviewUrl] = useState(null);
  const [apiData, setApiData] = useState(null); 

  // 1. Ambil detail pasien berdasarkan ID dari URL
  useEffect(() => {
  const fetchPatientDetail = async () => {
    if (!appointmentId) return;
    try {
      const response = await axios.get(`/labs/examination-detail/${appointmentId}`);
      setPatient(response.data);
    } catch (error) {
      console.error("Gagal mengambil data pasien:", error);
    } finally {
      setLoadingPatient(false);
    }
    };

    fetchPatientDetail();
  }, [appointmentId]);

  const onFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setSelectedFile(file);
      setPreviewUrl(URL.createObjectURL(file));
    }
  };

  const handleUpload = async () => {
    if (!selectedFile) return alert("Silakan pilih gambar retina terlebih dahulu.");

    setExamStep(3);
    setMlLoading(true);
    setUploadProgress(10);

    const formData = new FormData();
    formData.append('image', selectedFile);
    formData.append('appointment_id', appointmentId); // Pakai ID dinamis

   const handleAnalysis = async () => {
    try {
      const interval = setInterval(() => {
        setUploadProgress(prev => (prev < 90 ? prev + 5 : prev));
      }, 150);

      // Kirim formData langsung ke Axios
      const response = await axios.post('/ml/check-glaucoma', formData);

      clearInterval(interval);

      if (response.data.status === 'success') {
        setApiData(response.data.data);
        setUploadProgress(100);
      } else {
        alert("Gagal: " + (response.data.message || "Server Error"));
        setExamStep(2);
      }
      } catch (error) {
        alert("Koneksi gagal.");
        setExamStep(2);
      } finally {
        setMlLoading(false);
      }
    };
  };

  // 2. Fungsi Selesaikan & Balik ke Dashboard
  const handleFinish = async () => {
    try {
      await axios.post(`/labs/examination-complete/${appointmentId}`);
      navigate('/labs/dashboard');
    } catch (error) {
      console.error("Gagal update status:", error.response?.data?.message || error.message);
    }
  };

  // Logic Tampilan Dinamis (Real dari API)
  const rawScore = apiData ? apiData.confidence_score : 0;
  const isGlaucoma = apiData?.analysis.is_glaucoma;
  const resultLabel = isGlaucoma ? 'GLAUKOMA' : 'NORMAL';
  const confidence = apiData ? (apiData.confidence_score * 100) : 0;
  const glaucomaValue = isGlaucoma ? (rawScore * 100) : (rawScore * 100);
  const normalValue = 100 - glaucomaValue;

  const pieData = [
    { name: 'Normal', value: normalValue },
    { name: 'Glaukoma', value: glaucomaValue },
  ];
  const displayConfidence = isGlaucoma 
  ? (rawScore * 100) 
  : (1 - rawScore) * 100;

  if (loadingPatient) return <div className="p-20 text-center font-bold text-blue-600 animate-pulse">Menghubungkan ke Ruang Periksa...</div>;

  return (
    <div className="max-w-4xl mx-auto animate-in slide-in-from-bottom-4 duration-500 pb-20">
      {/* Header */}
      <div className="mb-8 flex items-center gap-4">
        <button onClick={() => navigate('/labs/dashboard')} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
          <ArrowLeft size={24} />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Alur Deteksi AI</h1>
          <p className="text-gray-500 text-sm">Pemeriksaan Pasien: <span className="font-bold text-gray-700">{patient?.name}</span></p>
        </div>
      </div>

      {/* Stepper Header */}
      <div className="flex items-center justify-between mb-12 relative px-10">
        <div className="absolute top-1/2 left-0 w-full h-1 bg-gray-200 -translate-y-1/2 -z-10"></div>
        <div
          className="absolute top-1/2 left-0 h-1 bg-blue-600 -translate-y-1/2 -z-10 transition-all duration-500"
          style={{ width: `${(examStep - 1) * 50}%` }}
        ></div>
        {[1, 2, 3].map((s) => (
          <div key={s} className="flex flex-col items-center gap-3 bg-[#f8fafc] px-2">
            <div
              className={`w-12 h-12 rounded-full flex items-center justify-center font-bold text-lg transition-all shadow-lg ${
                examStep >= s ? 'bg-blue-600 text-white scale-110' : 'bg-white text-gray-400 border-2 border-gray-200'
              }`}
            >
              {examStep > s ? <CheckCircle size={24} /> : s}
            </div>
            <span className={`text-sm font-semibold ${examStep >= s ? 'text-blue-600' : 'text-gray-400'}`}>
              {s === 1 ? 'Info Pasien' : s === 2 ? 'Upload Gambar' : 'Hasil Deteksi'}
            </span>
          </div>
        ))}
      </div>

      {/* Step 1: Info Pasien (Dinamis) */}
      {examStep === 1 && (
        <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-10">
            <div className="space-y-6">
              <div>
                <h3 className="text-xs uppercase text-gray-400 font-bold mb-3 tracking-widest">Data Personal</h3>
                <div className="p-4 bg-gray-50 rounded-2xl space-y-3">
                  <div className="flex justify-between">
                    <span className="text-gray-500">Nama Lengkap</span>
                    <span className="font-bold">{patient?.name}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500">Usia / Gender</span>
                    <span className="font-bold">{patient?.age} / {patient?.gender}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500">ID Medis</span>
                    <span className="font-bold text-blue-600">#PX-{appointmentId}</span>
                  </div>
                </div>
              </div>
              <div>
                <h3 className="text-xs uppercase text-gray-400 font-bold mb-3 tracking-widest">Informasi Janji</h3>
                <div className="p-4 bg-gray-50 rounded-2xl space-y-3">
                  <div className="flex items-center gap-3 text-sm font-medium text-gray-700">
                    <Calendar size={18} className="text-blue-500" /> Jadwal: {patient?.date}
                  </div>
                  <div className="flex items-center gap-3 text-sm font-medium text-gray-700">
                    <Clock size={18} className="text-blue-500" /> Jam: {patient?.date}
                  </div>
                  <div className="flex items-center gap-3 text-sm font-medium text-gray-700">
                    <User size={18} className="text-blue-500" /> Pemeriksa: {patient?.doctor}
                  </div>
                </div>
              </div>
            </div>
            <div>
              <h3 className="text-xs uppercase text-gray-400 font-bold mb-3 tracking-widest">Keluhan Utama</h3>
              <div className="p-6 bg-blue-50 text-blue-800 rounded-3xl min-h-[160px] italic relative overflow-hidden">
                <div className="absolute top-0 right-0 p-4 opacity-10">
                  <FileText size={80} />
                </div>
                "{patient?.complaint}"
              </div>
              <div className="mt-6 flex items-start gap-3 text-sm text-gray-500 p-4 border border-dashed border-gray-200 rounded-2xl">
                <Info size={20} className="text-orange-400 shrink-0" />
                <span className="font-medium">Catatan: {patient?.medical_history}</span>
              </div>
            </div>
          </div>
          <button
            onClick={() => setExamStep(2)}
            className="w-full py-4 bg-[#1565C0] text-white rounded-2xl font-bold shadow-lg hover:bg-blue-700 active:scale-[0.99] transition-all flex items-center justify-center gap-3"
          >
            Mulai Pemeriksaan <ChevronRight size={20} />
          </button>
        </div>
      )}

      {/* Step 2: Upload (UI Utuh) */}
      {examStep === 2 && (
        <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
          <div className="mb-10 text-center">
            <label className="block text-sm font-bold text-gray-700 mb-4 uppercase tracking-widest">Upload Foto Retina: {patient?.name}</label>
            <div className="border-2 border-dashed border-gray-200 rounded-3xl p-12 text-center hover:border-blue-400 hover:bg-blue-50/50 transition-all cursor-pointer group relative overflow-hidden">
              <input type="file" className="absolute inset-0 opacity-0 cursor-pointer z-10" onChange={onFileChange} accept="image/*" />
              {previewUrl ? (
                <div className="relative">
                  <img src={previewUrl} className="h-64 rounded-2xl shadow-md mx-auto object-cover border-4 border-white" alt="Preview" />
                  <p className="mt-4 text-blue-600 font-bold bg-blue-50 inline-block px-4 py-1 rounded-full">{selectedFile?.name}</p>
                </div>
              ) : (
                <>
                  <div className="bg-blue-100 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform shadow-inner">
                    <Upload size={32} className="text-blue-600" />
                  </div>
                  <p className="text-lg font-bold text-gray-900 mb-1">Pilih gambar atau tarik ke sini</p>
                  <p className="text-sm text-gray-400">Dukung file JPG, PNG, atau TIFF (Maks. 10MB)</p>
                </>
              )}
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-10 text-left">
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-3">Sisi Mata</label>
                <div className="grid grid-cols-3 gap-3">
                  {['Kiri', 'Kanan', 'Keduanya'].map((opt) => (
                    <button key={opt} className={`py-3 px-4 rounded-xl text-sm font-semibold border-2 transition-all ${opt === 'Kiri' ? 'border-blue-600 bg-blue-50 text-blue-600' : 'border-gray-100 text-gray-500'}`}>
                      {opt}
                    </button>
                  ))}
                </div>
              </div>
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-3 uppercase tracking-tighter text-[10px]">Model Alat Kamera</label>
                <input type="text" className="w-full px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 font-medium text-sm" defaultValue="Canon CR-2 AF" />
              </div>
            </div>
            <div>
              <label className="block text-sm font-bold text-gray-700 mb-3">Catatan Pengambilan (Opsional)</label>
              <textarea className="w-full px-4 py-3 rounded-xl border border-gray-200 h-[126px] bg-gray-50" placeholder="Misal: Cahaya redup karena pupil tidak melebar..."></textarea>
            </div>
          </div>

          {uploadProgress > 0 && (
            <div className="mb-6">
              <div className="flex justify-between text-[10px] font-black text-blue-600 mb-2 uppercase tracking-widest">
                <span>Mengirim Citra ke Server AI...</span>
                <span>{uploadProgress}%</span>
              </div>
              <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                <div className="h-full bg-blue-600 transition-all duration-300" style={{ width: `${uploadProgress}%` }}></div>
              </div>
            </div>
          )}

          <button
            onClick={handleUpload}
            disabled={!selectedFile || (uploadProgress > 0 && uploadProgress < 100)}
            className="w-full py-4 bg-[#1565C0] text-white rounded-2xl font-bold shadow-lg hover:bg-blue-700 active:scale-[0.99] transition-all flex items-center justify-center gap-3 disabled:opacity-50"
          >
            Upload & Analisis Sekarang <Search size={20} />
          </button>
        </div>
      )}

      {/* Step 3: Hasil (UI Utuh - Recharts) */}
      {examStep === 3 && (
        <div className="animate-in fade-in zoom-in-95 duration-700">
          {mlLoading ? (
            <div className="bg-white p-24 rounded-3xl shadow-sm border border-gray-100 flex flex-col items-center justify-center text-center">
              <div className="relative mb-8">
                <div className="w-24 h-24 border-8 border-blue-50 border-t-blue-600 rounded-full animate-spin"></div>
                <div className="absolute inset-0 flex items-center justify-center">
                  <Eye className="text-blue-200" size={32} />
                </div>
              </div>
              <h2 className="text-2xl font-bold text-gray-900 mb-2">AI sedang menganalisis retina...</h2>
              <p className="text-gray-500 max-w-sm font-medium">Sistem sedang menghitung probabilitas glaukoma untuk {patient?.name}.</p>
            </div>
          ) : (
            <div className="space-y-6">
              <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
                <div className="flex flex-col md:flex-row gap-8 items-center mb-10">
                  <div
                    className={`p-10 rounded-[48px] flex flex-col items-center justify-center min-w-[280px] shadow-2xl border-4 transition-all duration-1000 ${
                      !isGlaucoma ? 'bg-green-50 border-green-200 shadow-green-100' : 'bg-red-50 border-red-200 shadow-red-100'
                    }`}
                  >
                    <p className="text-xs font-black uppercase tracking-[0.2em] text-gray-400 mb-3 text-center">Hasil Sistem AI</p>
                    <h2 className={`text-5xl font-black mb-1 tracking-tighter ${!isGlaucoma ? 'text-green-700' : 'text-red-700'}`}>
                      {resultLabel}
                    </h2>
                    <div className={`flex items-center gap-2 font-bold uppercase text-xs mt-2 ${!isGlaucoma ? 'text-green-600' : 'text-red-600'}`}>
                      {!isGlaucoma ? <CheckCircle size={18} /> : <AlertCircle size={18} />}
                      {!isGlaucoma ? 'Kesehatan Baik' : 'Gejala Glaukoma'}
                    </div>
                  </div>

                  <div className="flex-1 w-full text-left">
                    <div className="flex justify-between mb-2 items-end">
                      <div>
                        <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1 italic">Confidence Score</p>
                        <p className="text-4xl font-black text-gray-900 tracking-tighter">{displayConfidence.toFixed(1)}%</p>
                      </div>
                      <span className="text-[10px] font-bold text-blue-600 bg-blue-50 px-3 py-1.5 rounded-full border border-blue-100 uppercase tracking-tighter">
                        AI MODEL: v4.2 PRO
                      </span>
                    </div>
                    <div className="h-4 bg-gray-100 rounded-full overflow-hidden mb-6 shadow-inner">
                      <div
                        className={`h-full transition-all duration-[1500ms] shadow-lg ${!isGlaucoma ? 'bg-green-500' : 'bg-red-500'}`}
                        style={{ width: `${displayConfidence}%` }}
                      ></div>
                    </div>
                    {apiData && (
                        <div className="p-5 bg-blue-50/50 border-l-[6px] border-blue-600 rounded-r-2xl text-gray-700 text-sm italic font-medium leading-relaxed">
                            "{apiData.medical_advice}"
                        </div>
                    )}
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-10 pt-8 border-t border-gray-50">
                  {/* Pie Chart (Recharts) */}
                  <div className="text-center">
                    <h3 className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-6 flex items-center justify-center gap-2">
                      <Info size={16} className="text-blue-500" /> Analisis Probabilitas
                    </h3>
                    <div className="h-64">
                      <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                          <Pie data={pieData} innerRadius={65} outerRadius={85} paddingAngle={8} dataKey="value" stroke="none">
                            <Cell fill="#10B981" />
                            <Cell fill="#EF4444" />
                          </Pie>
                          <Tooltip />
                          <Legend verticalAlign="bottom" height={36} />
                        </PieChart>
                      </ResponsiveContainer>
                    </div>
                  </div>

                  {/* Visualisasi (Eye) */}
                  <div className="text-center">
                    <h3 className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-6 flex items-center justify-center gap-2">
                      <Eye size={16} className="text-blue-500" /> Layer Pemrosesan AI
                    </h3>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-3">
                        <div className="aspect-square bg-gray-50 rounded-3xl overflow-hidden border-4 border-white shadow-md">
                          <img src={previewUrl} className="object-cover w-full h-full" alt="Input" />
                        </div>
                        <p className="text-[9px] font-black text-gray-400 uppercase">Original</p>
                      </div>
                      <div className="space-y-3">
                        <div className="aspect-square bg-gray-50 rounded-3xl overflow-hidden border-4 border-white shadow-md relative">
                          <img src={previewUrl} className="object-cover w-full h-full opacity-50 grayscale" alt="Heatmap" />
                          <div className={`absolute inset-0 ${isGlaucoma ? 'bg-red-500/30' : 'bg-blue-500/20'} mix-blend-overlay`}></div>
                        </div>
                        <p className="text-[9px] font-black text-gray-400 uppercase">Heatmap</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex gap-4">
                <button className="flex-1 py-4 bg-white border-2 border-gray-200 rounded-2xl font-black text-[10px] uppercase tracking-widest text-gray-500 hover:bg-gray-50 transition-all active:scale-95 shadow-sm flex items-center justify-center gap-2">
                  <Download size={20} /> Download PDF
                </button>
                <button 
                   onClick={handleFinish} 
                   className="flex-[2] py-4 bg-green-600 text-white rounded-2xl font-black text-[10px] uppercase tracking-[0.2em] shadow-xl hover:bg-green-700 active:scale-[0.99] transition-all flex items-center justify-center gap-3"
                >
                  Selesaikan & Simpan Medis <ChevronRight size={20} />
                </button>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default Examination;