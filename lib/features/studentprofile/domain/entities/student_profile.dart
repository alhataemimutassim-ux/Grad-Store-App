class StudentProfile {
  final int idUser;
  final String? name;
  final String? email;
  final String? phone;
  final String? major;
  final String? university;

  StudentProfile({
    required this.idUser,
    this.name,
    this.email,
    this.phone,
    this.major,
    this.university,
  });
}
