import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/constants/asset_constants.dart';

class RegisterScreen extends StatefulWidget {
  final bool isCheckoutFlow;
  const RegisterScreen({super.key, this.isCheckoutFlow = false});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}


class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  Future<void> _submit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Գաղտնաբառերը չեն համընկնում:')), // Passwords don't match
        );
        return;
      }

      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final l10n = Provider.of<LocalizationProvider>(context, listen: false);
      
      final phoneExists = await authProvider.checkIfIdentifierExists(phone: _phoneController.text);
      if (phoneExists) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.translate('phoneAlreadyInUse'))),
        );
        return;
      }

      final emailExists = await authProvider.checkIfIdentifierExists(email: _emailController.text);
      if (emailExists) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.translate('emailAlreadyInUse'))),
        );
        return;
      }
      
      final success = await authProvider.register(
        _nameController.text,
        '', // No username
        _emailController.text,
        _passwordController.text,
        _phoneController.text,
      );
      
      if (success) {
        if (!mounted) return;
        navigator.pop(true);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                      ),

                      child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface, size: 24),

                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n.translate('register'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),

                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,

                  child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Logo
                        Center(
                          child: Consumer<OnboardingProvider>(
                            builder: (context, onboarding, _) {
                              final logo = onboarding.partner?.logo;
                              if (logo != null && logo.isNotEmpty) {
                                return Image.network(
                                  logo,
                                  height: 165,
                                  width: 248,
                                  fit: BoxFit.contain,
                                );
                              }
                              return Image.asset(
                                AssetConstants.masoorBranch,
                                height: 165,
                                width: 248,
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Error Message
                        if (authProvider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),

                            ),
                          ),

                        // Inputs
                        AppTextField(
                          controller: _nameController,
                          hintText: l10n.translate('name'),
                          autofillHints: const [AutofillHints.name],
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _phoneController,
                          hintText: l10n.translate('phone'),
                          keyboardType: TextInputType.phone,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _emailController,
                          hintText: l10n.translate('email'),
                          autofillHints: const [AutofillHints.email],
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            if (!value.contains('@')) return l10n.translate('invalidEmail');
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _passwordController,
                          hintText: l10n.translate('password'),
                          obscureText: true,
                          showToggle: true,
                          autofillHints: const [AutofillHints.newPassword],
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            if (value.length < 6) return 'Գաղտնաբառը պետք է լինի առնվազն 6 նիշ:';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Կրկնել գաղտնաբառը',
                          obscureText: true,
                          showToggle: true,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _submit,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            if (value != _passwordController.text) return 'Գաղտնաբառերը չեն համընկնում:';
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),

                        // Register Button
                        if (authProvider.isLoading)
                          CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface)

                        else
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.onSurface,
                              foregroundColor: Theme.of(context).colorScheme.surface,
                              minimumSize: const Size(double.infinity, 65),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                              elevation: 0,
                            ),

                            child: Text(
                              l10n.translate('register'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Footer Link
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 13,
                                fontFamily: 'Segoe UI',
                              ),

                              children: [
                                TextSpan(
                                  text: '${l10n.translate('alreadyHaveAccount')} ',
                                  style: TextStyle(fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurface),

                                ),
                                TextSpan(
                                  text: l10n.translate('login'),
                                  style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),

                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
