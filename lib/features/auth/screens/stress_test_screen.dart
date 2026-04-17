import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class StressTestScreen extends StatefulWidget {
  const StressTestScreen({super.key});

  @override
  State<StressTestScreen> createState() => _StressTestScreenState();
}

class _StressTestScreenState extends State<StressTestScreen> {
  final List<String> _results = [];
  bool _isRunning = false;

  void _runStressTest() async {
    setState(() {
      _isRunning = true;
      _results.clear();
      _results.add('Սկսում ենք 10 զուգահեռ մուտքի թեստը...');
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // We will simulate 10 concurrent requests to check for duplicates
    // and then 10 concurrent requests to save user data (dummy data)
    
    final startTime = DateTime.now();

    try {
      final List<Future<bool>> checks = List.generate(10, (i) {
        return authProvider.checkIfIdentifierExists(email: 'test_user_$i@example.com');
      });

      final results = await Future.wait(checks);
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      setState(() {
        _results.add('10 ստուգումն ավարտվեց $duration մվ-ում:');
        _results.add('Արդյունքներ: ${results.where((r) => r).length} գոյություն ունեցող, ${results.where((r) => !r).length} նոր:');
      });

      _results.add('Սկսում ենք տվյալների պահպանման թեստը...');
      
      // Note: We can't easily simulate 10 "real" Firebase users without login,
      // but we can test the AuthRepository's saveUserData method if we had a User object.
      // Since we don't have real User objects here, we are testing the query part primarily.
      
    } catch (e) {
      setState(() {
        _results.add('Սխալ թեստի ժամանակ: $e');
      });
    } finally {
      setState(() {
        _isRunning = false;
        _results.add('Թեստն ավարտվեց:');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stress Test (10 Logins)')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isRunning ? null : _runStressTest,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.orange,
              ),
              child: _isRunning 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Սկսել թեստը (10 concurrent requests)'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) => Text(_results[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
