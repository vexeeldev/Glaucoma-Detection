import React, { useState, useEffect } from "react";
import {
    Eye,
    Smartphone,
    Layout,
    ShieldCheck,
    Cpu,
    CheckCircle,
    Mail,
    Github,
    MapPin,
    Menu,
    X,
    ChevronRight,
    Database,
    Users,
    Calendar,
    FileText,
    Activity,
    Award,
    ArrowRight,
    Code2,
    Server,
    Layers,
    Search,
    Zap,
    Clock,
    Globe,
    DatabaseBackup,
} from "lucide-react";
import { useNavigate } from "react-router-dom";

// --- Sub-Components ---

const SectionHeader = ({ title, subtitle }) => (
    <div className="mb-12 animate-in fade-in slide-in-from-left-4 duration-700">
        <div className="flex items-center gap-2 mb-3">
            <div className="w-12 h-1 bg-[#F5A623] rounded-full"></div>
            <span className="text-xs font-black uppercase tracking-[0.3em] text-[#1565C0]">
                GlaucoScan System
            </span>
        </div>
        <h2 className="text-4xl md:text-5xl font-black text-[#0D1B3E] leading-tight mb-4">
            {title}
        </h2>
        <p className="text-slate-500 text-lg max-w-2xl leading-relaxed">
            {subtitle}
        </p>
    </div>
);

