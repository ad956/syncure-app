class Payment {
  final String id;
  final String hospitalName;
  final DateTime date;
  final double amount;
  final String disease;
  final String description;
  final String status;

  Payment({
    required this.id,
    required this.hospitalName,
    required this.date,
    required this.amount,
    required this.disease,
    required this.description,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['txnDocumentId'] ?? json['id'] ?? '',
      hospitalName: json['hospital']?['name'] ?? json['hospitalName'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      amount: (json['amount'] ?? 0).toDouble(),
      disease: json['disease'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Unknown',
    );
  }
}