import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Save user profile data
  Future<void> saveUserProfile({
    required String userId,
    required String username,
    File? profileImage,
  }) async {
    try {
      // Save username to shared preferences for quick access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);

      // If there's a profile image, upload it to Firebase Storage
      if (profileImage != null) {
        final ref = _storage.ref().child('user_profiles/$userId/profile.jpg');
        await ref.putFile(profileImage);
        
        // Save the download URL to shared preferences
        final imageUrl = await ref.getDownloadURL();
        await prefs.setString('profile_image_url', imageUrl);
      }
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Get current user's username
  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'User';
  }

  // Get current user's profile image URL
  Future<String?> getProfileImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_url');
  }

  // Update username
  Future<void> updateUsername(String newUsername) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
    
    // Here you would typically update the username in your database
    // For example, if using Firestore:
    // await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
    //   'username': newUsername,
    //   'updatedAt': FieldValue.serverTimestamp(),
    // });
  }

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    
    try {
      final ref = _storage.ref().child('user_profiles/${user.uid}/profile.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      // Save the download URL to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_url', downloadUrl);
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Clear user data on sign out
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('profile_image_url');
  }
}
