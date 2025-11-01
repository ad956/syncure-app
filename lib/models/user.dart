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
      fullName = json['name'].toString();
    } else if (json['firstName'] != null && json['lastName'] != null) {
      fullName = '${json['firstName']} ${json['lastName']}';
    }
    
    return User(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: fullName.isNotEmpty ? fullName : 'User',
      email: (json['email'] ?? '').toString(),
      image: json['image']?.toString() ?? json['profileImage']?.toString(),
      role: (json['role'] ?? 'patient').toString(),
      phone: json['phone']?.toString(),
      age: json['age'] is int ? json['age'] : (json['age'] != null ? int.tryParse(json['age'].toString()) : null),
      bloodGroup: json['bloodGroup']?.toString(),
      height: json['height'] != null ? double.tryParse(json['height'].toString()) : null,
      weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
    );
  }

  // Getters for backward compatibility
  String get firstName => name.split(' ').first;
  String get lastName => name.split(' ').length > 1 ? name.split(' ').last : '';
  String? get profileImage => image;
}