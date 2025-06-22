import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class ProfileModel extends UserModel {
  final String? phoneNumber;
  final String? occupation;
  final double? monthlyIncome;
  final String? currency;
  final DateTime? dateOfBirth;
  final DateTime updatedAt;

  ProfileModel({
    required super.id,
    required super.email,
    required super.name,
    super.photoUrl,
    required super.createdAt,
    this.phoneNumber,
    this.occupation,
    this.monthlyIncome,
    this.currency,
    this.dateOfBirth,
    required this.updatedAt,
  });

  factory ProfileModel.fromFirestore(DocumentSnapshot doc, UserModel user) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileModel(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      phoneNumber: data['phoneNumber'] as String?,
      occupation: data['occupation'] as String?,
      monthlyIncome: (data['monthlyIncome'] as num?)?.toDouble(),
      currency: data['currency'] as String?,
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'occupation': occupation,
      'monthlyIncome': monthlyIncome,
      'currency': currency,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ProfileModel copyWith({
    String? name,
    String? photoUrl,
    String? phoneNumber,
    String? occupation,
    double? monthlyIncome,
    String? currency,
    DateTime? dateOfBirth,
  }) {
    return ProfileModel(
      id: id,
      email: email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      occupation: occupation ?? this.occupation,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currency: currency ?? this.currency,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      updatedAt: DateTime.now(),
    );
  }
} 