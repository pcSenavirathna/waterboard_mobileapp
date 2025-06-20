import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _checkTerms();
  }

  Future<void> _checkTerms() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('accepted_terms') ?? false;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (accepted) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/terms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/waterlogo.jpg',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}