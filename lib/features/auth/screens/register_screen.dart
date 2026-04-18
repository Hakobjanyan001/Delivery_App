import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/localization/widgets/language_selector.dart';
import '../../../core/theme/app_theme.dart';

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
  final _phoneController = TextEditingController();
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
          SnackBar(content: Text(l10n.translate('emailAlreadyInUse'))),
        );
        return;
      }

      final phoneExists = await authProvider.checkIfIdentifierExists(phone: _phoneController.text);
      if (phoneExists) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.translate('phoneAlreadyInUse'))),
        );
        return;
      }

      final usernameExists = await authProvider.checkIfIdentifierExists(username: _usernameController.text);
      if (usernameExists) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.translate('usernameAlreadyInUse'))),
        );
        return;
      }
      
      final success = await authProvider.register(
        _nameController.text,
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _phoneController.text,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.translate('register'),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: const [
          LanguageSelector(color: AppColors.textPrimary),
        ],
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, MediaQuery.of(context).viewInsets.bottom + 40.0),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (authProvider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        const SizedBox(height: 20),
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _nameController,
                          label: l10n.translate('name'),
                          icon: Icons.person,
                          autofillHints: const [AutofillHints.name],
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          label: l10n.translate('phone'),
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _usernameController,
                          label: l10n.translate('username'),
                          icon: Icons.account_circle,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: l10n.translate('email'),
                          icon: Icons.email,
                          autofillHints: const [AutofillHints.email],
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            if (!value.contains('@')) return l10n.translate('invalidEmail');
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          label: l10n.translate('password'),
                          icon: Icons.lock,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          autofillHints: const [AutofillHints.newPassword],
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            if (value.length < 6) return l10n.translate('shortPassword');
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: l10n.translate('confirmPassword'),
                          icon: Icons.lock_clock,
                          isPassword: true,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          onTogglePassword: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
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
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          ),
                          child: Text(
                            l10n.translate('register'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            l10n.translate('alreadyHaveAccount'),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    List<String>? autofillHints,
    TextInputType? keyboardType,
    VoidCallback? onEditingComplete,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      style: const TextStyle(color: AppColors.textPrimary),
      autofillHints: autofillHints,
      keyboardType: keyboardType,
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: onTogglePassword,
              )
            : null,
      ),
      validator: validator,
    );
  }
}
