import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../colors.dart';

// A custom text form field widget for country code input
class CountryCodeField extends StatelessWidget {
  // Properties for initial value, on changed event handler and validator function
  final String? initialValue;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const CountryCodeField({
    Key? key,
    this.initialValue,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  // Builds the text form field widget with customized decoration and validation
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(color: AppColors.textColor),
      decoration: const InputDecoration(
        labelText: 'Country code',
        labelStyle: TextStyle(color: AppColors.textColor),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textColor),
        ),
      ),
      cursorColor: AppColors.textColor,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'\w')),
        LengthLimitingTextInputFormatter(2),
      ],
      keyboardType: TextInputType.number,

      // Rudimentary client side verification of the ID code
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a country code.';
            }
            if (value.length != 2) {
              return 'Country should have 2 characters.';
            }
            return null;
          },
      onChanged: onChanged,

      // Set autovalidate mode to trigger validation on user interaction
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
