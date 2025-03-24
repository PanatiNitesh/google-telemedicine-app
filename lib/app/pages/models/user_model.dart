class User {
  final String id;
  final String firstName;
  final String? lastName;
  final String email;
  final String? profileImage;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? address;
  final String? governmentId;
  final String? gender;

  User({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    this.profileImage,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.governmentId,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'],
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'],
      address: json['address'],
      governmentId: json['governmentId'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'governmentId': governmentId,
      'gender': gender,
    };
  }
}