import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_text_field.dart';
import '../screens/phone_auth_screen.dart';

class GuestAuthView extends StatefulWidget {
  const GuestAuthView({super.key});

  @override
  State<GuestAuthView> createState() => _GuestAuthViewState();
}

class _GuestAuthViewState extends State<GuestAuthView> {
  bool _isLoginMode = true;

  // Login controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register controllers
  final _registerFormKey = GlobalKey<FormState>();
  final _regNameController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _loginEmailController.text,
        _loginPasswordController.text,
      );
    }
  }

  Future<void> _submitRegister() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_registerFormKey.currentState!.validate()) {
      if (_regPasswordController.text != _regConfirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Գաղտնաբառերը չեն համընկնում:')),
        );
        return;
      }

      final l10n = Provider.of<LocalizationProvider>(context, listen: false);
      final messenger = ScaffoldMessenger.of(context);

      final phoneExists = await authProvider.checkIfIdentifierExists(phone: _regPhoneController.text);
      if (phoneExists) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.translate('phoneAlreadyInUse'))),
        );
        return;
      }

      final emailExists = await authProvider.checkIfIdentifierExists(email: _regEmailController.text);
      if (emailExists) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.translate('emailAlreadyInUse'))),
        );
        return;
      }

      final success = await authProvider.register(
        _regNameController.text,
        '',
        _regEmailController.text,
        _regPasswordController.text,
        _regPhoneController.text,
      );

      if (success) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.translate('registrationSuccess'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoginMode ? _buildLogin(context) : _buildRegister(context);
  }

  Widget _buildLogin(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/masoor_branch.png',
                height: 80,
                width: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            if (authProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  authProvider.errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            AppTextField(
              controller: _loginEmailController,
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
              controller: _loginPasswordController,
              hintText: l10n.translate('password'),
              obscureText: true,
              showToggle: true,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onEditingComplete: _submitLogin,
              validator: (value) {
                if (value == null || value.isEmpty) return l10n.translate('requiredField');
                return null;
              },
            ),
            const SizedBox(height: 24),
            if (authProvider.isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else
              ElevatedButton(
                onPressed: _submitLogin,
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
            const SizedBox(height: 16),
            const Text(
              'կամ',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialButton(
                  icon: Icons.local_phone_rounded,
                  onTap: () async {
                    await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (context) => const PhoneAuthScreen(isCheckoutFlow: false)),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _socialButton(
                  icon: Icons.send_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                _socialButton(
                  icon: Icons.chat_bubble_rounded,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => setState(() => _isLoginMode = false),
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
    );
  }

  Widget _buildRegister(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/images/masoor_branch.png',
                height: 70,
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            if (authProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  authProvider.errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            AppTextField(
              controller: _regNameController,
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
              controller: _regPhoneController,
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
              controller: _regEmailController,
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
              controller: _regPasswordController,
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
              controller: _regConfirmPasswordController,
              hintText: 'Կրկնել գաղտնաբառը',
              obscureText: true,
              showToggle: true,
              textInputAction: TextInputAction.done,
              onEditingComplete: _submitRegister,
              validator: (value) {
                if (value == null || value.isEmpty) return l10n.translate('requiredField');
                if (value != _regPasswordController.text) return 'Գաղտնաբառերը չեն համընկնում:';
                return null;
              },
            ),
            const SizedBox(height: 24),
            if (authProvider.isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else
              ElevatedButton(
                onPressed: _submitRegister,
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
                  l10n.translate('register'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _isLoginMode = true),
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
                      text: '${l10n.translate('alreadyHaveAccount')} ',
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: l10n.translate('login'),
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
