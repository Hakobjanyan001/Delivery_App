import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Unified text field for the whole app.
///
/// States:
///   empty    — dark bg, no border, hint text
///   focused  — dark bg, white 40% border
///   filled   — dark bg, white 12% border
///   error    — dark bg, red border + error text below
///   disabled — 40% opacity, no interactions
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  final bool showToggle;        // show eye icon for password fields
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final bool enabled;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.showToggle = false,
    this.keyboardType,
    this.autofillHints,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.focusNode,
    this.enabled = true,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _isObscured = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiLine = widget.maxLines > 1;
    final double radius = isMultiLine ? 20.0 : 80.0;

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.4,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText && _isObscured,
        keyboardType: widget.keyboardType,
        autofillHints: widget.autofillHints,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
        enabled: widget.enabled,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        textInputAction: widget.textInputAction,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: const Color(0xFF121212),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isMultiLine ? 16 : 20,
          ),
          // --- border states ---
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: _buildSuffix(),
        ),
        validator: widget.validator,
      ),
    );
  }

  bool get _hasText => (widget.controller?.text.isNotEmpty) ?? false;

  Widget? _buildSuffix() {
    if (widget.showToggle) {
      return IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_off : Icons.visibility,
          color: Colors.white.withValues(alpha: 0.4),
          size: 20,
        ),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      );
    }
    return widget.suffixIcon;
  }
}
