import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import 'signup_screen.dart';
import 'forget_password_screen.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String _passwordStrength = "";
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email validation function
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Password strength used for UX; shows live while typing
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

  Future<void> _loadUserData(String userId) async {
    try {
      // This will load the username from SharedPreferences
      // and update it if needed from the database
      await _userService.getUsername();
    } catch (e) {
      // Handle error, but don't block the login
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = email.isEmpty ? "Enter your email" : null;
      _passwordError = password.isEmpty ? "Enter your password" : null;
    });

    if (_emailError != null || _passwordError != null) return;

    // Email format validation
    if (!_isValidEmail(email)) {
      setState(() => _emailError = "Please enter a valid email address");
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Load user data after successful login
      if (userCredential.user != null) {
        await _loadUserData(userCredential.user!.uid);

        // Update the username in SharedPreferences if needed
        await _userService.getUsername();
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _emailError = "No user found with this email";
        } else if (e.code == 'wrong-password') {
          _passwordError = "Incorrect password";
        } else if (e.code == 'invalid-email') {
          _emailError = "Invalid email format";
        } else {
          _emailError = null;
          _passwordError = null;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Login error: ${e.message}")));
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  PageRouteBuilder _routeToSignUp() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => const SignUpScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetTween = Tween(
          begin: const Offset(0.2, 0.0),
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
                      "Derma Scan",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("AI Skin Disease Screening Tool"),
                    const SizedBox(height: 25),

                    // Email field
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
                      onChanged: (value) {
                        if (_emailError != null && _isValidEmail(value)) {
                          setState(() => _emailError = null);
                        }
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
                                color: Color(0xFF2E8BC0), // Primary blue
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

                    const SizedBox(height: 20),

                    // Forgot password
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xFF2E8BC0), // Primary blue
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Sign in button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _signIn,
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
                                "Sign In",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),

                    const SizedBox(height: 14),

                    // Switch to signup
                    // Switch to signup
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacement(context, _routeToSignUp()),
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(
                          color: Color(0xFF2E8BC0), // Primary blue
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
