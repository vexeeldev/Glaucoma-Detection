class Constants {
  static const String appName = 'EyeCare';
  static const String appTagline = 'Smart Glaucoma Detection';

  // Shared Preferences Keys
  static const String prefUser = 'user';
  static const String prefIsLoggedIn = 'isLoggedIn';

  // Status
  static const String statusPending = 'pending';
  static const String statusPaid = 'paid';
  static const String statusConfirmed = 'confirmed';
  static const String statusRejected = 'rejected';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Notification Types
  static const String notifAppointmentConfirmed = 'appointment_confirmed';
  static const String notifAppointmentRejected = 'appointment_rejected';
  static const String notifPaymentSuccess = 'payment_success';
  static const String notifExaminationReady = 'examination_ready';
  static const String notifNewAppointment = 'new_appointment';
  static const String notifMLProcessed = 'ml_processed';

  // Payment Methods
  static const List<String> paymentMethods = [
    'Transfer Bank',
    'E-Wallet',
  ];

  // Time Slots
  static const List<String> timeSlots = [
    '09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00',
  ];
}