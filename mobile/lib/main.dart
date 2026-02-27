import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
// DESIGN SYSTEM (Medical Blue & White - WASG Principles)
// ─────────────────────────────────────────────────────────────
class K {
  static const primary     = Color(0xFF0052CC); // Biru Medis Profesional
  static const primarySoft = Color(0xFFE6F0FF);
  static const bg          = Color(0xFFFFFFFF);
  static const surface     = Color(0xFFF9FAFB);
  static const border      = Color(0xFFE5E7EB);
  static const txtDark     = Color(0xFF111827); 
  static const txtMid      = Color(0xFF4B5563);
  static const txtSoft     = Color(0xFF9CA3AF);
  static const error       = Color(0xFFDC2626);
}

// ─────────────────────────────────────────────────────────────
// SERVICES
// ─────────────────────────────────────────────────────────────
class AuthService {
  final _d = Dio(BaseOptions(
    baseUrl: 'http://YOUR_IP/api', 
    connectTimeout: const Duration(seconds: 15),
  ));

  Future<Map<String, dynamic>> login(String e, String p) async =>
      (await _d.post('/auth/login', data: {'email': e, 'password': p})).data;

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async =>
      (await _d.post('/auth/register', data: data)).data;
}

// ─────────────────────────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────────────────────────
class AuthCtrl extends GetxController {
  final svc = AuthService();
  
  final currentStep = 0.obs;
  final isLoading = false.obs;
  final errMsg = ''.obs;
  
  // Login
  final leC = TextEditingController();
  final lpC = TextEditingController();
  final showLP = false.obs;

  // Register Step 1 (Identitas)
  final rnC = TextEditingController(); // Nama
  final rnikC = TextEditingController(); // NIK
  final rplaceC = TextEditingController(); // Tempat Lahir
  final rdateC = TextEditingController(); // Tanggal Lahir
  final rgender = 'Laki-laki'.obs; // Jenis Kelamin
  final raddrC = TextEditingController(); // Alamat
  
  // Register Step 2 (Akun)
  final reC = TextEditingController();
  final rpC = TextEditingController();
  final rcC = TextEditingController();
  final showRP = false.obs;
  final showRC = false.obs;

  final loginKey = GlobalKey<FormState>();
  final regKey1 = GlobalKey<FormState>();
  final regKey2 = GlobalKey<FormState>();

  @override
  void onClose() {
    for (var c in [leC, lpC, rnC, rnikC, rplaceC, rdateC, raddrC, reC, rpC, rcC]) {
      c.dispose();
    }
    super.onClose();
  }

  // Fungsi untuk membersihkan error saat pindah layar
  void clearError() {
    errMsg.value = '';
  }

  void nextStep() {
    clearError(); // Bersihkan error setiap pindah step
    if (currentStep.value == 0 && (regKey1.currentState?.validate() ?? false)) {
      currentStep.value = 1;
    } else if (currentStep.value == 1 && (regKey2.currentState?.validate() ?? false)) {
      doRegister();
    }
  }

  void prevStep() {
    clearError();
    if (currentStep.value > 0) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  Future<void> doLogin() async {
    if (!(loginKey.currentState?.validate() ?? false)) return;
    isLoading(true); errMsg('');
    try {
      final r = await svc.login(leC.text.trim(), lpC.text);
      if (r['success'] == true) {
        clearError();
        Get.offAllNamed('/home-patient');
      } else {
        errMsg(r['message'] ?? 'Email atau password salah');
      }
    } catch (e) {
      errMsg('Gagal terhubung ke server rumah sakit.');
    } finally { isLoading(false); }
  }

  Future<void> doRegister() async {
    isLoading(true); errMsg('');
    try {
      final data = {
        'name': rnC.text.trim(),
        'nik': rnikC.text.trim(),
        'pob': rplaceC.text.trim(),
        'dob': rdateC.text.trim(),
        'gender': rgender.value,
        'address': raddrC.text.trim(),
        'email': reC.text.trim(),
        'password': rpC.text,
        'password_confirmation': rcC.text,
      };
      final r = await svc.register(data);
      if (r['success'] == true) {
        clearError();
        currentStep.value = 2;
      } else {
        errMsg(r['message'] ?? 'Pendaftaran gagal');
      }
    } catch (e) {
      errMsg('Terjadi kesalahan pada sistem pendaftaran.');
    } finally { isLoading(false); }
  }

  Future<void> pickDate(BuildContext ctx) async {
    final d = await showDatePicker(
      context: ctx,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: K.primary),
          ),
          child: child!,
        );
      },
    );
    if (d != null) {
      rdateC.text = "${d.day}-${d.month}-${d.year}";
    }
  }
}

