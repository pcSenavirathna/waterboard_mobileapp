import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String customerId = '';
  String currentPassword = '';
  String newPassword = '';
  String reNewPassword = '';
  bool _obscureNew = true;
  bool _obscureReNew = true;
  bool _obscureCurrent = true;

  Future<void> updatePassword() async {
    if (newPassword != reNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }
    try {
      final url = Uri.parse('https://waterboard-api.vercel.app/forgot-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerId': customerId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Update failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot connect to server. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Customer ID'),
                keyboardType: TextInputType.number,
                onChanged: (val) => customerId = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter Customer ID' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                obscureText: _obscureCurrent,
                onChanged: (val) => currentPassword = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter current password' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                obscureText: _obscureNew,
                onChanged: (val) => newPassword = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter new password' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Re-Enter New Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureReNew ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureReNew = !_obscureReNew),
                  ),
                ),
                obscureText: _obscureReNew,
                onChanged: (val) => reNewPassword = val,
                validator: (val) => val == null || val.isEmpty ? 'Re-enter new password' : null,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      updatePassword();
                    }
                  },
                  child: const Text('Update Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}