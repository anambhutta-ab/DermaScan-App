import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

  String? _emailError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    setState(() {
      _emailError = email.isEmpty ? "Enter your email" : null;
    });

    if (_emailError != null) return;

    setState(() => _isLoading = true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset link sent! Check your email."),
          backgroundColor: Color(0xFF2E8BC0), // Primary blue
        ),
      );

      Navigator.pop(context); // go back to sign-in
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() => _emailError = "No user found with this email.");
      } else if (e.code == 'invalid-email') {
        setState(() => _emailError = "Invalid email format.");
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E8BC0), Color(0xFF0C4160)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: const Color(0xFFF8FAFC), // Light background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_reset,
                      size: 70,
                      color: Color(0xFF2E8BC0),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("Enter your email to reset your password"),
                    const SizedBox(height: 25),

                    // Email TextField
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFB1D4E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFB1D4E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF2E8BC0),
                            width: 2.0,
                          ),
                        ),
                        errorText: _emailError,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                    ),

                    const SizedBox(height: 25),

                    // Send Reset Link Button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _sendResetEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF2E8BC0,
                                ), // Primary blue
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Send Reset Link",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),

                    const SizedBox(height: 15),

                    // Back to Sign In
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Back to Sign In",
                        style: TextStyle(
                          color: Color(0xFF2E8BC0), // Primary blue
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
