import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../services/user_service.dart';
import 'signin_screen.dart';
import 'recentlydeleted_screen.dart';
class ProfileScreen extends StatefulWidget {
  final VoidCallback onReloadHistory;

  const ProfileScreen({super.key, required this.onReloadHistory});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _picker = ImagePicker();

  late TextEditingController _usernameController;
  File? _profileImage;
  String? _profileImageUrl;
  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: 'User');
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _openRecentlyDeleted() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecentlyDeletedScreen()),
    );

    widget.onReloadHistory();
  }

  Future<void> _loadUserData() async {
    try {
      final username = await _userService.getUsername();
      final imageUrl = await _userService.getProfileImageUrl();

      if (mounted) {
        setState(() {
          _usernameController.text = username;
          _profileImageUrl = imageUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedImage == null) return;

      if (!mounted) return;

      setState(() => _isLoading = true);


          final imageFile = File(pickedImage.path);
          final imageUrl = await _userService.uploadProfileImage(imageFile);
 
          if (mounted) {
            setState(() {
              _profileImage = imageFile;
              _profileImageUrl = imageUrl;
            });
            ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    }catch (e) {
          if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
  }
          
        
  Future<void> _toggleEdit() async {
    if (_isEditing) {
      if (_formKey.currentState?.validate() ?? false) {
        try {
          setState(() => _isLoading = true);
          await _userService.updateUsername(_usernameController.text);

          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update profile: $e')),
            );
          }
        }
      } else {
        return;
      }
    }

    if (mounted) {
      setState(() => _isEditing = !_isEditing);
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _policyBullet('Skin images are used solely for diagnostic purposes and are not shared with any third party.'),
              _policyBullet('The AI Large Language Model (LLM) cannot access your uploaded images.'),
              _policyBullet('All data storage is handled locally on your mobile device; no external storage is utilized.'),
              _policyBullet('You retain the right to delete your data or history permanently at any time.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF2E8BC0))),
          ),
        ],
      ),
    );
  }

  Widget _policyBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Derma Scan App', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A powerful skin analysis app that helps you understand your skin condition using AI technology. '
              'Get instant analysis and recommendations for better skin care.',
            ),
            SizedBox(height: 16),
            Text(
              '© 2025 Derma Scan App',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF2E8BC0))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E8BC0),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    border: Border.all(
                      color: const Color(0xFFE2F0F6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(
                            _profileImage!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                          )
                        : _profileImageUrl != null
                        ? Image.network(
                            _profileImageUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: const Color(0xFF2E8BC0),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E8BC0),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _pickImage,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF2E8BC0),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // User Info
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF2E8BC0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    initialValue: user?.email,
                    enabled: false, // Email is not editable
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF2E8BC0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF2E8BC0)),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showPrivacyPolicy,
              ),
            ),
            const SizedBox(height: 12),
            // About Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF2E8BC0),
                ),
                title: const Text('About'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showAboutDialog,
              ),
            ),
            const SizedBox(height: 15),

            // --- RECENTLY DELETED SCANS (HIVE INTEGRATION) ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.restore_from_trash,
                  color: Color(0xFFE63946),
                ),
                title: const Text('Recently Deleted Scans'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _openRecentlyDeleted,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _userService.clearUserData();
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to sign out: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE63946),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 3. NEW DELETED SCAN CARD WIDGET (For consistent UI)
// =========================================================================

