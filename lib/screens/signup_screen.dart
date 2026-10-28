import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import 'signin_screen.dart';
import 'disclaimer_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _usernameError;
  String _passwordStrength = "";
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  bool _isValidUsername(String username) {
    // Only allow alphanumeric characters, underscores, and hyphens
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]{3,20}$');
    return usernameRegex.hasMatch(username);
  }

  bool _isValidEmail(String email) {
    // Basic format check
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  String _getPasswordStrength(String password) {
    if (password.isEmpty) return "";
    int score = 0;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'\d'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    if (password.length >= 8) score++;
    if (score <= 2) return "Weak";
    if (score == 3 || score == 4) return "Medium";
    return "Strong";
  }

  Color _getStrengthColor(String s) {
    switch (s) {
      case "Weak":
        return const Color(0xFFE63946); // Error red
      case "Medium":
        return const Color(0xFFFFA500); // Orange
      case "Strong":
        return const Color(0xFF2E8BC0); // Primary blue
      default:
        return Colors.transparent;
    }
  }

  void _showPasswordRules() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Password Requirements"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• At least one uppercase letter"),
            Text("• At least one special character"),
            Text("• At least one numeric digit"),
            Text("• Minimum 8 characters recommended"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  final UserService _userService = UserService();

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;
    final username = _usernameController.text.trim();

    // --- 1. Initial Emptiness Check ---
    setState(() {
      _emailError = email.isEmpty ? "Enter your email" : null;
      _passwordError = password.isEmpty ? "Enter a password" : null;
      _confirmError = confirmPassword.isEmpty ? "Confirm your password" : null;
      _usernameError = username.isEmpty
          ? "Enter a username"
          : username.length < 3
          ? "Username must be at least 3 characters"
          : null;
    });

    if (_emailError != null ||
        _passwordError != null ||
        _confirmError != null ||
        _usernameError != null) {
      return;
    }

    // --- 2. FORMAT VALIDATION (The Fix) ---
    if (!_isValidEmail(email)) {
      setState(() {
        _emailError = "Please enter a valid email address";
      });
      return;
    }
    // ------------------------------------

    // Additional username validation
    if (!_isValidUsername(username)) {
      setState(() {
        _usernameError =
            "Username can only contain letters, numbers, underscores, and hyphens (3-20 characters)";
      });
      return;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      setState(() {
        _confirmError = "Passwords don't match";
      });
      return;
    }

    // Original check on line 148 removed as it is now covered by step 2.

    if (mounted) setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user profile data
      await _userService.saveUserProfile(
        userId: userCredential.user!.uid,
        username: _usernameController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DisclaimerScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _emailError = "This email is already registered.";
        } else if (e.code == 'invalid-email') {
          // This will only catch extreme edge cases, as the front-end check should catch most.
          _emailError = "Invalid email format.";
        } else if (e.code == 'weak-password') {
          _passwordError = "Password is too weak.";
        } else {
          // fallback: show error as SnackBar
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Signup error: ${e.message}")));
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  PageRouteBuilder _routeToSignIn() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => const SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetTween = Tween(
          begin: const Offset(-0.2, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(offsetTween),
            child: child,
          ),
        );
      },
    );
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
                      Icons.medical_services,
                      size: 70,
                      color: Color(0xFF2E8BC0), // Primary blue
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("AI Skin Disease Screening Tool"),
                    const SizedBox(height: 25),

                    // Username Field
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: _usernameError,
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
                        hintText: 'Choose a username',
                      ),
                      onChanged: (_) {
                        setState(() {
                          _usernameError = null;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        errorText: _emailError,
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
                        hintText: 'your@email.com',
                      ),
                      onChanged: (_) {
                        // Clear the email error instantly if the user starts typing
                        setState(() {
                          _emailError = null;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (v) {
                        setState(() {
                          _passwordStrength = _getPasswordStrength(v);
                          if (_passwordError != null) _passwordError = null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
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
                        errorText: _passwordError,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.info_outline,
                                color: Color(0xFF2E8BC0),
                              ),
                              onPressed: _showPasswordRules,
                            ),
                            IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Password strength
                    if (_passwordStrength.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password Strength: $_passwordStrength",
                            style: TextStyle(
                              color: _getStrengthColor(_passwordStrength),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Confirm password
                    TextField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        prefixIcon: const Icon(Icons.lock_outline),
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
                        errorText: _confirmError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _signUp,
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
                                "Create Account",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),

                    const SizedBox(height: 14),

                    // Link to Sign In
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacement(context, _routeToSignIn()),
                      child: const Text(
                        "Already have an account? Sign In",
                        style: TextStyle(
                          color: Color(0xFF2E8BC0),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
