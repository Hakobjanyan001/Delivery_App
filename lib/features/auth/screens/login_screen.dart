import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/localization/localization_provider.dart';
import 'register_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/theme/app_theme.dart';
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
  bool _isPasswordVisible = false;

  void _handleSuccess() {
    if (widget.isCheckoutFlow) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          settings: const RouteSettings(name: 'HomeScreen'),
          builder: (context) => const HomeScreen(),
        ),
      );
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
      backgroundColor: Colors.black,
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
                        color: const Color(0xFF161616),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n.translate('login'),
                    style: const TextStyle(
                      color: Colors.white,
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
                  color: Colors.black,
                  child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/images/masoor_branch.png',
                            height: 165,
                            width: 248,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 60),

                        // Error Message
                        if (authProvider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),

                        // Inputs
                        _buildInputField(
                          controller: _emailController,
                          hintText: l10n.translate('usernameOrEmail'),
                          autofillHints: const [AutofillHints.email, AutofillHints.username],
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _passwordController,
                          hintText: l10n.translate('password'),
                          isPassword: true,
                          autofillHints: const [AutofillHints.password],
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.translate('requiredField');
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),

                        // Login Button
                        if (authProvider.isLoading)
                          const CircularProgressIndicator(color: Colors.white)
                        else
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
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
                        const Text(
                          'կամ',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
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
                            if (success == true && widget.isCheckoutFlow) {
                              Navigator.of(context).pop(true);
                            }
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Segoe UI',
                              ),
                              children: [
                                TextSpan(
                                  text: '${l10n.translate('noAccount')} ',
                                  style: const TextStyle(fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: l10n.translate('register'),
                                  style: const TextStyle(fontWeight: FontWeight.w700),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    List<String>? autofillHints,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      autofillHints: autofillHints,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        filled: true,
        fillColor: const Color(0xFF121212),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80),
          borderSide: const BorderSide(color: Colors.white24, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white38,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
      ),
      validator: validator,
    );
  }

  Widget _socialButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF141414),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

