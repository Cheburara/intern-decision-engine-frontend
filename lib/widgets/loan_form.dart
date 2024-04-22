// This file defines a `LoanForm` widget which is a stateful widget
// that displays a loan application form.

import 'dart:math';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:inbank_frontend/fonts.dart';
import 'package:inbank_frontend/widgets/country_code_field.dart';
import 'package:inbank_frontend/widgets/date_of_birth_field.dart';
import 'package:inbank_frontend/widgets/national_id_field.dart';

import '../api_service.dart';
import '../colors.dart';

// LoanForm is a StatefulWidget that displays a loan application form.
class LoanForm extends StatefulWidget {
  const LoanForm({Key? key}) : super(key: key);

  @override
  _LoanFormState createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  String _nationalId = '';
  int _loanAmount = 2500;
  int _loanPeriod = 36;
  int _loanAmountResult = 0;
  int _loanPeriodResult = 0;
  String _countryCode = '';
  DateTime? _dateOfBirth;
  String _errorMessage = '';

  // Submit the form and update the state with the loan decision results.
  // Only submits if the form inputs are validated.
  void _submitForm() {
    ApiService apiService = ApiService();
    DateTime? localDateOfBirth = _dateOfBirth;
    String formattedDateOfBirth = localDateOfBirth != null ? formatDate(localDateOfBirth) : '';

    apiService.requestLoanDecision(_nationalId, _loanAmount, _loanPeriod, _countryCode, formattedDateOfBirth)
        .then((response) {
      setState(() {
        _loanAmountResult = int.tryParse(response['loanAmount'] ?? '') ?? 0;
        _loanPeriodResult = int.tryParse(response['loanPeriod'] ?? '') ?? 0;
        _errorMessage = response['errorMessage'] ?? '';
      });
    }).catchError((error) {
      setState(() {
        _errorMessage = 'Failed to communicate with the server.';
      });
    });
  }

  // Builds the application form widget.
  // The widget automatically queries the endpoint for the latest data
  // when a field is changed.
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth / 3;
    const minWidth = 500.0;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: max(minWidth, formWidth),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  FormField<String>(
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CountryCodeField(
                            onChanged: (value) {
                              setState(() {
                                _countryCode = value ?? '';
                                _submitForm();
                              });
                            },
                          ),
                          NationalIdTextFormField(
                            onChanged: (value) {
                              setState(() {
                                _nationalId = value ?? '';
                                _submitForm();
                              });
                            },
                          ),
                          BirthDateFormField(
                            onChanged: (DateTime? value) {
                              setState(() {
                                _dateOfBirth = value;
                                _submitForm();
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30.0),
                  Text('Loan Amount: $_loanAmount €'),
                  const SizedBox(height: 4),
                  Slider.adaptive(
                    value: _loanAmount.toDouble(),
                    min: 2000,
                    max: 10000,
                    divisions: 80,
                    label: '$_loanAmount €',
                    activeColor: AppColors.secondaryColor,
                    onChanged: (double newValue) {
                      setState(() {
                        _loanAmount = ((newValue.floor() / 100).round() * 100);
                        _submitForm();
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('2000€')),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('10000€'),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Text('Loan Period: $_loanPeriod months'),
                  const SizedBox(height: 4),
                  Slider.adaptive(
                    value: _loanPeriod.toDouble(),
                    min: 12,
                    max: 60,
                    divisions: 48,
                    label: '$_loanPeriod months',
                    activeColor: AppColors.secondaryColor,
                    onChanged: (double newValue) {
                      setState(() {
                        _loanPeriod = newValue.round();
                        _submitForm();
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('12 months')),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('60 months'),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Column(
            children: [
              Text(
                  'Approved Loan Amount: ${_loanAmountResult != 0 ? _loanAmountResult : "--"} €'),
              const SizedBox(height: 8.0),
              Text(
                  'Approved Loan Period: ${_loanPeriodResult != 0 ? _loanPeriodResult : "--"} months'),
              Visibility(
                  visible: _errorMessage != '',
                  child: Text(_errorMessage, style: errorMedium))
            ],
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
