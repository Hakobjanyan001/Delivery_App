import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoor/features/auth/providers/auth_provider.dart';
import 'package:masoor/core/localization/localization_provider.dart';
import 'package:masoor/core/widgets/app_text_field.dart';
import 'package:masoor/features/auth/widgets/profile/profile_common_widgets.dart';

class EditProfileView extends StatefulWidget {
  final VoidCallback onBack;

  const EditProfileView({super.key, required this.onBack});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _nameController.text = auth.userName ?? '';
      _emailController.text = auth.email ?? '';
      _phoneController.text = auth.phone ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final l10n = Provider.of<LocalizationProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeader(title: l10n.translate('personalData'), onBack: widget.onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _nameController,
                  hintText: l10n.translate('name'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _emailController,
                  hintText: l10n.translate('email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _phoneController,
                  hintText: l10n.translate('phone'),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: l10n.translate('save'),
                  isLoading: auth.isLoading,
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await auth.updateProfile(
                      name: _nameController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                    );
                    if (success && mounted) {
                      widget.onBack();
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.translate('profileUpdated'))),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
