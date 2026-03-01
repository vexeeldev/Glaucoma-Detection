class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role; // 'pasien' or 'dokter'
  final String? phoneNumber;
  final String? address;

  // Medical data
  final String? bloodType;
  final String? medicalHistory;
  final String? allergies;

  // Insurance data
  final String? insuranceName;
  final String? insurancePolicyNumber;

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
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      bloodType: json['bloodType'],
      medicalHistory: json['medicalHistory'],
      allergies: json['allergies'],
      insuranceName: json['insuranceName'],
      insurancePolicyNumber: json['insurancePolicyNumber'],
    );
  }
}

class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final String photoUrl;
  final String schedule;
  final int availableQuota;
  final bool isAvailable;
  final String? about;
  final int experience;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.photoUrl,
    required this.schedule,
    required this.availableQuota,
    required this.isAvailable,
    this.about,
    required this.experience,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'photoUrl': photoUrl,
      'schedule': schedule,
      'availableQuota': availableQuota,
      'isAvailable': isAvailable,
      'about': about,
      'experience': experience,
    };
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      photoUrl: json['photoUrl'],
      schedule: json['schedule'],
      availableQuota: json['availableQuota'],
      isAvailable: json['isAvailable'],
      about: json['about'],
      experience: json['experience'],
    );
  }
}