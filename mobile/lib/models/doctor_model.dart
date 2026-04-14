class DoctorModel {
  final int id;
  final String name;
  final String specialization;
  final String? experience;
  final String? consultationFee;
  final bool isAvailable;
  final String? profilePhoto;
  final String? email;
  final String? biography;
  final List<Schedule>? schedules;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    this.experience,
    this.consultationFee,
    required this.isAvailable,
    this.profilePhoto,
    this.email,
    this.biography,
    this.schedules,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    // Handle schedules
    List<Schedule>? schedules;
    if (json['schedules'] != null) {
      schedules = (json['schedules'] as List)
          .map((e) => Schedule.fromJson(e))
          .toList();
    }

    return DoctorModel(
      id: json['id'],
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      experience: json['experience'],
      consultationFee: json['consultation_fee'],
      isAvailable: json['is_available'] ?? false,
      profilePhoto: json['profile_photo'],
      email: json['email'],
      biography: json['biography'],
      schedules: schedules,
    );
  }
}

class Schedule {
  final int id;
  final int doctorId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int maxPatients;

  Schedule({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.maxPatients,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      doctorId: json['doctor_id'],
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isAvailable: json['is_available'] ?? false,
      maxPatients: json['max_patients'] ?? 0,
    );
  }

  String get dayName {
    switch (dayOfWeek.toLowerCase()) {
      case 'monday':
        return 'Senin';
      case 'tuesday':
        return 'Selasa';
      case 'wednesday':
        return 'Rabu';
      case 'thursday':
        return 'Kamis';
      case 'friday':
        return 'Jumat';
      case 'saturday':
        return 'Sabtu';
      case 'sunday':
        return 'Minggu';
      default:
        return dayOfWeek;
    }
  }

  String get timeRange => '$startTime - $endTime';
}