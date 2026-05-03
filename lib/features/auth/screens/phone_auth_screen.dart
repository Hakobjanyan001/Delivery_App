import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/theme/app_theme.dart';

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
        // Fallback for other formats or let the provider handle validation
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text("Մուտք հեռախոսով", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.phone_android, size: 80, color: Theme.of(context).colorScheme.onSurface),

              const SizedBox(height: 30),
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    authProvider.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),

                  ),
                ),
              if (!_codeSent) ...[
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),

                  decoration: InputDecoration(
                    labelText: "Հեռախոսահամար (+374...)",
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2)),
                    prefixIcon: Icon(Icons.phone, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    hintText: "+374XXXXXXXX",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),

                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _verifyPhone,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),

                  child: authProvider.isLoading
                      ? CircularProgressIndicator(color: Theme.of(context).colorScheme.surface)

                      : const Text("Ուղարկել կոդը"),
                ),
              ] else ...[
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),

                  decoration: InputDecoration(
                    labelText: "SMS կոդ",
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2)),
                    prefixIcon: Icon(Icons.lock_open, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    hintText: "123456",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),

                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _signInWithOtp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),

                  child: authProvider.isLoading
                      ? CircularProgressIndicator(color: Theme.of(context).colorScheme.surface)

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
      ),

    );
  }
}
