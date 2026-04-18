import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/localization/localization_provider.dart';
import 'register_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/localization/widgets/language_selector.dart';
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

  void _loginWithGoogle() async {
    final success = await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
    if (success && mounted) {
      _handleSuccess();
    }
  }

  void _loginAnonymously() async {
    final success = await Provider.of<AuthProvider>(context, listen: false).signInAnonymously();
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


  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          LanguageSelector(color: Colors.white),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  color: AppColors.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 80,),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 5)
                                    )
                                  ]
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/masoor_logo.png',
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(l10n.translate('login'), style: const TextStyle(color: AppColors.textPrimary, fontSize: 40),),
                            const SizedBox(height: 10,),
                            Text(l10n.translate('welcome'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 18),),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: authProvider.isLoading 
                                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                                : AutofillGroup(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: <Widget>[
                                        if (authProvider.errorMessage != null)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 20),
                                            child: Text(
                                              authProvider.errorMessage!,
                                              style: const TextStyle(color: AppColors.error),
                                            ),
                                          ),
                                        const SizedBox(height: 20,),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.inputFill,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: const BoxDecoration(
                                                  border: Border(bottom: BorderSide(color: AppColors.border))
                                                ),
                                                child: TextFormField(
                                                  controller: _emailController,
                                                  style: const TextStyle(color: AppColors.textPrimary),
                                                  decoration: InputDecoration(
                                                    hintText: l10n.translate('usernameOrEmail'),
                                                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                                                    border: InputBorder.none,
                                                    filled: false,
                                                  ),
                                                  autofillHints: const [AutofillHints.email, AutofillHints.username],
                                                  keyboardType: TextInputType.emailAddress,
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) return l10n.translate('requiredField');
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                child: TextFormField(
                                                  controller: _passwordController,
                                                  obscureText: !_isPasswordVisible,
                                                  style: const TextStyle(color: AppColors.textPrimary),
                                                  decoration: InputDecoration(
                                                    hintText: l10n.translate('password'),
                                                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                                                    border: InputBorder.none,
                                                    filled: false,
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _isPasswordVisible = !_isPasswordVisible;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  autofillHints: const [AutofillHints.password],
                                                  onEditingComplete: () => TextInput.finishAutofillContext(),
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) return l10n.translate('requiredField');
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 30,),
                                        ElevatedButton(
                                          onPressed: _submit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(double.infinity, 55),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            elevation: 4,
                                            shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                          ),
                                          child: Text(l10n.translate('login'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                        ),
                                        const SizedBox(height: 20,),
                                        Row(
                                          children: [
                                            const Expanded(child: Divider(color: AppColors.border)),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Text(l10n.translate('otherOptions'), style: const TextStyle(color: AppColors.textSecondary)),
                                            ),
                                            const Expanded(child: Divider(color: AppColors.border)),
                                          ],
                                        ),
                                        const SizedBox(height: 20,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _socialButton(
                                              icon: Icons.phone_android,
                                              color: Colors.green,
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
                                            _socialButton(
                                              icon: Icons.g_mobiledata,
                                              color: Colors.red,
                                              onTap: _loginWithGoogle,
                                            ),
                                            _socialButton(
                                              icon: Icons.facebook,
                                              color: const Color(0xFF1877F2),
                                              onTap: _loginWithFacebook,
                                            ),
                                            _socialButton(
                                              icon: Icons.person_outline,
                                              color: AppColors.textSecondary,
                                              onTap: _loginAnonymously,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 30,),
                                        TextButton(
                                          onPressed: () async {
                                            final success = await Navigator.of(context).push<bool>(
                                              MaterialPageRoute(builder: (context) => RegisterScreen(isCheckoutFlow: widget.isCheckoutFlow)),
                                            );
                                            if (!context.mounted) return;
                                            if (success == true && widget.isCheckoutFlow) {
                                              Navigator.of(context).pop(true);
                                            }
                                          },
                                          child: Text(
                                            l10n.translate('noAccount'),
                                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                          ),
                                        ),
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
              ),
            ),
          );
        },
      ),

    );
  }

  Widget _socialButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.inputFill,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}

