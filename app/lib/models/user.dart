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
    String fullName = '';
    if (json['firstname'] != null && json['lastname'] != null) {
      fullName = '${json['firstname']} ${json['lastname']}';
    } else if (json['name'] != null) {
      fullName = json['name'];
    } else if (json['firstName'] != null && json['lastName'] != null) {
      fullName = '${json['firstName']} ${json['lastName']}';
    }
    
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: fullName,
      email: json['email'] ?? '',
      image: json['image'] ?? json['profileImage'],
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