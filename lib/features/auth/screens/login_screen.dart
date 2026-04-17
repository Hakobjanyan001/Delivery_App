import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/localization/localization_provider.dart';
import 'register_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/localization/widgets/language_selector.dart';
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
        MaterialPageRoute(builder: (context) => const HomeScreen()),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          LanguageSelector(color: Colors.white),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.blue[900]!,
              Colors.blue[800]!,
              Colors.blue[400]!
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 60,),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(l10n.translate('login'), style: const TextStyle(color: Colors.white, fontSize: 40),),
                  const SizedBox(height: 10,),
                  Text(l10n.translate('welcome'), style: const TextStyle(color: Colors.white, fontSize: 18),),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: authProvider.isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          if (authProvider.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                authProvider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 20,),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 139, .3),
                                  blurRadius: 20,
                                  offset: Offset(0, 10)
                                )
                              ]
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey[200]!))
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      hintText: l10n.translate('usernameOrEmail'),
                                      hintStyle: const TextStyle(color: Colors.grey),
                                      border: InputBorder.none
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
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey[200]!))
                                  ),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    decoration: InputDecoration(
                                      hintText: l10n.translate('password'),
                                      hintStyle: const TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
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
                              backgroundColor: Colors.blue[900],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            ),
                            child: Text(l10n.translate('login'), style: const TextStyle(fontWeight: FontWeight.bold),),
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[300])),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text("Այլ տարբերակներ", style: TextStyle(color: Colors.grey[600])),
                              ),
                              Expanded(child: Divider(color: Colors.grey[300])),
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
                                color: Colors.blue[900]!,
                                onTap: _loginWithFacebook,
                              ),
                              _socialButton(
                                icon: Icons.person_outline,
                                color: Colors.blue,
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
                              style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _socialButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}

