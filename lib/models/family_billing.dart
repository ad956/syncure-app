class FamilyMember {
  final String id;
  final String name;
  final String relationship;
  final String dateOfBirth;
  final String gender;
  final String? photo;
  final String? contact;
  final String? email;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    required this.dateOfBirth,
    required this.gender,
    this.photo,
    this.contact,
    this.email,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      photo: json['photo'],
      contact: json['contact'],
      email: json['email'],
    );
  }
}

class PendingBill {
  final String id;
  final String hospitalName;
  final String hospitalLogo;
  final double amount;
  final String billDate;
  final String dueDate;
  final String status;
  final String description;
  final String? appointmentId;

  PendingBill({
    required this.id,
    required this.hospitalName,
    required this.hospitalLogo,
    required this.amount,
    required this.billDate,
    required this.dueDate,
    required this.status,
    required this.description,
    this.appointmentId,
  });

  factory PendingBill.fromJson(Map<String, dynamic> json) {
    return PendingBill(
      id: json['id'] ?? '',
      hospitalName: json['hospital_name'] ?? '',
      hospitalLogo: json['hospital_logo'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      billDate: json['bill_date'] ?? '',
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? 'pending',
      description: json['description'] ?? '',
      appointmentId: json['appointment_id'],
    );
  }
}

class PaymentHistory {
  final String id;
  final String transactionId;
  final String hospitalName;
  final double amount;
  final String paymentDate;
  final String status;
  final String paymentMethod;
  final String description;

  PaymentHistory({
    required this.id,
    required this.transactionId,
    required this.hospitalName,
    required this.amount,
    required this.paymentDate,
    required this.status,
    required this.paymentMethod,
    required this.description,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      hospitalName: json['hospital_name'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentDate: json['payment_date'] ?? '',
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      description: json['description'] ?? '',
    );
  }
}