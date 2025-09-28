class User {
  final String id;
  final String name;
  final String email;
  final String? image;
  final String role;
  final String? phone;
  final int? age;
  final String? bloodGroup;
  final double? height;
  final double? weight;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    required this.role,
    this.phone,
    this.age,
    this.bloodGroup,
    this.height,
    this.weight,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
      role: json['role'] ?? 'patient',
      phone: json['phone'],
      age: json['age'],
      bloodGroup: json['bloodGroup'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
    );
  }

  // Getters for backward compatibility
  String get firstName => name.split(' ').first;
  String get lastName => name.split(' ').length > 1 ? name.split(' ').last : '';
  String? get profileImage => image;
}