import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'profiles';

  ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<ProfileModel?> getProfile(UserModel user) {
    return _firestore
        .collection(_collection)
        .doc(user.id)
        .snapshots()
        .map((doc) => doc.exists ? ProfileModel.fromFirestore(doc, user) : null);
  }

  Future<void> saveProfile(ProfileModel profile) async {
    await _firestore
        .collection(_collection)
        .doc(profile.id)
        .set(profile.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateProfilePhoto(String userId, String photoUrl) async {
    await _firestore.collection(_collection).doc(userId).update({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
} 