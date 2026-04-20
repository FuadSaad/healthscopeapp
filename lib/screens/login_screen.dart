import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login fields
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Signup fields
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  bool _loginLoading = false;
  bool _signupLoading = false;
  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPhoneController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password', isError: true);
      return;
    }

    setState(() => _loginLoading = true);

    final result = await ApiService.login(email, password);

    setState(() => _loginLoading = false);

    if (result['success'] == true) {
      // Save session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      final user = result['user'];
      if (user != null) {
        await prefs.setInt('userId', user['id'] ?? 0);
        await prefs.setString('userName', user['name'] ?? '');
        await prefs.setString('userEmail', user['email'] ?? '');
        await prefs.setString('userPhone', user['phone'] ?? '');
        _showMessage('Welcome back, ${user['name']}! 🎉');
      } else {
        _showMessage('Welcome back! 🎉');
      }
      widget.onLoginSuccess();
    } else {
      _showMessage(result['message'] ?? 'Login failed', isError: true);
    }
  }

  Future<void> _handleSignup() async {
    final name = _signupNameController.text.trim();
    final email = _signupEmailController.text.trim();
    final phone = _signupPhoneController.text.trim();
    final password = _signupPasswordController.text;
    final confirm = _signupConfirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Name, email, and password are required', isError: true);
      return;
    }

    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters', isError: true);
      return;
    }

    if (password != confirm) {
      _showMessage('Passwords do not match', isError: true);
      return;
    }

    setState(() => _signupLoading = true);

    final result = await ApiService.signup(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    setState(() => _signupLoading = false);

    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      final user = result['user'];
      if (user != null) {
        await prefs.setInt('userId', user['id'] ?? 0);
        await prefs.setString('userName', user['name'] ?? '');
        await prefs.setString('userEmail', user['email'] ?? '');
        await prefs.setString('userPhone', user['phone'] ?? '');
      }

      _showMessage('Account created! Welcome, $name! 🎉');
      widget.onLoginSuccess();
    } else {
      _showMessage(result['message'] ?? 'Signup failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Beautiful Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF020617)],
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: const Color(0xFF10B981).withOpacity(0.15),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -50,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: const Color(0xFF3B82F6).withOpacity(0.15), 
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(color: Colors.transparent)),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Header Space
                const SizedBox(height: 30),
                Hero(
                  tag: 'appLogo',
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.2), blurRadius: 30)],
                    ),
                    child: const Icon(Icons.health_and_safety, size: 52, color: Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('HealthScope BD', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text('Your Digital Health Companion', style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.6))),
                const SizedBox(height: 40),

                // Main Glassmorphism Bottom Sheet
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            // Tab Bar
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(30)),
                              child: TabBar(
                                controller: _tabController,
                                indicator: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white54,
                                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                dividerColor: Colors.transparent,
                                tabs: const [Tab(text: 'Login'), Tab(text: 'Sign Up')],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Tab Views
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [_buildLoginTab(), _buildSignupTab()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome Back 👋', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Sign in to continue your journey', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)),
          const SizedBox(height: 36),

          _buildPremiumTextField(
            controller: _loginEmailController,
            hint: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          _buildPremiumTextField(
            controller: _loginPasswordController,
            hint: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscureLoginPassword,
            onToggleVisibility: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          ),
          const SizedBox(height: 16),
          
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {}, 
              child: Text('Forgot Password?', style: TextStyle(color: const Color(0xFF10B981).withOpacity(0.9), fontWeight: FontWeight.w600)),
            )
          ),
          const SizedBox(height: 24),

          _buildPremiumButton(
            text: 'Sign In',
            isLoading: _loginLoading,
            onPressed: _handleLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create Account 🚀', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Join HealthScope BD today', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)),
          const SizedBox(height: 36),

          _buildPremiumTextField(
            controller: _signupNameController,
            hint: 'Full Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          _buildPremiumTextField(
            controller: _signupEmailController,
            hint: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          _buildPremiumTextField(
            controller: _signupPhoneController,
            hint: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),

          _buildPremiumTextField(
            controller: _signupPasswordController,
            hint: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscureSignupPassword,
            onToggleVisibility: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
          ),
          const SizedBox(height: 20),

          _buildPremiumTextField(
            controller: _signupConfirmPasswordController,
            hint: 'Confirm Password',
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          const SizedBox(height: 40),

          _buildPremiumButton(
            text: 'Sign Up',
            isLoading: _signupLoading,
            onPressed: _handleSignup,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.6), size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white.withOpacity(0.4), size: 20),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPremiumButton({required String text, required bool isLoading, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
      ),
    );
  }
}
