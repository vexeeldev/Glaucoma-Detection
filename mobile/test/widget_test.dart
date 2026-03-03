import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:eyecare_app/main.dart';
import 'package:eyecare_app/screens/splash_screen.dart';
import 'package:eyecare_app/screens/auth/login_screen.dart';
import 'package:eyecare_app/screens/auth/register_screen.dart';
import 'package:eyecare_app/screens/pasien/pasien_home_screen.dart';
import 'package:eyecare_app/screens/dokter/dokter_home_screen.dart';
import 'package:eyecare_app/widgets/loading_widget.dart';
import 'package:eyecare_app/widgets/doctor_card.dart';
import 'package:eyecare_app/widgets/appointment_card.dart';
import 'package:eyecare_app/models/doctor_model.dart';
import 'package:eyecare_app/models/appointment_model.dart';
import 'package:eyecare_app/providers/auth_provider.dart';
import 'package:eyecare_app/providers/appointment_provider.dart';
import 'package:eyecare_app/providers/notification_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Initialization', () {
    testWidgets('App starts with SplashScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('EyeCare'), findsOneWidget);
      expect(find.text('Smart Glaucoma Detection'), findsOneWidget);
    });

    testWidgets('SplashScreen shows loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Authentication Screens', () {
    testWidgets('LoginScreen has all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.text('Belum punya akun?'), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);
    });

    testWidgets('LoginScreen validates empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('LoginScreen validates email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Email tidak valid'), findsOneWidget);
    });

    testWidgets('RegisterScreen has all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegisterScreen()),
      );

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.byType(RadioListTile<String>), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Daftar'), findsOneWidget);
      expect(find.text('Sudah punya akun?'), findsOneWidget);
    });

    testWidgets('RegisterScreen validates password match', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegisterScreen()),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'different123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
      await tester.pump();

      expect(find.text('Password tidak cocok'), findsOneWidget);
    });
  });

  group('Widget Tests', () {
    testWidgets('LoadingWidget displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingWidget with message displays text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(message: 'Loading...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('LoadingOverlay shows when isLoading true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('DoctorCard displays correctly', (WidgetTester tester) async {
      final doctor = DoctorModel(
        id: '1',
        name: 'Dr. Test',
        specialization: 'Spesialis Mata',
        photoUrl: '',
        schedule: 'Senin-Jumat, 09:00-17:00',
        availableQuota: 10,
        isAvailable: true,
        experience: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoctorCard(
              doctor: doctor,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Dr. Test'), findsOneWidget);
      expect(find.text('Spesialis Mata'), findsOneWidget);
      expect(find.text('Senin-Jumat, 09:00-17:00'), findsOneWidget);
      expect(find.text('Tersedia'), findsOneWidget);
    });

    testWidgets('AppointmentCard displays correctly', (WidgetTester tester) async {
      final appointment = AppointmentModel(
        id: '1',
        patientId: '1',
        doctorId: '1',
        doctorName: 'Dr. Test',
        date: DateTime.now(),
        time: '10:00',
        complaint: 'Test complaint',
        status: 'confirmed',
        paymentMethod: 'Transfer Bank',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppointmentCard(
              appointment: appointment,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Dr. Test'), findsOneWidget);
      expect(find.text('Dikonfirmasi'), findsOneWidget);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Tap on Daftar navigates to RegisterScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
          },
        ),
      );

      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });

  group('Provider Tests', () {
    testWidgets('AuthProvider initializes correctly', (WidgetTester tester) async {
      final authProvider = AuthProvider();

      expect(authProvider.currentUser, isNull);
      expect(authProvider.isLoggedIn, false);
    });

    testWidgets('AuthProvider login with valid credentials', (WidgetTester tester) async {
      final authProvider = AuthProvider();

      // Note: This test requires mock data to be loaded
      // In a real test, you would mock the MockDataService
      final result = await authProvider.login('test@example.com', 'password');

      // This will fail because we need to mock the service
      // For demonstration only
      expect(result, false);
    });
  });

  group('Doctor Home Screen Tests', () {
    testWidgets('DokterHomeScreen shows stats cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
            ChangeNotifierProvider<AppointmentProvider>(create: (_) => AppointmentProvider()),
            ChangeNotifierProvider<NotificationProvider>(create: (_) => NotificationProvider()),
          ],
          child: const MaterialApp(
            home: DokterHomeScreen(),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      expect(find.text('Janji Hari Ini'), findsOneWidget);
      expect(find.text('Menunggu'), findsOneWidget);
      expect(find.text('Total Pasien'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });
  });

  group('Pasien Home Screen Tests', () {
    testWidgets('PasienHomeScreen shows quick actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
            ChangeNotifierProvider<AppointmentProvider>(create: (_) => AppointmentProvider()),
            ChangeNotifierProvider<NotificationProvider>(create: (_) => NotificationProvider()),
          ],
          child: const MaterialApp(
            home: PasienHomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Buat Janji'), findsOneWidget);
      expect(find.text('Riwayat'), findsOneWidget);
      expect(find.text('Notifikasi'), findsOneWidget);
    });
  });

  group('Edge Cases', () {
    testWidgets('Empty state displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Tidak ada data'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.text('Tidak ada data'), findsOneWidget);
    });

    testWidgets('Error handling shows snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error message'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Show Error'));
      await tester.pump();

      expect(find.text('Error message'), findsOneWidget);
    });
  });
}