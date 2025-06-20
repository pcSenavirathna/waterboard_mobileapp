import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String customerId;
  final String name;

  const HomePage({super.key, required this.customerId, required this.name});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? previousMeter;
  double? currentMeter;
  bool loading = true;

  final TextEditingController meterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMeterDetails();
  }

  Future<void> fetchMeterDetails() async {
    setState(() => loading = true);
    final url =
        Uri.parse('http://172.20.10.2:3000/meter-details/${widget.customerId}');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (data['success'] && data['data'] != null) {
        setState(() {
          previousMeter = (data['data']['previous_meter'] as num?)?.toDouble();
          currentMeter = (data['data']['current_meter'] as num?)?.toDouble();
        });
      } else {
        setState(() {
          previousMeter = null;
          currentMeter = null;
        });
      }
    } catch (e) {
      setState(() {
        previousMeter = null;
        currentMeter = null;
      });
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy/MM/dd').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF4F5BD5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer ID: ${widget.customerId}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Name: ${widget.name}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Date: $formattedDate', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            loading
                ? const CircularProgressIndicator()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Previous Meter: ${previousMeter?.toString() ?? "-"}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current Meter: ${currentMeter?.toString() ?? "-"}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),
            const Text('Enter this month\'s current meter:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: meterController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Current Meter value',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F5BD5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final meterValue = meterController.text;
                  if (meterValue.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please enter the current meter value')),
                    );
                    return;
                  }
                  try {
                    final url =
                        Uri.parse('http://172.20.10.2:3000/submit-meter');
                    final response = await http.post(
                      url,
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'customerId': widget.customerId,
                        'currentMeter': meterValue,
                      }),
                    );
                    final data = jsonDecode(response.body);
                    if (data['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(data['message'] ?? 'Success!')),
                      );
                      fetchMeterDetails(); // Refresh after submit
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Failed: ${data['error'] ?? 'Unknown error'}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Cannot connect to server. Please try again later.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}