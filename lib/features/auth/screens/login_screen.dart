import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/localization/localization_provider.dart';
import 'register_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../../core/widgets/app_text_field.dart';
import 'phone_auth_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isCheckoutFlow;
  const LoginScreen({super.key, this.isCheckoutFlow = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleSuccess() {
    if (widget.isCheckoutFlow) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pop(true);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        _handleSuccess();
      }
    }
  }



/*
  void _loginWithGoogle() async {
    final success = await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
    if (success && mounted) {
      _handleSuccess();
    }
  }

  void _loginWithFacebook() async {
    final success = await Provider.of<AuthProvider>(context, listen: false).signInWithFacebook();
    if (success && mounted) {
      _handleSuccess();
    }
  }

  _loginWithSend(){
    Telegram kgrvi ste    
  }

  _loginWithCall(){
    Watsapnel ste kgrvi     
  }
*/

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
                    l10n.translate('login'),
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
                        const SizedBox(height: 40),
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
                                'assets/images/masoor_branch.png',
                                height: 165,
                                width: 248,
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 60),

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
                          controller: _emailController,
                          hintText: l10n.translate('usernameOrEmail'),
                          autofillHints: const [AutofillHints.email, AutofillHints.username],
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          hintText: l10n.translate('password'),
                          obscureText: true,
                          showToggle: true,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _submit,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),

                        // Login Button
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
                              l10n.translate('login'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),
                        Text(
                          'կամ',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                        ),

                        const SizedBox(height: 24),

                        // Social Logins
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton(
                              icon: Icons.local_phone_rounded,
                              onTap: () async {
                                final success = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(builder: (context) => PhoneAuthScreen(isCheckoutFlow: widget.isCheckoutFlow)),
                                );
                                if (!context.mounted) return;
                                if (success == true && widget.isCheckoutFlow) {
                                  Navigator.of(context).pop(true);
                                }
                              },
                            ),
                            const SizedBox(width: 16),
                            _socialButton(
                              icon: Icons.send_rounded, // Telegram placeholder
                              onTap: () {},
                            ),
                            const SizedBox(width: 16),
                            _socialButton(
                              icon: Icons.chat_bubble_rounded, // WhatsApp placeholder
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Footer Link
                        GestureDetector(
                          onTap: () async {
                            final success = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                settings: const RouteSettings(name: 'RegisterScreen'),
                                builder: (context) => RegisterScreen(isCheckoutFlow: widget.isCheckoutFlow),
                              ),
                            );
                            if (!context.mounted) return;
                            if (success == true) {
                              Navigator.of(context).pop(true);
                            }
                          },
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
                                  text: '${l10n.translate('noAccount')} ',
                                  style: TextStyle(fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurface),

                                ),
                                TextSpan(
                                  text: l10n.translate('register'),
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

  Widget _socialButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
        ),

        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 28),

      ),
    );
  }
}

