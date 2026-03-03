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
  final String? education;
  final String? hospital;
  final double? rating;
  final int? totalPatients;

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
    this.education,
    this.hospital,
    this.rating,
    this.totalPatients,
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
      'education': education,
      'hospital': hospital,
      'rating': rating,
      'totalPatients': totalPatients,
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
      education: json['education'],
      hospital: json['hospital'],
      rating: json['rating']?.toDouble(),
      totalPatients: json['totalPatients'],
    );
  }
}