// ─────────────────────────────────────────────────────────────
// MAIN APP
// ─────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext ctx) => GetMaterialApp(
    title: 'GlaucoScan',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: K.bg,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    ),
    initialRoute: '/login',
    getPages: [
      GetPage(name: '/login', page: () => const LoginScreen()),
      GetPage(name: '/register', page: () => const RegisterScreen()),
      GetPage(name: '/home-patient', page: () => const Scaffold(body: Center(child: Text("Portal Utama Pasien")))),
    ],
  );
}

// ─────────────────────────────────────────────────────────────
// LOGIN SCREEN
// ─────────────────────────────────────────────────────────────
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext ctx) {
    final c = Get.put(AuthCtrl());
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: c.loginKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.medical_services_rounded, size: 80, color: K.primary),
                  const SizedBox(height: 20),
                  Text('LOGIN', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, color: K.txtDark, letterSpacing: 4)),
                  const SizedBox(height: 4),
                  Text('Portal Kesehatan GlaucoScan', style: TextStyle(color: K.txtSoft, fontSize: 13)),
                  const SizedBox(height: 40),

                  _AppField(ctrl: c.leC, label: 'Alamat Email', hint: 'nama@email.com', icon: Icons.mail_outline_rounded, kb: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  Obx(() => _AppField(
                    ctrl: c.lpC, label: 'Kata Sandi', hint: '••••••••', icon: Icons.lock_outline_rounded,
                    obscure: !c.showLP.value,
                    suffix: IconButton(icon: Icon(c.showLP.value ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 20), onPressed: c.showLP.toggle),
                  )),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () {}, child: const Text('Lupa Kata Sandi?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: K.primary))),
                  ),
                  
                  const SizedBox(height: 24),
                  Obx(() => _AppErr(msg: c.errMsg.value)),
                  Obx(() => _AppBtn(label: 'MASUK', fn: c.doLogin, loading: c.isLoading.value)),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum terdaftar? ', style: TextStyle(color: K.txtMid, fontSize: 13)),
                      GestureDetector(
                        onTap: () {
                          c.clearError(); // Bersihkan error saat pindah ke register
                          Get.toNamed('/register');
                        },
                        child: const Text('Daftar Sekarang', style: TextStyle(color: K.primary, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// REGISTER SCREEN
// ─────────────────────────────────────────────────────────────
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext ctx) {
    final c = Get.find<AuthCtrl>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        title: Text('REGISTER PASIEN', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: K.txtDark, letterSpacing: 1.5)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: K.txtDark, size: 18), onPressed: c.prevStep)
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progres Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 16),
              child: Row(children: [
                _AppStep(num: '1', active: c.currentStep.value >= 0, label: 'Identitas'),
                _AppLine(active: c.currentStep.value >= 1),
                _AppStep(num: '2', active: c.currentStep.value >= 1, label: 'Akun'),
                _AppLine(active: c.currentStep.value >= 2),
                _AppStep(num: '3', active: c.currentStep.value >= 2, label: 'Konfirmasi'),
              ]),
            ),
            
            Expanded(
              child: Obx(() => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24), 
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Menurunkan konten agar lebih seimbang (WASG: Balance)
                    const SizedBox(height: 24), 
                    if (c.currentStep.value == 0) _StepIdentitas(c),
                    if (c.currentStep.value == 1) _StepAkun(c),
                    if (c.currentStep.value == 2) _StepFinish(),
                    
                    const SizedBox(height: 32),
                    if (c.currentStep.value < 2) ...[
                      Obx(() => _AppBtn(
                        label: c.currentStep.value == 1 ? 'DAFTAR SEKARANG' : 'LANJUTKAN', 
                        fn: c.nextStep, 
                        loading: c.isLoading.value
                      )),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// REGISTER STEPS
// ─────────────────────────────────────────────────────────────
class _StepIdentitas extends StatelessWidget {
  final AuthCtrl c;
  const _StepIdentitas(this.c);
  @override
  Widget build(BuildContext ctx) => Form(
    key: c.regKey1,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _AppField(ctrl: c.rnC, label: 'Nama Lengkap Pasien', hint: 'Sesuai KTP/KIA', icon: Icons.person_outline_rounded),
      const SizedBox(height: 16),
      _AppField(ctrl: c.rnikC, label: 'Nomor Induk Kependudukan (NIK)', hint: '16 digit NIK', icon: Icons.badge_outlined, kb: TextInputType.number),
      const SizedBox(height: 16),
      
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _AppField(ctrl: c.rplaceC, label: 'Tempat Lahir', hint: 'Kota/Kab', icon: Icons.location_city_rounded)),
        const SizedBox(width: 12),
        Expanded(child: GestureDetector(
          onTap: () => c.pickDate(ctx),
          child: AbsorbPointer(
            child: _AppField(ctrl: c.rdateC, label: 'Tanggal Lahir', hint: 'DD-MM-YYYY', icon: Icons.calendar_today_rounded),
          ),
        )),
      ]),
      const SizedBox(height: 16),

      Text('JENIS KELAMIN', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: K.txtMid, letterSpacing: 1.5)),
      const SizedBox(height: 8),
      Obx(() => Row(children: [
        _GenderOpt(label: 'Laki-laki', val: 'Laki-laki', group: c.rgender.value, onTap: (v) => c.rgender.value = v),
        const SizedBox(width: 12),
        _GenderOpt(label: 'Perempuan', val: 'Perempuan', group: c.rgender.value, onTap: (v) => c.rgender.value = v),
      ])),
      const SizedBox(height: 16),
      
      _AppField(ctrl: c.raddrC, label: 'Alamat Domisili Lengkap', hint: 'Nama jalan, No. Rumah, RT/RW, dsb.', icon: Icons.map_outlined, lines: 3),
    ]),
  );
}

