class Appointment {
  final String id;
  final String hospitalName;
  final String doctorName;
  final DateTime date;
  final String status;
  final String disease;

  Appointment({
    required this.id,
    required this.hospitalName,
    required this.doctorName,
    required this.date,
    required this.status,
    required this.disease,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      hospitalName: json['hospitalName'],
      doctorName: json['doctorName'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      disease: json['disease'],
    );
  }
}