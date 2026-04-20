import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/home_screen.dart';
import 'screens/symptom_checker_screen.dart';
import 'screens/trends_screen.dart';
import 'screens/report_screen.dart';
import 'screens/about_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AppTheme.loadSavedTheme();
  runApp(const HealthScopeApp());
}

class HealthScopeApp extends StatelessWidget {
  const HealthScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeMode,
      builder: (context, mode, _) {
        // Apply Google Fonts to both themes
        final lightTheme = AppTheme.lightTheme.copyWith(
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        );
        final darkTheme = AppTheme.darkTheme.copyWith(
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        );

        return MaterialApp(
          title: 'HealthScope BD',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: const AuthGate(),
        );
      },
    );
  }
}

/// Checks if user is logged in and shows Login or MainNavigator accordingly.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSplash = true;
  bool _checking = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _checking = false;
      });
    }
  }

  void _onSplashFinished() {
    if (mounted) setState(() => _showSplash = false);
  }

  void _onLoginSuccess() {
    setState(() => _isLoggedIn = true);
  }

  void _onLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      setState(() => _isLoggedIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen first
    if (_showSplash) {
      return SplashScreen(onFinished: _onSplashFinished);
    }

    if (_checking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                  boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
                ),
                child: const Icon(Icons.health_and_safety, size: 56, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Color(0xFF10B981), strokeWidth: 2.5),
            ],
          ),
        ),
      );
    }

    if (!_isLoggedIn) {
      return LoginScreen(onLoginSuccess: _onLoginSuccess);
    }

    return MainNavigator(onLogout: _onLogout);
  }
}

class MainNavigator extends StatefulWidget {
  final VoidCallback onLogout;
  const MainNavigator({super.key, required this.onLogout});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // Keys to force rebuild when switching tabs — ensures fresh Firebase data
  final Map<int, Key> _screenKeys = {};

  Key _getKey(int index) {
    return _screenKeys[index] ?? ValueKey('screen_$index');
  }

  void _onItemTapped(int index) {
    setState(() {
      _screenKeys[index] = UniqueKey();
      _selectedIndex = index;
    });
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0: return HomeScreen(key: _getKey(0));
      case 1: return SymptomCheckerScreen(key: _getKey(1));
      case 2: return TrendsScreen(key: _getKey(2));
      case 3: return ReportScreen(key: _getKey(3));
      case 4: return AboutScreen(key: _getKey(4), onLogout: widget.onLogout);
      default: return HomeScreen(key: _getKey(0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(context);

    return Scaffold(
      body: _buildScreen(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.navBg,
          border: Border(top: BorderSide(color: c.navBorder)),
          boxShadow: [
            BoxShadow(color: c.navShadow, blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: c.navInactive,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.3),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              activeIcon: Icon(Icons.medical_services_rounded),
              label: 'Symptoms',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Trends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment_rounded),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people_rounded),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}
