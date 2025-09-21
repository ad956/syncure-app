class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profileImage;
  final int age;
  final String bloodGroup;
  final double height;
  final double weight;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.age,
    required this.bloodGroup,
    required this.height,
    required this.weight,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profileImage'],
      age: json['age'],
      bloodGroup: json['bloodGroup'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
    );
  }
}