const HomePage = ({ setPage }) => (
    <div className="py-10 animate-in fade-in zoom-in duration-500">
        <div className="flex flex-col lg:flex-row items-center gap-16 mb-24">
            <div className="flex-1 space-y-8 text-center lg:text-left">
                <div className="inline-flex items-center gap-2 bg-blue-50 border border-blue-100 text-[#1565C0] px-4 py-2 rounded-xl text-sm font-bold">
                    <Activity className="w-4 h-4 animate-pulse" />
                    Proyek Integrasi 4 Mata Kuliah Utama
                </div>
                <h1 className="text-5xl lg:text-7xl font-black text-[#0D1B3E] leading-[1.1] tracking-tight">
                    Hentikan Glaukoma <br />
                    <span className="text-[#1565C0]">Sebelum Terlambat.</span>
                </h1>
                <p className="text-xl text-slate-500 leading-relaxed max-w-2xl mx-auto lg:mx-0">
                    GlaucoScan menggunakan{" "}
                    <span className="text-[#0D1B3E] font-bold underline decoration-[#F5A623] decoration-4">
                        Computer Vision
                    </span>{" "}
                    tercanggih untuk mendeteksi tanda-tanda awal kerusakan saraf
                    optik melalui analisis fundus retina yang cepat dan akurat.
                </p>
                <div className="flex flex-wrap justify-center lg:justify-start gap-4 pt-4">
                    <button
                        onClick={() => setPage("fitur")}
                        className="bg-[#1565C0] text-white px-10 py-5 rounded-2xl font-black text-lg hover:shadow-2xl hover:shadow-blue-200 transition-all flex items-center gap-3 group"
                    >
                        Eksplorasi Sistem{" "}
                        <ArrowRight className="group-hover:translate-x-2 transition-transform" />
                    </button>
                    <button
                        onClick={() => setPage("alur")}
                        className="bg-white border-2 border-slate-200 text-slate-600 px-10 py-5 rounded-2xl font-black text-lg hover:bg-slate-50 transition-all"
                    >
                        Cara Kerja
                    </button>
                </div>
            </div>

            <div className="flex-1 relative">
                <div className="relative z-10 bg-white p-6 rounded-[3rem] shadow-[0_40px_80px_-15px_rgba(21,101,192,0.25)] border border-blue-50 group">
                    <div className="bg-slate-900 aspect-square rounded-[2.5rem] overflow-hidden relative">
                        <div className="absolute inset-0 bg-gradient-to-tr from-[#1565C0]/60 to-transparent"></div>
                        <div className="absolute inset-0 flex items-center justify-center">
                            <Eye className="w-40 h-40 text-white/20 group-hover:scale-110 transition-transform duration-[2000ms] animate-pulse" />
                        </div>

                        {/* UI Overlays */}
                        <div className="absolute top-8 left-8 bg-black/40 backdrop-blur-md px-4 py-2 rounded-full border border-white/20">
                            <p className="text-white text-[10px] font-bold tracking-widest flex items-center gap-2 italic">
                                <span className="w-2 h-2 bg-green-400 rounded-full animate-ping"></span>{" "}
                                LIVE ANALYSIS
                            </p>
                        </div>

                        <div className="absolute bottom-8 left-8 right-8 bg-white p-5 rounded-2xl shadow-2xl">
                            <div className="flex justify-between items-center mb-3">
                                <span className="text-xs font-black text-slate-400 uppercase tracking-tighter">
                                    Result Probability
                                </span>
                                <span className="bg-blue-100 text-[#1565C0] px-2 py-1 rounded text-[10px] font-black italic">
                                    CNN EfficientNet
                                </span>
                            </div>
                            <div className="h-4 bg-slate-100 rounded-full overflow-hidden mb-2">
                                <div className="h-full bg-gradient-to-r from-[#1565C0] to-[#42A5F5] w-[95.8%] transition-all duration-1000"></div>
                            </div>
                            <p className="text-[#0D1B3E] font-black text-xl">
                                Normal{" "}
                                <span className="text-slate-300 font-light">
                                    / Glaucoma Suspicious
                                </span>
                            </p>
                        </div>
                    </div>
                </div>
                <div className="absolute -top-12 -right-12 w-64 h-64 bg-[#F5A623]/20 rounded-full blur-[80px]"></div>
                <div className="absolute -bottom-12 -left-12 w-64 h-64 bg-blue-600/20 rounded-full blur-[80px]"></div>
            </div>
        </div>

        {/* Quick Technical Specs Bar */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 py-12 border-y border-slate-100 mb-20">
            {[
                {
                    icon: <Database className="text-[#1565C0]" />,
                    label: "Dataset Size",
                    value: "24,000+ Image",
                },
                {
                    icon: <Zap className="text-[#F5A623]" />,
                    label: "Inference Speed",
                    value: "< 1.5 Seconds",
                },
                {
                    icon: <ShieldCheck className="text-emerald-500" />,
                    label: "Model Accuracy",
                    value: "95.82%",
                },
                {
                    icon: <Globe className="text-indigo-500" />,
                    label: "Integration",
                    value: "4 Platforms",
                },
            ].map((item, idx) => (
                <div
                    key={idx}
                    className="flex flex-col items-center md:items-start"
                >
                    <div className="mb-2">{item.icon}</div>
                    <div className="text-xs font-black text-slate-400 uppercase tracking-widest mb-1">
                        {item.label}
                    </div>
                    <div className="text-2xl font-black text-[#0D1B3E]">
                        {item.value}
                    </div>
                </div>
            ))}
        </div>
    </div>
);

const FiturPage = () => {
    const [activeTab, setActiveTab] = useState(0);
    const data = [
        {
            id: "mobile",
            title: "Mobile Client App",
            role: "User-Facing Platform",
            icon: <Smartphone className="w-7 h-7" />,
            desc: "Dikembangkan menggunakan Flutter, aplikasi ini menjadi jembatan utama antara pasien dan sistem kesehatan, memudahkan akses diagnosis dari genggaman.",
            details: [
                {
                    title: "Smart Appointment",
                    text: "Integrasi jadwal real-time dengan Web Admin Rumah Sakit.",
                },
                {
                    title: "Digital Health Record",
                    text: "Menyimpan seluruh riwayat diagnosis citra retina secara terenkripsi.",
                },
                {
                    title: "Payment Gateway",
                    text: "Mendukung berbagai metode pembayaran dari VA hingga E-Wallet.",
                },
                {
                    title: "AI Assistant",
                    text: "Edukasi glaukoma berbasis chatbot sederhana untuk pasien.",
                },
            ],
        },
        {
            id: "lab",
            title: "Diagnostic Web Lab",
            role: "Clinical Interface",
            icon: <Layout className="w-7 h-7" />,
            desc: "Platform khusus teknisi laboratorium dan dokter spesialis untuk melakukan pemrosesan gambar fundus secara presisi dan mendalam.",
            details: [
                {
                    title: "Batch Processing",
                    text: "Kemampuan upload beberapa citra sekaligus untuk antrean klinik.",
                },
                {
                    title: "Grad-CAM Visualization",
                    text: "Heatmap AI yang menunjukkan area mana yang dianggap mencurigakan.",
                },
                {
                    title: "Diagnostic Export",
                    text: "Hasil PDF yang komprehensif dengan metrik probabilitas glaukoma.",
                },
                {
                    title: "Real-time Processing",
                    text: "Integrasi langsung ke Python ML Service via REST API.",
                },
            ],
        },
        {
            id: "admin",
            title: "Central Admin Dashboard",
            role: "Management Control",
            icon: <ShieldCheck className="w-7 h-7" />,
            desc: "Pusat kendali ekosistem GlaucoScan. Mengelola seluruh data pengguna, jadwal praktik, hingga monitoring performa sistem.",
            details: [
                {
                    title: "User Analytics",
                    text: "Grafik statistik harian untuk memantau trafik pasien dan klinik.",
                },
                {
                    title: "RBAC System",
                    text: "Role-Based Access Control untuk keamanan data medis pasien.",
                },
                {
                    title: "Audit Trail",
                    text: "Log aktivitas lengkap untuk memantau setiap akses ke data sensitif.",
                },
                {
                    title: "Model Monitoring",
                    text: "Dashboard khusus untuk melihat status versi model Machine Learning.",
                },
            ],
        },
        {
            id: "ml",
            title: "ML Engine Service",
            role: "The Brain (AI Core)",
            icon: <Cpu className="w-7 h-7" />,
            desc: "Layanan backend khusus berbasis Python yang menginangi model Deep Learning untuk pemrosesan citra medis.",
            details: [
                {
                    title: "EfficientNetB0 Core",
                    text: "Arsitektur state-of-the-art yang dioptimasi untuk akurasi tinggi.",
                },
                {
                    title: "Image Preprocessing",
                    text: "CLAHE & Gaussian Blur otomatis untuk meningkatkan kontras pembuluh darah.",
                },
                {
                    title: "Scalable API",
                    text: "Dibangun dengan Flask/FastAPI untuk skalabilitas permintaan tinggi.",
                },
                {
                    title: "Data Versioning",
                    text: "Menggunakan DVC untuk manajemen dataset training yang masif.",
                },
            ],
        },
    ];

    return (
        <div className="py-10 animate-in fade-in slide-in-from-bottom-8 duration-700">
            <SectionHeader
                title="Arsitektur Sistem Terpadu"
                subtitle="GlaucoScan bukan sekadar satu aplikasi, melainkan ekosistem yang saling terhubung untuk menjamin efisiensi diagnosis dari hulu ke hilir."
            />

            <div className="grid lg:grid-cols-12 gap-10">
                <div className="lg:col-span-4 flex flex-col gap-3">
                    {data.map((item, i) => (
                        <button
                            key={item.id}
                            onClick={() => setActiveTab(i)}
                            className={`w-full text-left p-6 rounded-[2rem] transition-all border-2 flex items-center gap-5 ${
                                activeTab === i
                                    ? "bg-[#1565C0] border-[#1565C0] text-white shadow-2xl shadow-blue-200 translate-x-2"
                                    : "bg-white border-slate-100 text-slate-500 hover:border-blue-200"
                            }`}
                        >
                            <div
                                className={`${activeTab === i ? "bg-white/20" : "bg-blue-50 text-[#1565C0]"} p-4 rounded-2xl`}
                            >
                                {item.icon}
                            </div>
                            <div>
                                <p
                                    className={`text-[10px] font-black uppercase tracking-widest ${activeTab === i ? "text-blue-100" : "text-slate-400"}`}
                                >
                                    {item.role}
                                </p>
                                <p className="font-black text-lg">
                                    {item.title}
                                </p>
                            </div>
                        </button>
                    ))}
                </div>

                <div className="lg:col-span-8 bg-white p-12 rounded-[3rem] border border-slate-50 shadow-sm relative overflow-hidden flex flex-col justify-between">
                    <div className="relative z-10">
                        <h3 className="text-3xl font-black text-[#0D1B3E] mb-4">
                            {data[activeTab].title}
                        </h3>
                        <p className="text-lg text-slate-500 mb-10 leading-relaxed">
                            {data[activeTab].desc}
                        </p>

                        <div className="grid md:grid-cols-2 gap-6">
                            {data[activeTab].details.map((detail, idx) => (
                                <div
                                    key={idx}
                                    className="p-5 bg-slate-50 rounded-2xl border border-slate-100 hover:bg-blue-50 hover:border-blue-100 transition-colors"
                                >
                                    <div className="flex items-center gap-2 mb-2">
                                        <CheckCircle className="w-5 h-5 text-[#1565C0]" />
                                        <span className="font-black text-[#0D1B3E] text-sm uppercase tracking-tight">
                                            {detail.title}
                                        </span>
                                    </div>
                                    <p className="text-sm text-slate-500 leading-relaxed">
                                        {detail.text}
                                    </p>
                                </div>
                            ))}
                        </div>
                    </div>
                    <div className="absolute -bottom-20 -right-20 opacity-[0.05] grayscale">
                        {data[activeTab].icon}
                    </div>
                </div>
            </div>
        </div>
    );
};

const AlurPage = () => {
    const steps = [
        {
            title: "Registrasi & Booking",
            desc: "Pasien mendaftarkan diri dan memilih jadwal melalui aplikasi Mobile GlaucoScan.",
            icon: <Calendar />,
        },
        {
            title: "Akuisisi Citra",
            desc: "Petugas medis mengambil foto fundus retina pasien di klinik yang bermitra.",
            icon: <Search />,
        },
        {
            title: "Analisis AI Engine",
            desc: "Teknisi mengunggah foto ke Web Lab. AI menganalisis gambar dalam hitungan detik.",
            icon: <Cpu />,
        },
        {
            title: "Validasi Dokter",
            desc: "Dokter menerima hasil probabilitas dan memberikan diagnosis serta rekomendasi akhir.",
            icon: <Users />,
        },
        {
            title: "Penerimaan Hasil",
            desc: "Pasien mendapatkan laporan lengkap dan notifikasi tindak lanjut di perangkat mereka.",
            icon: <Smartphone />,
        },
    ];

    return (
        <div className="py-10 animate-in fade-in slide-in-from-right-4 duration-700">
            <SectionHeader
                title="Alur Kerja Sistem"
                subtitle="Bagaimana GlaucoScan mengotomatisasi proses diagnosis dari awal hingga akhir."
            />

            <div className="space-y-4 max-w-4xl mx-auto">
                {steps.map((step, i) => (
                    <div key={i} className="flex items-center gap-8 group">
                        <div className="flex flex-col items-center">
                            <div className="w-16 h-16 bg-[#0D1B3E] text-white rounded-2xl flex items-center justify-center shadow-lg group-hover:bg-[#1565C0] transition-colors relative z-10">
                                {step.icon}
                                <span className="absolute -left-3 text-4xl font-black text-slate-100 -z-10 group-hover:text-blue-50 transition-colors">
                                    0{i + 1}
                                </span>
                            </div>
                            {i < steps.length - 1 && (
                                <div className="w-0.5 h-16 bg-slate-200 my-2"></div>
                            )}
                        </div>
                        <div className="flex-1 bg-white p-8 rounded-[2rem] border border-slate-100 shadow-sm group-hover:border-blue-200 transition-all">
                            <h4 className="text-xl font-black text-[#0D1B3E] mb-2">
                                {step.title}
                            </h4>
                            <p className="text-slate-500 leading-relaxed">
                                {step.desc}
                            </p>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
};

const AboutPage = () => (
    <div className="py-10 animate-in fade-in duration-700">
        <SectionHeader
            title="Filosofi Proyek"
            subtitle="Membedah alasan teknis dan akademis di balik pembangunan GlaucoScan."
        />

        <div className="grid lg:grid-cols-2 gap-16 items-start">
            <div className="space-y-10">
                <div className="bg-white p-10 rounded-[3rem] shadow-sm border border-slate-50">
                    <h3 className="text-2xl font-black text-[#0D1B3E] mb-6 flex items-center gap-3">
                        <Layers className="text-[#1565C0]" /> Masalah & Solusi
                    </h3>
                    <div className="space-y-4 text-slate-600 leading-relaxed">
                        <p>
                            Glaukoma adalah penyebab kebutaan permanen kedua di
                            dunia. Sering disebut sebagai{" "}
                            <span className="text-[#0D1B3E] font-bold underline">
                                "The Silent Thief of Sight"
                            </span>{" "}
                            karena tidak menunjukkan gejala awal.
                        </p>
                        <p>
                            Hambatan utama di lapangan adalah kurangnya rasio
                            dokter spesialis mata dibanding jumlah penduduk.{" "}
                            <span className="font-bold">
                                GlaucoScan hadir sebagai solusi skrining massal
                            </span>{" "}
                            yang dapat ditempatkan di puskesmas atau klinik
                            tingkat pertama tanpa harus menunggu antrean
                            spesialis yang panjang.
                        </p>
                    </div>
                </div>

                <div className="bg-[#1565C0] p-10 rounded-[3rem] text-white shadow-2xl shadow-blue-100 relative overflow-hidden">
                    <div className="relative z-10">
                        <h3 className="text-2xl font-black mb-6">
                            Integrasi 4 Mata Kuliah UAS
                        </h3>
                        <div className="grid grid-cols-2 gap-4">
                            {[
                                {
                                    m: "Mobile Dev",
                                    t: "Flutter, Provider, API Integration",
                                },
                                {
                                    m: "Framework",
                                    t: "Laravel, MySQL, React.js",
                                },
                                { m: "AI Core", t: "CNN, TensorFlow, OpenCV" },
                                { m: "Cloud", t: "VPS, Docker, Nginx, Flask" },
                            ].map((item, i) => (
                                <div
                                    key={i}
                                    className="bg-white/10 backdrop-blur-sm p-4 rounded-2xl border border-white/10"
                                >
                                    <p className="text-[#F5A623] text-[10px] font-black uppercase tracking-widest">
                                        {item.m}
                                    </p>
                                    <p className="text-xs font-medium text-blue-100">
                                        {item.t}
                                    </p>
                                </div>
                            ))}
                        </div>
                    </div>
                    <Activity className="absolute -bottom-10 -right-10 w-40 h-40 opacity-10" />
                </div>
            </div>

            <div className="space-y-8">
                <div className="bg-slate-900 rounded-[3rem] p-10 text-white relative overflow-hidden">
                    <div className="absolute top-0 right-0 p-8 opacity-10">
                        <Code2 className="w-40 h-40" />
                    </div>
                    <h4 className="text-xl font-bold mb-8 flex items-center gap-3">
                        <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
                            <Server className="w-4 h-4" />
                        </div>
                        <span className="text-sm font-mono opacity-80 italic">
                            ml_service/inference.py
                        </span>
                    </h4>
                    <div className="space-y-4 font-mono text-xs leading-relaxed text-blue-100/70">
                        <p>
                            <span className="text-purple-400">def</span>{" "}
                            <span className="text-yellow-400">preprocess</span>
                            (img):
                        </p>
                        <p className="pl-6">
                            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
                        </p>
                        <p className="pl-6 text-slate-500">
                            # CLAHE for contrast enhancement
                        </p>
                        <p className="pl-6">
                            clahe = cv2.createCLAHE(clipLimit=2.0)
                        </p>
                        <p className="pl-6">
                            <span className="text-purple-400">return</span> img
                            / 255.0
                        </p>
                        <p className="pt-4">
                            <span className="text-purple-400">def</span>{" "}
                            <span className="text-yellow-400">predict</span>
                            (file):
                        </p>
                        <p className="pl-6">
                            model = tf.keras.models.load_model(
                            <span className="text-green-400">
                                'effnet_b0.h5'
                            </span>
                            )
                        </p>
                        <p className="pl-6">
                            score = model.predict(preprocess(file))
                        </p>
                        {/* FIX: Escaped curly braces for JSX literal rendering */}
                        <p className="pl-6">
                            <span className="text-purple-400">return</span>{" "}
                            {"{"}
                            <span className="text-green-400">"status"</span>:
                            score {">"} 0.5{"}"}
                        </p>
                    </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                    <div className="bg-white p-6 rounded-3xl border border-slate-100 flex items-center gap-4">
                        <DatabaseBackup className="text-indigo-500" />
                        <div>
                            <p className="text-xs font-black text-slate-400 uppercase">
                                Training Epochs
                            </p>
                            <p className="text-xl font-black text-[#0D1B3E]">
                                100+
                            </p>
                        </div>
                    </div>
                    <div className="bg-white p-6 rounded-3xl border border-slate-100 flex items-center gap-4">
                        <Users className="text-[#F5A623]" />
                        <div>
                            <p className="text-xs font-black text-slate-400 uppercase">
                                Beta Users
                            </p>
                            <p className="text-xl font-black text-[#0D1B3E]">
                                150+
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
);

const DeveloperPage = () => (
    <div className="py-10 animate-in fade-in zoom-in duration-700">
        <SectionHeader
            title="Tim Pengembang"
            subtitle="Di balik setiap baris kode terdapat dedikasi untuk inovasi teknologi kesehatan."
        />

        <div className="grid md:grid-cols-3 gap-10">
            {[
                {
                    name: "Malakul Kabir Arrabbani",
                    role: "AI Lead • Fullstack Web",
                    initial: "MK",
                    color: "from-blue-600 to-indigo-600",
                    skills: ["TensorFlow", "Laravel", "React"],
                },
                {
                    name: "Ahmad Syauqi",
                    role: "Backend Architecture",
                    initial: "AS",
                    color: "from-[#F5A623] to-[#FF8C00]",
                    skills: ["PHP", "SQL", "Cloud Hosting"],
                },
                {
                    name: "Ahmad Fikri",
                    role: "Mobile Engineer",
                    initial: "AF",
                    color: "from-emerald-500 to-teal-600",
                    skills: ["Flutter", "Dart", "Firebase"],
                },
            ].map((dev, i) => (
                <div key={i} className="group relative">
                    <div className="bg-white rounded-[3rem] p-10 border border-slate-100 shadow-sm hover:shadow-2xl hover:shadow-blue-100 transition-all duration-500 relative z-10">
                        <div
                            className={`w-24 h-24 bg-gradient-to-br ${dev.color} rounded-3xl mb-8 flex items-center justify-center text-4xl font-black text-white shadow-xl group-hover:rotate-12 transition-all duration-500`}
                        >
                            {dev.initial}
                        </div>
                        <h4 className="text-2xl font-black text-[#0D1B3E] mb-2">
                            {dev.name}
                        </h4>
                        <p className="text-[#1565C0] font-black text-sm mb-6 uppercase tracking-wider">
                            {dev.role}
                        </p>
                        <div className="flex flex-wrap gap-2 mb-10">
                            {dev.skills.map((s) => (
                                <span
                                    key={s}
                                    className="px-3 py-1 bg-slate-100 text-slate-500 rounded-lg text-[10px] font-black uppercase tracking-widest"
                                >
                                    {s}
                                </span>
                            ))}
                        </div>
                        <div className="flex gap-4 pt-8 border-t border-slate-50">
                            <div className="w-10 h-10 bg-slate-50 rounded-full flex items-center justify-center text-slate-400 hover:text-[#0D1B3E] hover:bg-slate-100 cursor-pointer transition-all">
                                <Github className="w-5 h-5" />
                            </div>
                            <div className="w-10 h-10 bg-slate-50 rounded-full flex items-center justify-center text-slate-400 hover:text-[#1565C0] hover:bg-blue-50 cursor-pointer transition-all">
                                <Mail className="w-5 h-5" />
                            </div>
                        </div>
                    </div>
                    <div className="absolute inset-0 bg-blue-600 rounded-[3rem] translate-y-4 translate-x-4 -z-10 opacity-0 group-hover:opacity-10 transition-all"></div>
                </div>
            ))}
        </div>
    </div>
);

const KontakPage = () => (
    <div className="py-10 animate-in fade-in slide-in-from-left-4 duration-700">
        <SectionHeader
            title="Hubungi Kami"
            subtitle="Punya pertanyaan atau ingin berdiskusi lebih lanjut? Kirimkan pesan Anda."
        />

        <div className="bg-white rounded-[4rem] shadow-2xl border border-slate-50 flex flex-col lg:flex-row overflow-hidden max-w-6xl mx-auto">
            <div className="lg:w-[40%] bg-[#0D1B3E] p-16 text-white relative">
                <h2 className="text-5xl font-black mb-10 leading-none">
                    Let's Talk.
                </h2>
                <div className="space-y-10">
                    {[
                        {
                            icon: <Mail className="text-[#F5A623]" />,
                            label: "Email Support",
                            val: "glaucoscan@gmail.com",
                        },
                        {
                            icon: <Github className="text-[#42A5F5]" />,
                            label: "Open Source",
                            val: "github.com/glaucoscan",
                        },
                        {
                            icon: <MapPin className="text-emerald-500" />,
                            label: "Location",
                            val: "Surakarta, Indonesia",
                        },
                    ].map((item, i) => (
                        <div key={i} className="flex items-start gap-6">
                            <div className="bg-white/5 p-4 rounded-2xl border border-white/10">
                                {item.icon}
                            </div>
                            <div>
                                <p className="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1">
                                    {item.label}
                                </p>
                                <p className="font-bold text-lg">{item.val}</p>
                            </div>
                        </div>
                    ))}
                </div>
                <div className="absolute bottom-0 right-0 w-32 h-32 bg-[#1565C0] rounded-tl-[4rem] flex items-center justify-center">
                    <Zap className="w-10 h-10 text-white animate-bounce" />
                </div>
            </div>

            <div className="lg:w-[60%] p-16">
                <form
                    className="space-y-8"
                    onSubmit={(e) => e.preventDefault()}
                >
                    <div className="grid md:grid-cols-2 gap-8">
                        <div className="space-y-2">
                            <label className="text-xs font-black text-slate-400 uppercase tracking-[0.2em] ml-1">
                                Nama Lengkap
                            </label>
                            <input
                                type="text"
                                className="w-full bg-slate-50 border-2 border-transparent focus:border-[#1565C0] focus:bg-white rounded-2xl px-8 py-5 transition-all outline-none"
                                placeholder="Masukkan nama Anda..."
                            />
                        </div>
                        <div className="space-y-2">
                            <label className="text-xs font-black text-slate-400 uppercase tracking-[0.2em] ml-1">
                                Email Aktif
                            </label>
                            <input
                                type="email"
                                className="w-full bg-slate-50 border-2 border-transparent focus:border-[#1565C0] focus:bg-white rounded-2xl px-8 py-5 transition-all outline-none"
                                placeholder="john@example.com"
                            />
                        </div>
                    </div>
                    <div className="space-y-2">
                        <label className="text-xs font-black text-slate-400 uppercase tracking-[0.2em] ml-1">
                            Pesan Utama
                        </label>
                        <textarea
                            rows="5"
                            className="w-full bg-slate-50 border-2 border-transparent focus:border-[#1565C0] focus:bg-white rounded-3xl px-8 py-5 transition-all outline-none resize-none"
                            placeholder="Apa yang ingin Anda sampaikan?"
                        ></textarea>
                    </div>
                    <button className="bg-[#1565C0] text-white px-12 py-5 rounded-2xl font-black text-xl shadow-2xl shadow-blue-200 hover:bg-[#0D1B3E] transition-all transform hover:-translate-y-1 w-full md:w-auto">
                        Kirim Pesan Sekarang
                    </button>
                </form>
            </div>
        </div>
    </div>
);

// --- MAIN APP ---

export default function Landing() {
    const navigate = useNavigate();
    const [page, setPage] = useState("home");
    const [isMenuOpen, setIsMenuOpen] = useState(false);

    const menuItems = [
        { id: "home", label: "Home" },
        { id: "fitur", label: "Fitur" },
        { id: "alur", label: "Alur Sistem" },
        { id: "about", label: "About" },
        { id: "developer", label: "Developer" },
        { id: "kontak", label: "Kontak" },
    ];

    return (
        <div className="min-h-screen bg-[#F8FAFF] font-sans text-slate-900 selection:bg-blue-100 selection:text-[#1565C0]">
            {/* Dynamic Header */}
            <header className="sticky top-0 z-50 bg-white/70 backdrop-blur-2xl border-b border-slate-100">
                <div className="container mx-auto px-6 h-24 flex items-center justify-between">
                    <div
                        onClick={() => setPage("home")}
                        className="flex items-center gap-3 cursor-pointer group"
                    >
                        <div className="bg-[#1565C0] p-2.5 rounded-2xl group-hover:scale-110 transition-all shadow-xl shadow-blue-100">
                            <Eye className="text-white w-7 h-7" />
                        </div>
                        <div className="flex flex-col leading-none">
                            <span className="text-2xl font-black tracking-tighter text-[#0D1B3E]">
                                Glauco
                                <span className="text-[#1565C0]">Scan</span>
                            </span>
                            <span className="text-[10px] font-black text-[#F5A623] uppercase tracking-[0.2em] mt-1">
                                AI Diagnostic
                            </span>
                        </div>
                    </div>

                    {/* Desktop Nav */}
                    <nav className="hidden lg:flex items-center gap-1">
                        {menuItems.map((item) => (
                            <button
                                key={item.id}
                                onClick={() => setPage(item.id)}
                                className={`px-6 py-3 rounded-2xl text-xs font-black uppercase tracking-widest transition-all ${
                                    page === item.id
                                        ? "bg-blue-50 text-[#1565C0]"
                                        : "text-slate-400 hover:text-[#0D1B3E] hover:bg-slate-50"
                                }`}
                            >
                                {item.label}
                            </button>
                        ))}
                        <div className="w-px h-8 bg-slate-200 mx-6"></div>
                        <button
                            onClick={() => navigate("/login")}
                            className="bg-[#1565C0] text-white px-8 py-3.5 rounded-2xl font-black text-xs uppercase tracking-widest shadow-lg shadow-blue-100 hover:shadow-2xl transition-all"
                        >
                            Mulai Diagnosis
                        </button>
                    </nav>

                    {/* Mobile Toggle */}
                    <button
                        className="lg:hidden p-3 bg-slate-100 rounded-2xl text-[#0D1B3E]"
                        onClick={() => setIsMenuOpen(!isMenuOpen)}
                    >
                        {isMenuOpen ? <X /> : <Menu />}
                    </button>
                </div>

                {/* Mobile Nav Overlay */}
                {isMenuOpen && (
                    <div className="lg:hidden absolute top-full left-0 w-full bg-white/95 backdrop-blur-xl border-b border-slate-100 p-8 flex flex-col gap-3 shadow-2xl animate-in fade-in slide-in-from-top-6">
                        {menuItems.map((item) => (
                            <button
                                key={item.id}
                                onClick={() => {
                                    setPage(item.id);
                                    setIsMenuOpen(false);
                                }}
                                className={`w-full text-left p-5 rounded-2xl font-black uppercase tracking-widest transition-all ${
                                    page === item.id
                                        ? "bg-blue-50 text-[#1565C0]"
                                        : "text-slate-500"
                                }`}
                            >
                                {item.label}
                            </button>
                        ))}
                    </div>
                )}
            </header>

            {/* Main Content Area */}
            <main className="container mx-auto px-6 min-h-[calc(100vh-200px)] py-12">
                {page === "home" && <HomePage setPage={setPage} />}
                {page === "fitur" && <FiturPage />}
                {page === "alur" && <AlurPage />}
                {page === "about" && <AboutPage />}
                {page === "developer" && <DeveloperPage />}
                {page === "kontak" && <KontakPage />}
            </main>

            {/* Modern Footer */}
            <footer className="bg-white py-16 border-t border-slate-100 mt-20">
                <div className="container mx-auto px-6">
                    <div className="flex flex-col md:flex-row justify-between items-start gap-12 mb-16">
                        <div className="max-w-sm">
                            <div className="flex items-center gap-3 mb-6">
                                <div className="bg-slate-900 p-2 rounded-xl">
                                    <Eye className="text-white w-5 h-5" />
                                </div>
                                <span className="text-xl font-black text-[#0D1B3E]">
                                    Glauco
                                    <span className="text-[#1565C0]">Scan</span>
                                </span>
                            </div>
                            <p className="text-slate-500 leading-relaxed font-medium">
                                Misi kami adalah memberikan akses diagnosis
                                kesehatan mata yang adil dan cerdas bagi seluruh
                                lapisan masyarakat melalui teknologi AI.
                            </p>
                        </div>

                        <div className="grid grid-cols-2 md:grid-cols-3 gap-12">
                            <div className="space-y-6">
                                <h5 className="text-[10px] font-black text-[#0D1B3E] uppercase tracking-widest border-b border-[#F5A623] pb-2 inline-block">
                                    Platform
                                </h5>
                                <ul className="space-y-4 text-sm font-bold text-slate-400">
                                    <li
                                        className="hover:text-[#1565C0] cursor-pointer"
                                        onClick={() => setPage("fitur")}
                                    >
                                        Sistem Terpadu
                                    </li>
                                    <li
                                        className="hover:text-[#1565C0] cursor-pointer"
                                        onClick={() => setPage("about")}
                                    >
                                        AI Engine
                                    </li>
                                    <li
                                        className="hover:text-[#1565C0] cursor-pointer"
                                        onClick={() => setPage("alur")}
                                    >
                                        Workflow
                                    </li>
                                </ul>
                            </div>
                            <div className="space-y-6">
                                <h5 className="text-[10px] font-black text-[#0D1B3E] uppercase tracking-widest border-b border-[#F5A623] pb-2 inline-block">
                                    Legal
                                </h5>
                                <ul className="space-y-4 text-sm font-bold text-slate-400">
                                    <li className="hover:text-[#1565C0] cursor-pointer">
                                        Privacy Policy
                                    </li>
                                    <li className="hover:text-[#1565C0] cursor-pointer">
                                        Medical Disclaimer
                                    </li>
                                    <li className="hover:text-[#1565C0] cursor-pointer">
                                        Terms of Use
                                    </li>
                                </ul>
                            </div>
                            <div className="space-y-6 hidden md:block">
                                <h5 className="text-[10px] font-black text-[#0D1B3E] uppercase tracking-widest border-b border-[#F5A623] pb-2 inline-block">
                                    Social
                                </h5>
                                <div className="flex gap-4">
                                    <div className="w-10 h-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-400 hover:bg-slate-900 hover:text-white transition-all cursor-pointer">
                                        <Github className="w-5 h-5" />
                                    </div>
                                    <div className="w-10 h-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-400 hover:bg-red-500 hover:text-white transition-all cursor-pointer">
                                        <Mail className="w-5 h-5" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="pt-10 border-t border-slate-50 flex flex-col md:flex-row justify-between items-center gap-6">
                        <p className="text-xs font-bold text-slate-400 italic">
                            "Building better vision for humanity."
                        </p>
                        <div className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] text-center">
                            © 2025 GlaucoScan. D3 Teknologi Informasi • Proyek
                            Integrasi UAS.
                        </div>
                    </div>
                </div>
            </footer>

            <style>
                {`
          @keyframes fade-in { from { opacity: 0; } to { opacity: 1; } }
          @keyframes zoom-in { from { transform: scale(0.97); opacity: 0; } to { transform: scale(1); opacity: 1; } }
          @keyframes slide-in-bottom { from { transform: translateY(30px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
          @keyframes slide-in-right { from { transform: translateX(30px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
          @keyframes slide-in-left { from { transform: translateX(-30px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
          
          .animate-in { animation-fill-mode: forwards; }
          .fade-in { animation-name: fade-in; }
          .zoom-in { animation-name: zoom-in; }
          .slide-in-from-bottom-8 { animation-name: slide-in-bottom; }
          .slide-in-from-right-4 { animation-name: slide-in-right; }
          .slide-in-from-left-4 { animation-name: slide-in-left; }
          
          .duration-500 { animation-duration: 500ms; }
          .duration-700 { animation-duration: 700ms; }

          ::-webkit-scrollbar { width: 8px; }
          ::-webkit-scrollbar-track { background: #f8faff; }
          ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
          ::-webkit-scrollbar-thumb:hover { background: #1565C0; }
        `}
            </style>
        </div>
    );
}
