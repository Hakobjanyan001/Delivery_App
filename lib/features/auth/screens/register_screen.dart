import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/localization/widgets/language_selector.dart';

class RegisterScreen extends StatefulWidget {
  final bool isCheckoutFlow;
  const RegisterScreen({super.key, this.isCheckoutFlow = false});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}


class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _submit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final l10n = Provider.of<LocalizationProvider>(context, listen: false);
      
      // Check if email or username already exists
      final emailExists = await authProvider.checkIfIdentifierExists(email: _emailController.text);
      if (emailExists) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Այս էլ. հասցեն արդեն գրանցված է:')),
        );
        return;
      }

      final usernameExists = await authProvider.checkIfIdentifierExists(username: _usernameController.text);
      if (usernameExists) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Այս մուտքանունը արդեն զբաղված է:')),
        );
        return;
      }
      
      final success = await authProvider.register(
        _nameController.text,
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
      
      if (success) {
        if (!mounted) return;
        if (widget.isCheckoutFlow) {
          navigator.pop(true);
        } else {
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.translate('registrationSuccess'))),
        );
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('register')),
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: authProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
            child: Column(
              children: [
                if (authProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                const Icon(Icons.person_add_outlined, size: 80, color: Colors.blue),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('name'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  autofillHints: const [AutofillHints.name],
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.translate('requiredField');
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('username'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.account_circle),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.translate('requiredField');
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('email'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  autofillHints: const [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.translate('requiredField');
                    if (!value.contains('@')) return l10n.translate('invalidEmail');
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: l10n.translate('password'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.translate('requiredField');
                    if (value.length < 6) return l10n.translate('shortPassword');
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: l10n.translate('confirmPassword'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_clock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  autofillHints: const [AutofillHints.password],
                  onEditingComplete: () => TextInput.finishAutofillContext(),
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.translate('requiredField');
                    if (value != _passwordController.text) return l10n.translate('passwordMismatch');
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(l10n.translate('register'), style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

