class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? phoneNumber;
  final String? address;

  // Data Medis
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
  final String? religion;
  final String? nationality;

  // Field Tambahan
  final String? postalCode;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final String? currentMedications;
  final String? insuranceProvider;
  final String? insuranceNumber;

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
    this.religion,
    this.nationality,
    this.postalCode,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.currentMedications,
    this.insuranceProvider,
    this.insuranceNumber,
  });

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
      'religion': religion,
      'nationality': nationality,
      'postalCode': postalCode,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'emergencyContactRelation': emergencyContactRelation,
      'currentMedications': currentMedications,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] == 'patient' ? 'pasien' : (json['role'] ?? 'pasien'),
      phoneNumber: json['phone'] ?? json['phoneNumber'],
      address: json['address'],
      bloodType: json['bloodType'] ?? json['blood_type'],
      medicalHistory: json['medicalHistory'] ?? json['medical_history'],
      allergies: json['allergies'],
      insuranceName: json['insuranceName'] ?? json['insurance_name'],
      insurancePolicyNumber: json['insurancePolicyNumber'] ?? json['insurance_policy_number'],
      nik: json['nik'],
      username: json['username'],
      dateOfBirth: json['dateOfBirth'] ?? json['date_of_birth'],
      gender: json['gender'],
      city: json['city'],
      province: json['province'],
      religion: json['religion'],
      nationality: json['nationality'],
      postalCode: json['postalCode'] ?? json['postal_code'],
      emergencyContactName: json['emergencyContactName'] ?? json['emergency_contact_name'],
      emergencyContactPhone: json['emergencyContactPhone'] ?? json['emergency_contact_phone'],
      emergencyContactRelation: json['emergencyContactRelation'] ?? json['emergency_contact_relation'],
      currentMedications: json['currentMedications'] ?? json['current_medications'],
      insuranceProvider: json['insuranceProvider'] ?? json['insurance_provider'],
      insuranceNumber: json['insuranceNumber'] ?? json['insurance_number'],
    );
  }
}