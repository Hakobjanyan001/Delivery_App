import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../home/screens/home_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  final bool isCheckoutFlow;
  const PhoneAuthScreen({super.key, this.isCheckoutFlow = false});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _codeSent = false;

  void _verifyPhone() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l10n = Provider.of<LocalizationProvider>(context, listen: false);

    String phoneNumber = _phoneController.text.trim();
    
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('requiredField'))),
      );
      return;
    }

    // Automatically handle 8-digit local numbers for Armenia
    if (phoneNumber.length == 8 && !phoneNumber.startsWith('+')) {
      phoneNumber = '+374$phoneNumber';
    } else if (!phoneNumber.startsWith('+')) {
      // If it doesn't start with +, assume it needs a + but might already have country code?
      // For safety, let's just ensure it has a + if it looks like a full number or prepend +374 if it looks like local
      if (phoneNumber.startsWith('374')) {
        phoneNumber = '+$phoneNumber';
      } else {
        // Fallback for other formats or let Firebase handle validation
        // But for this app, +374 is the primary focus
      }
    }

    // Check if phone number already exists
    final exists = await authProvider.checkIfIdentifierExists(phone: phoneNumber);
    if (exists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Այս հեռախոսահամարն արդեն գրանցված է:')),
      );
      return;
    }

    await authProvider.verifyPhone(
      phoneNumber,
      (verificationId) {
        setState(() {
          _codeSent = true;
        });
      },
    );
  }

  void _signInWithOtp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_otpController.text.isEmpty) {
      final l10n = Provider.of<LocalizationProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('requiredField'))),
      );
      return;
    }

    final navigator = Navigator.of(context);
    String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.length == 8 && !phoneNumber.startsWith('+')) {
      phoneNumber = '+374$phoneNumber';
    } else if (phoneNumber.startsWith('374')) {
      phoneNumber = '+$phoneNumber';
    }

    final success = await authProvider.signInWithPhone(
      _otpController.text,
      phoneNumber: phoneNumber,
    );
    if (success) {
      if (!mounted) return;
      if (widget.isCheckoutFlow) {
        navigator.pop(true);
      } else {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);



    return Scaffold(
      appBar: AppBar(
        title: const Text("Մուտք հեռախոսով"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android, size: 80, color: Colors.blue),
            const SizedBox(height: 30),
            if (authProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  authProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (!_codeSent) ...[
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Հեռախոսահամար (+374...)",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  hintText: "+374XXXXXXXX",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _verifyPhone,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Ուղարկել կոդը"),
              ),
            ] else ...[
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "SMS կոդ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_open),
                  hintText: "123456",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _signInWithOtp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Հաստատել"),
              ),
              TextButton(
                onPressed: () => setState(() => _codeSent = false),
                child: const Text("Փոխել հեռախոսահամարը"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