class _StepAkun extends StatelessWidget {
  final AuthCtrl c;
  const _StepAkun(this.c);
  @override
  Widget build(BuildContext ctx) => Form(
    key: c.regKey2,
    child: Column(children: [
      _AppField(ctrl: c.reC, label: 'Email Aktif', hint: 'nama@email.com', icon: Icons.mail_outline_rounded, kb: TextInputType.emailAddress),
      const SizedBox(height: 16),
      Obx(() => _AppField(
        ctrl: c.rpC, label: 'Kata Sandi', hint: 'Minimal 8 karakter', icon: Icons.lock_outline_rounded,
        obscure: !c.showRP.value,
        suffix: IconButton(icon: Icon(c.showRP.value ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 20), onPressed: c.showRP.toggle),
      )),
      const SizedBox(height: 16),
      Obx(() => _AppField(
        ctrl: c.rcC, label: 'Konfirmasi Kata Sandi', hint: 'Ulangi kata sandi', icon: Icons.verified_user_outlined,
        obscure: !c.showRC.value,
        suffix: IconButton(icon: Icon(c.showRC.value ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 20), onPressed: c.showRC.toggle),
      )),
      const SizedBox(height: 24),
      Obx(() => _AppErr(msg: c.errMsg.value)),
    ]),
  );
}

