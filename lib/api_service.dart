import 'dart:convert';

import 'package:http/http.dart' as http;

// ApiService is a class that provides methods for making API calls
// to the decision engine.
class ApiService {
  final String _baseUrl = 'http://localhost:8080';
  String responseAmount = '';
  String responsePeriod = '';
  String responseCountryCode = '';
  String responseDateOfBirth = '';
  String responseError = '';
  http.Client httpClient;

  ApiService({http.Client? client}) : httpClient = client ?? http.Client();

  // requestLoanDecision sends a request to the API to get a loan decision
  // based on the provided personalCode, loanAmount, loanPeriod, countryCode, and dateOfBirth.
  Future<Map<String, String>> requestLoanDecision(
      String personalCode, int loanAmount, int loanPeriod, String countryCode, String dateOfBirth) async {
    final response = await httpClient.post(
      Uri.parse('$_baseUrl/loan/decision'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'personalCode': personalCode,
        'loanAmount': loanAmount,
        'loanPeriod': loanPeriod,
        'countryCode': countryCode,
        'dateOfBirth': dateOfBirth,
      }),
    );

    if (response.statusCode == 200) {
      // Decode the API response and update response data variables
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'loanAmount': responseData['loanAmount'].toString(),
        'loanPeriod': responseData['loanPeriod'].toString(),
        'countryCode': responseData['countryCode'].toString(),
        'dateOfBirth': responseData['dateOfBirth'].toString(),
        'errorMessage': responseData['errorMessage'] ?? '',
      };
    } else {
      // Parse the response to get the error message from the server
      Map<String, dynamic> responseData = jsonDecode(response.body);
      String errorMessage = responseData['errorMessage'] ?? 'An unexpected error occurred.';

      // Provide more context based on the status code
      if (response.statusCode == 400) {
        errorMessage = errorMessage;
      } else if (response.statusCode == 404) {
        errorMessage = 'Unfortunately, we could not find an available loan for you.';
      } else if (response.statusCode == 500) {
        errorMessage = 'Server error: ' + errorMessage;
      }

      return {
        'errorMessage': errorMessage
      };
    }
  }
}
