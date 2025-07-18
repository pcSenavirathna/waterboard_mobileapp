import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String customerId = '';
  String name = '';
  String mobile = '';
  String password = '';
  final TextEditingController securityKeyController = TextEditingController();

  Future<void> signup() async {
    if (securityKeyController.text != '2025') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Security Key')),
      );
      return;
    }
    try {
      final url = Uri.parse('https://waterboard-api.vercel.app/signup');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerId': customerId,
          'name': name,
          'mobile': mobile,
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: ${data['error'] ?? 'Unknown error'}'),
          ),
        );
      }
    } catch (e) {
      // Show error if cannot connect to backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot connect to server. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    securityKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F5BD5),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child:
                    Icon(Icons.person_add, size: 56, color: Color(0xFF4F5BD5)),
                // Or use your logo:
                // backgroundImage: AssetImage('assets/images/waterlogo.jpg'),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Customer ID',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: UnderlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => customerId = val,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter Customer ID'
                            : (int.tryParse(val) == null
                                ? 'Enter a valid number'
                                : null),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: UnderlineInputBorder(),
                        ),
                        onChanged: (val) => name = val,
                        validator: (val) => val!.isEmpty ? 'Enter Name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: UnderlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (val) => mobile = val,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Enter Mobile Number';
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(val))
                            return 'Enter valid 10-digit number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const UnderlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        onChanged: (val) => password = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: securityKeyController,
                        decoration: const InputDecoration(
                          labelText: 'Security Key',
                          prefixIcon: Icon(Icons.vpn_key),
                          border: UnderlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter Security Key'
                            : null,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F5BD5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              signup();
                            }
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(
                              color: Color(0xFF4F5BD5),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}