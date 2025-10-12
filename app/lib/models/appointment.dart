class Appointment {
  final String id;
  final String hospitalName;
  final String doctorName;
  final DateTime date;
  final String status;
  final String disease;
  final String? timing;
  final String? doctorSpecialty;
  final String? notes;

  Appointment({
    required this.id,
    required this.hospitalName,
    required this.doctorName,
    required this.date,
    required this.status,
    required this.disease,
    this.timing,
    this.doctorSpecialty,
    this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] ?? json['id'],
      hospitalName: json['hospital']?['name'] ?? json['hospitalName'],
      doctorName: json['doctor']?['name'] ?? json['doctorName'],
      date: DateTime.parse(json['date']),
      status: json['approved'] ?? json['status'],
      disease: json['disease'],
      timing: json['timing'],
      doctorSpecialty: json['doctor']?['specialty'],
      notes: json['note'] ?? json['notes'],
    );
  }
}