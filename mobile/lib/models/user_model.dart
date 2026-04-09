// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? phoneNumber;
  final String? address;

  // Data Medis (dari 'patient')
  final String? bloodType;
  final String? medicalHistory;
  final String? allergies;
  final String? insuranceName;
  final String? insurancePolicyNumber;

  // Data Pribadi Tambahan
  final String? nik;
  final String? username;
  final String? dateOfBirth;
  final String? gender;
  final String? city;
  final String? province;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phoneNumber,
    this.address,
    this.bloodType,
    this.medicalHistory,
    this.allergies,
    this.insuranceName,
    this.insurancePolicyNumber,
    this.nik,
    this.username,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.province,
  });

  // Jangan lupa update toJson dan fromJson jika perlu
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phoneNumber': phoneNumber,
      'address': address,
      'bloodType': bloodType,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'insuranceName': insuranceName,
      'insurancePolicyNumber': insurancePolicyNumber,
      'nik': nik,
      'username': username,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'city': city,
      'province': province,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      password: json['password'] ?? '',
      role: json['role'] == 'patient' ? 'pasien' : json['role'],
      phoneNumber: json['phone'] ?? json['phoneNumber'],
      address: json['address'],
      bloodType: json['bloodType'] ?? json['blood_type'],
      medicalHistory: json['medicalHistory'] ?? json['medical_history'],
      allergies: json['allergies'],
      insuranceName: json['insuranceName'] ?? json['insurance_provider'],
      insurancePolicyNumber: json['insurancePolicyNumber'] ?? json['insurance_number'],
      nik: json['nik'],
      username: json['username'],
      dateOfBirth: json['dateOfBirth'] ?? json['date_of_birth'],
      gender: json['gender'],
      city: json['city'],
      province: json['province'],
    );
  }
}