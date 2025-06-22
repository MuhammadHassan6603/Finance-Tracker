import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/theme_constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final String? initialValue;
  final String? suffixText;
  final String? prefixText;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool readOnly;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final void Function()? onTap;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final InputBorder? border;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixText,
    this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.sentences,
    this.border,
    this.contentPadding,
    this.focusNode,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.helperText,
    this.suffixText,
    this.onTap,
    this.onSaved,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      readOnly: readOnly,
      onTap: onTap,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      style: TextStyle(
        color: isDarkMode
            ? ThemeConstants.textPrimaryDark
            : ThemeConstants.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: isDarkMode
              ? ThemeConstants.textSecondaryDark
              : ThemeConstants.textSecondaryLight,
        ),
        hintText: hintText,
        labelText: labelText,
        suffixText: suffixText,
        helperText: helperText,
        prefixText: prefixText,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      onTapOutside: (f) => FocusScope.of(context).unfocus(),
    );
  }
}
