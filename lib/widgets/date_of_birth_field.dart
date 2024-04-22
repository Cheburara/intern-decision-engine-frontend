import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../colors.dart';

// A custom form field widget for date of birth input
class BirthDateFormField extends StatefulWidget {
  final DateTime? initialValue;
  final Function(DateTime?)? onChanged;
  final String? Function(DateTime?)? validator;

  const BirthDateFormField({
    Key? key,
    this.initialValue,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  _BirthDateFormFieldState createState() => _BirthDateFormFieldState();
}

class _BirthDateFormFieldState extends State<BirthDateFormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue != null ? DateFormat('yyyy-MM-dd').format(widget.initialValue!) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.initialValue ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != widget.initialValue) {
      setState(() {
        _controller.text = DateFormat('yyyy-MM-dd').format(picked);
        if (widget.onChanged != null) {
          widget.onChanged!(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      style: const TextStyle(color: AppColors.textColor),
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        labelStyle: TextStyle(color: AppColors.textColor),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textColor),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: AppColors.textColor),
        suffixIconColor: AppColors.textColor,
      ),
      cursorColor: AppColors.textColor,
      readOnly: true,
      onTap: () {
        _selectDate(context);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your date of birth.';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}