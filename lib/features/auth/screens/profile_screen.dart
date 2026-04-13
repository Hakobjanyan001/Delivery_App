import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import '../providers/auth_provider.dart';
import '../../cart/providers/payment_provider.dart';
import '../../cart/models/payment_card.dart';
import '../../../core/localization/localization_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _pickImage(AuthProvider auth) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      auth.updateProfile(imagePath: image.path);
    }
  }

  void _showEditField(BuildContext context, AuthProvider auth, String field, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$field-ի փոփոխում'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Մուտքագրեք նոր $field'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Չեղարկել')),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Պահպանել'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final payment = Provider.of<PaymentProvider>(context);
    Provider.of<LocalizationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Իմ պրոֆիլը', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[900],
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue[50],
                    backgroundImage: auth.profileImagePath != null
                        ? (kIsWeb 
                            ? NetworkImage(auth.profileImagePath!) as ImageProvider
                            : FileImage(io.File(auth.profileImagePath!)) as ImageProvider)
                        : null,
                    child: auth.profileImagePath == null
                        ? Icon(Icons.person, size: 60, color: Colors.blue[900])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(auth),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue[900],
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              auth.userName ?? 'Օգտատեր',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Profile Sections
            _buildInfoCard(
              title: 'Անձնական տվյալներ',
              items: [
                _buildInfoItem(
                  icon: Icons.person_outline,
                  label: 'Անուն',
                  value: auth.userName ?? '-',
                  onTap: () => _showEditField(context, auth, 'Անուն', auth.userName!, (v) => auth.updateProfile(name: v)),
                ),
                _buildInfoItem(
                  icon: Icons.email_outlined,
                  label: 'Էլ. փոստ',
                  value: auth.email ?? '-',
                  onTap: () => _showEditField(context, auth, 'Էլ. փոստ', auth.email!, (v) => auth.updateProfile(email: v)),
                ),
                _buildInfoItem(
                  icon: Icons.phone_outlined,
                  label: 'Հեռախոս',
                  value: auth.phone ?? '-',
                  onTap: () => _showEditField(context, auth, 'Հեռախոս', auth.phone!, (v) => auth.updateProfile(phone: v)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildInfoCard(
              title: 'Վճարման քարտեր',
              items: payment.cards.isEmpty
                  ? [
                      const ListTile(
                        leading: Icon(Icons.credit_card_off),
                        title: Text('Կցված քարտեր չկան'),
                      )
                    ]
                  : payment.cards.map((card) => _buildCardItem(card, payment)).toList(),
            ),

            const SizedBox(height: 40),

            // Logout Button
            ElevatedButton(
              onPressed: () {
                auth.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Դուրս գալ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[900]),
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
      trailing: const Icon(Icons.edit_outlined, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildCardItem(PaymentCard card, PaymentProvider provider) {
    return ListTile(
      leading: const Icon(Icons.credit_card, color: Colors.blue),
      title: Text('**** **** **** ${card.last4}'),
      subtitle: Text(card.expiryDate),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: () => _confirmDeleteCard(context, provider, card),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _confirmDeleteCard(BuildContext context, PaymentProvider provider, PaymentCard card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ջնջել քարտը'),
        content: Text('Ցանկանո՞ւմ եք ջնջել ${card.last4}-ով ավարտվող քարտը։'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Չեղարկել')),
          TextButton(
            onPressed: () {
              provider.removeCard(card.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Ջնջել', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