class _StepFinish extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => Column(children: [
    const SizedBox(height: 32),
    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 90),
    const SizedBox(height: 20),
    Text('Registrasi Berhasil', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: K.txtDark)),
    const SizedBox(height: 12),
    Text('Data pasien telah berhasil disimpan. Silakan masuk kembali untuk memulai pemeriksaan mata Anda.', textAlign: TextAlign.center, style: TextStyle(color: K.txtMid, fontSize: 14, height: 1.5)),
    const SizedBox(height: 40),
    _AppBtn(label: 'KEMBALI KE LOGIN', fn: () => Get.offAllNamed('/login')),
    const SizedBox(height: 24),
  ]);
}

// ─────────────────────────────────────────────────────────────
// COMPONENTS
// ─────────────────────────────────────────────────────────────
class _AppField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType kb;
  final int lines;

  const _AppField({required this.ctrl, required this.label, required this.hint, required this.icon, this.obscure = false, this.suffix, this.kb = TextInputType.text, this.lines = 1});

  @override
  Widget build(BuildContext ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Text(label.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: K.txtMid, letterSpacing: 1.2)),
    ),
    TextFormField(
      controller: ctrl, obscureText: obscure, keyboardType: kb, maxLines: lines,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: K.txtDark),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: K.txtSoft, fontSize: 13),
        prefixIcon: Icon(icon, color: K.primary, size: 18),
        suffixIcon: suffix,
        filled: true, fillColor: K.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: K.border, width: 1.2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: K.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: K.error)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Data wajib diisi' : null,
    ),
  ]);
}

class _AppBtn extends StatelessWidget {
  final String label; final VoidCallback fn; final bool loading;
  const _AppBtn({required this.label, required this.fn, this.loading = false});

  @override
  Widget build(BuildContext ctx) => SizedBox(
    width: double.infinity, height: 58,
    child: ElevatedButton(
      onPressed: loading ? null : fn,
      style: ElevatedButton.styleFrom(backgroundColor: K.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
      child: loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
    ),
  );
}

class _GenderOpt extends StatelessWidget {
  final String label, val, group; final Function(String) onTap;
  const _GenderOpt({required this.label, required this.val, required this.group, required this.onTap});
  @override
  Widget build(BuildContext ctx) => Expanded(
    child: GestureDetector(
      onTap: () => onTap(val),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: group == val ? K.primarySoft : K.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: group == val ? K.primary : K.border, width: 1.5)
        ),
        child: Center(child: Text(label, style: TextStyle(color: group == val ? K.primary : K.txtMid, fontWeight: FontWeight.bold, fontSize: 13))),
      ),
    ),
  );
}

class _AppStep extends StatelessWidget {
  final String num, label; final bool active;
  const _AppStep({required this.num, required this.active, required this.label});
  @override
  Widget build(BuildContext ctx) => Column(children: [
    AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: active ? K.primary : K.surface,
        shape: BoxShape.circle,
        border: Border.all(color: active ? K.primary : K.border, width: 2)
      ),
      child: Center(child: Text(num, style: TextStyle(color: active ? Colors.white : K.txtSoft, fontSize: 11, fontWeight: FontWeight.bold))),
    ),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(fontSize: 9, color: active ? K.primary : K.txtSoft, fontWeight: FontWeight.bold)),
  ]);
}

class _AppLine extends StatelessWidget {
  final bool active; const _AppLine({required this.active});
  @override
  Widget build(BuildContext ctx) => Expanded(child: AnimatedContainer(duration: const Duration(milliseconds: 300), height: 2, margin: const EdgeInsets.only(left: 6, right: 6, bottom: 14), color: active ? K.primary : K.border));
}

class _AppErr extends StatelessWidget {
  final String msg; const _AppErr({required this.msg});
  @override
  Widget build(BuildContext ctx) => msg.isEmpty ? const SizedBox.shrink() : Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: K.error.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: K.error.withOpacity(0.2))), child: Row(children: [const Icon(Icons.error_outline_rounded, color: K.error, size: 18), const SizedBox(width: 10), Expanded(child: Text(msg, style: const TextStyle(color: K.error, fontSize: 12, fontWeight: FontWeight.w600)))]));
}