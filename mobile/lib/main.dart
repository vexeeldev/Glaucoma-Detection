import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/notification_provider.dart';
import 'package:device_preview/device_preview.dart';
import 'providers/doctor_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true, // Aktifkan Device Preview
      builder: (context) => const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
      ],
      child: MaterialApp(
        title: 'EyeCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(), // Langsung ke SplashScreen
      ),
    );
  }
}