class User {
  final String id;
  final String firstName;
  final String? lastName;
  final String? email;
  final String? profileImage;
  
  User({
    required this.id,
    required this.firstName,
    this.lastName,
    this.email,
    this.profileImage,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      profileImage: json['profileImage'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImage': profileImage,
    };
  }
}