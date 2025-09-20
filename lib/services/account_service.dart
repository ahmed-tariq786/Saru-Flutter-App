import 'dart:convert';

import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:saru/graphql/mutation/account_mutation.dart';
import 'package:saru/models/account.dart';
import 'package:saru/services/language.dart';
import 'package:saru/services/shopify_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountController extends GetxController {
  final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;

  // Authentication state
  final RxBool isLoggedIn = false.obs;
  final Rx<Customer?> currentCustomer = Rx<Customer?>(null);
  final RxString customerAccessToken = ''.obs;

  // SharedPreferences keys
  static const String _accessTokenKey = 'customer_access_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _customerDataKey = 'customer_data';

  Future<CustomerCreationResult> createCustomer(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(
            createCustomerMutation(locale: languageCode),
          ),
          variables: {
            "input": {
              "email": email.trim().toLowerCase(),
              "password": password,
              "firstName": firstName.trim(),
              "lastName": lastName.trim(),
            },
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      // Check for GraphQL exceptions
      if (result.hasException) {
        print('GraphQL Exception: ${result.exception.toString()}');

        // Handle network errors
        if (result.exception!.graphqlErrors.isEmpty && result.exception!.linkException != null) {
          return CustomerCreationResult(
            success: false,
            errorMessage: 'Network error. Please check your connection and try again.',
            errorType: CustomerErrorType.network,
          );
        }

        // Handle GraphQL errors
        final graphqlErrors = result.exception!.graphqlErrors;
        if (graphqlErrors.isNotEmpty) {
          final error = graphqlErrors.first;
          final errorMessage = error.message;

          return CustomerCreationResult(
            success: false,
            errorMessage: _parseShopifyError(errorMessage),
            errorType: CustomerErrorType.shopify,
          );
        }

        return CustomerCreationResult(
          success: false,
          errorMessage: 'An unexpected error occurred. Please try again.',
          errorType: CustomerErrorType.unknown,
        );
      }

      // Check for Shopify customer creation errors
      final customerCreate = result.data?['customerCreate'];
      if (customerCreate == null) {
        return CustomerCreationResult(
          success: false,
          errorMessage: 'Failed to create customer. Please try again.',
          errorType: CustomerErrorType.unknown,
        );
      }

      final userErrors = customerCreate['customerUserErrors'] as List?;
      if (userErrors != null && userErrors.isNotEmpty) {
        final errorMessage = userErrors.first['message'] as String;
        return CustomerCreationResult(
          success: false,
          errorMessage: _parseShopifyError(errorMessage),
          errorType: CustomerErrorType.shopify,
        );
      }

      final customer = customerCreate['customer'];
      if (customer == null) {
        return CustomerCreationResult(
          success: false,
          errorMessage: 'Failed to create customer account. Please try again.',
          errorType: CustomerErrorType.shopify,
        );
      }

      // Success
      return CustomerCreationResult(
        success: true,
        customer: CustomerData(
          id: customer['id'],
          email: customer['email'],
          firstName: customer['firstName'],
          lastName: customer['lastName'],
        ),
      );
    } catch (e) {
      print("Error creating customer: $e");
      return CustomerCreationResult(
        success: false,
        errorMessage: 'An unexpected error occurred. Please try again later.',
        errorType: CustomerErrorType.unknown,
      );
    }
  }

  Future<CustomerLoginResult> loginCustomer(String email, String password) async {
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(
            customerLoginMutation(locale: languageCode),
          ),
          variables: {
            "input": {
              "email": email.trim().toLowerCase(),
              "password": password,
            },
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      // Check for GraphQL exceptions
      if (result.hasException) {
        print('GraphQL Exception: ${result.exception.toString()}');

        // Handle network errors
        if (result.exception!.graphqlErrors.isEmpty && result.exception!.linkException != null) {
          return CustomerLoginResult(
            success: false,
            errorMessage: 'Network error. Please check your connection and try again.',
            errorType: CustomerErrorType.network,
          );
        }

        // Handle GraphQL errors
        final graphqlErrors = result.exception!.graphqlErrors;
        if (graphqlErrors.isNotEmpty) {
          final error = graphqlErrors.first;
          final errorMessage = error.message;

          // Check for specific error codes in extensions
          if (error.extensions != null && error.extensions!['code'] == 'THROTTLED') {
            return CustomerLoginResult(
              success: false,
              errorMessage: 'Too many login attempts. Please wait a few minutes before trying again.',
              errorType: CustomerErrorType.shopify,
            );
          }

          return CustomerLoginResult(
            success: false,
            errorMessage: _parseShopifyError(errorMessage),
            errorType: CustomerErrorType.shopify,
          );
        }

        return CustomerLoginResult(
          success: false,
          errorMessage: 'An unexpected error occurred. Please try again.',
          errorType: CustomerErrorType.unknown,
        );
      }

      // Check for Shopify customer login errors
      final customerAccessTokenCreate = result.data?['customerAccessTokenCreate'];
      if (customerAccessTokenCreate == null) {
        return CustomerLoginResult(
          success: false,
          errorMessage: 'Failed to log in. Please try again.',
          errorType: CustomerErrorType.unknown,
        );
      }

      final userErrors = customerAccessTokenCreate['customerUserErrors'] as List?;
      if (userErrors != null && userErrors.isNotEmpty) {
        final errorMessage = userErrors.first['message'] as String;
        return CustomerLoginResult(
          success: false,
          errorMessage: _parseLoginError(errorMessage),
          errorType: CustomerErrorType.shopify,
        );
      }

      final customerAccessToken = customerAccessTokenCreate['customerAccessToken'];
      if (customerAccessToken == null) {
        return CustomerLoginResult(
          success: false,
          errorMessage: 'Invalid email or password. Please check your credentials and try again.',
          errorType: CustomerErrorType.shopify,
        );
      }

      // Success - extract token and customer info
      final accessToken = customerAccessToken['accessToken'] as String?;
      final expiresAt = customerAccessToken['expiresAt'] as String?;

      if (accessToken == null) {
        return CustomerLoginResult(
          success: false,
          errorMessage: 'Failed to create access token. Please try again.',
          errorType: CustomerErrorType.shopify,
        );
      }

      // Store authentication data and fetch customer info
      await _storeAuthenticationData(accessToken, expiresAt);
      await _fetchAndStoreCustomerData(accessToken);

      return CustomerLoginResult(
        success: true,
        accessToken: accessToken,
        expiresAt: expiresAt,
      );
    } catch (e) {
      print("Error logging in customer: $e");
      return CustomerLoginResult(
        success: false,
        errorMessage: 'An unexpected error occurred. Please try again later.',
        errorType: CustomerErrorType.unknown,
      );
    }
  }

  String _parseLoginError(String errorMessage) {
    final upperError = errorMessage.toUpperCase();
    final lowerError = errorMessage.toLowerCase();

    // Official Shopify error codes for login
    if (upperError.contains('ALREADY_ENABLED')) {
      return 'This customer account is already active.';
    }

    if (upperError.contains('BAD_DOMAIN')) {
      return 'Please enter a valid email address. The domain name is invalid.';
    }

    if (upperError.contains('BLANK')) {
      return 'Please fill in all required fields.';
    }

    if (upperError.contains('CONTAINS_HTML_TAGS')) {
      return 'Please remove any HTML tags from your input.';
    }

    if (upperError.contains('CONTAINS_URL')) {
      return 'URLs are not allowed in this field.';
    }

    if (upperError.contains('CUSTOMER_DISABLED')) {
      return 'Your account has been disabled. Please contact support for assistance.';
    }

    if (upperError.contains('INVALID')) {
      if (lowerError.contains('email')) {
        return 'Please enter a valid email address.';
      }
      if (lowerError.contains('password') || lowerError.contains('credentials')) {
        return 'Invalid email or password. Please check your credentials and try again.';
      }
      return 'The information you entered is invalid. Please check and try again.';
    }

    if (upperError.contains('INVALID_MULTIPASS_REQUEST')) {
      return 'Authentication token is invalid. Please try logging in again.';
    }

    if (upperError.contains('NOT_FOUND')) {
      return 'Account not found. Please check your email or create a new account.';
    }

    if (upperError.contains('PASSWORD_STARTS_OR_ENDS_WITH_WHITESPACE')) {
      return 'Password cannot start or end with spaces. Please remove extra spaces.';
    }

    if (upperError.contains('TAKEN')) {
      return 'This information is already in use. Please try a different value.';
    }

    if (upperError.contains('TOKEN_INVALID')) {
      return 'The authentication token is invalid or has expired. Please try logging in again.';
    }

    if (upperError.contains('TOO_LONG')) {
      if (lowerError.contains('password')) {
        return 'Password is too long. Please use a shorter password.';
      }
      if (lowerError.contains('email')) {
        return 'Email address is too long. Please use a shorter email.';
      }
      return 'The input is too long. Please use fewer characters.';
    }

    if (upperError.contains('TOO_SHORT')) {
      if (lowerError.contains('password')) {
        return 'Password is too short. Please use a longer password.';
      }
      return 'The input is too short. Please add more characters.';
    }

    if (upperError.contains('UNIDENTIFIED_CUSTOMER')) {
      return 'Account not found. Please check your email or create a new account.';
    }

    if (upperError.contains('THROTTLED') || lowerError.contains('too many attempts')) {
      return 'Too many login attempts. Please wait a few minutes before trying again.';
    }

    // Legacy login-specific error patterns for backwards compatibility
    if (lowerError.contains('unidentified') || lowerError.contains('not found')) {
      return 'Account not found. Please check your email or create a new account.';
    }

    if (lowerError.contains('password') && (lowerError.contains('incorrect') || lowerError.contains('invalid'))) {
      return 'Incorrect password. Please try again.';
    }

    if (lowerError.contains('credentials') || lowerError.contains('authentication')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }

    if (lowerError.contains('rate limit') || lowerError.contains('too many requests')) {
      return 'Too many login attempts. Please wait a few minutes before trying again.';
    }

    // Return original message if no specific pattern matches
    return errorMessage;
  }

  // ==================== AUTHENTICATION MANAGEMENT ====================

  /// Load stored authentication data on app start
  Future<void> loadStoredAuthentication() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final storedToken = prefs.getString(_accessTokenKey);
      final expiryString = prefs.getString(_tokenExpiryKey);
      final customerJson = prefs.getString(_customerDataKey);

      if (storedToken != null && expiryString != null) {
        final expiryDate = DateTime.parse(expiryString);

        // Check if token is still valid
        if (DateTime.now().isBefore(expiryDate)) {
          customerAccessToken.value = storedToken;
          isLoggedIn.value = true;

          // Load customer data if available
          if (customerJson != null) {
            try {
              currentCustomer.value = Customer.fromJson(json.decode(customerJson));
            } catch (e) {
              print('Error parsing stored customer data: $e');
            }
          }

          print('User authentication restored from storage');
        } else {
          // Token expired, clear stored data
          await logout();
          print('Stored token expired, user logged out');
        }
      }
    } catch (e) {
      print('Error loading stored authentication: $e');
    }
  }

  /// Store authentication data in SharedPreferences
  Future<void> _storeAuthenticationData(String accessToken, String? expiresAt) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_accessTokenKey, accessToken);
      customerAccessToken.value = accessToken;
      isLoggedIn.value = true;

      if (expiresAt != null) {
        await prefs.setString(_tokenExpiryKey, expiresAt);
      }

      print('Authentication data stored successfully');
    } catch (e) {
      print('Error storing authentication data: $e');
    }
  }

  /// Fetch customer data using access token and store it
  Future<void> _fetchAndStoreCustomerData(String accessToken) async {
    try {
      final customerData = await _fetchCustomerProfile(accessToken);
      if (customerData != null) {
        currentCustomer.value = customerData;
        await _storeCustomerData(customerData);
      }
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  /// Fetch customer profile from Shopify using access token
  Future<Customer?> _fetchCustomerProfile(String accessToken) async {
    try {
      final result = await client.query(
        QueryOptions(
          document: gql(customerQuery(locale: languageCode)),
          variables: {
            'customerAccessToken': accessToken,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('Error fetching customer profile: ${result.exception}');
        return null;
      }

      final customerData = result.data?['customer'];
      if (customerData == null) {
        print('No customer data returned');
        return null;
      }

      return Customer(
        id: customerData['id'] as String,
        email: customerData['email'] as String,
        firstName: customerData['firstName'] as String? ?? '',
        lastName: customerData['lastName'] as String? ?? '',
        phone: customerData['phone'] as String?,
        acceptsMarketing: customerData['acceptsMarketing'] as bool? ?? false,
        createdAt: DateTime.parse(customerData['createdAt'] as String),
        updatedAt: DateTime.parse(customerData['updatedAt'] as String),
      );
    } catch (e) {
      print('Error parsing customer profile: $e');
      return null;
    }
  }

  /// Store customer data in SharedPreferences
  Future<void> _storeCustomerData(Customer customer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_customerDataKey, json.encode(customer.toJson()));
      currentCustomer.value = customer;
      print('Customer data stored successfully');
    } catch (e) {
      print('Error storing customer data: $e');
    }
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated => isLoggedIn.value && customerAccessToken.value.isNotEmpty;

  /// Get current access token
  String? get currentAccessToken => isAuthenticated ? customerAccessToken.value : null;

  /// Logout user and clear all stored data
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear stored authentication data
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_tokenExpiryKey);
      await prefs.remove(_customerDataKey);

      // Clear in-memory state
      customerAccessToken.value = '';
      isLoggedIn.value = false;
      currentCustomer.value = null;

      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  /// Check if token is expired and refresh if needed
  Future<bool> validateAndRefreshToken() async {
    try {
      if (!isAuthenticated) return false;

      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_tokenExpiryKey);

      if (expiryString != null) {
        final expiryDate = DateTime.parse(expiryString);

        // Check if token expires within the next 10 minutes
        final tenMinutesFromNow = DateTime.now().add(Duration(minutes: 10));

        if (expiryDate.isBefore(tenMinutesFromNow)) {
          print('Token is expiring soon, user should re-login');
          await logout();
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  String _parseShopifyError(String errorMessage) {
    // Parse Shopify error codes from their official documentation
    final upperError = errorMessage.toUpperCase();
    final lowerError = errorMessage.toLowerCase();

    // Official Shopify error codes
    if (upperError.contains('ALREADY_ENABLED')) {
      return 'This customer account is already active.';
    }

    if (upperError.contains('BAD_DOMAIN')) {
      return 'Please enter a valid email address. The domain name is invalid.';
    }

    if (upperError.contains('BLANK')) {
      return 'Please fill in all required fields.';
    }

    if (upperError.contains('CONTAINS_HTML_TAGS')) {
      return 'Please remove any HTML tags from your input.';
    }

    if (upperError.contains('CONTAINS_URL')) {
      return 'URLs are not allowed in this field.';
    }

    if (upperError.contains('CUSTOMER_DISABLED')) {
      return 'This customer account has been disabled. Please contact support.';
    }

    if (upperError.contains('INVALID')) {
      if (lowerError.contains('email')) {
        return 'Please enter a valid email address.';
      }
      return 'The information you entered is invalid. Please check and try again.';
    }

    if (upperError.contains('INVALID_MULTIPASS_REQUEST')) {
      return 'Authentication token is invalid. Please try logging in again.';
    }

    if (upperError.contains('NOT_FOUND')) {
      return 'The requested information could not be found.';
    }

    if (upperError.contains('PASSWORD_STARTS_OR_ENDS_WITH_WHITESPACE')) {
      return 'Password cannot start or end with spaces. Please remove extra spaces.';
    }

    if (upperError.contains('TAKEN')) {
      if (lowerError.contains('email')) {
        return 'Email already exists. Please use a different email or try logging in.';
      }
      return 'This information is already in use. Please try a different value.';
    }

    if (upperError.contains('TOKEN_INVALID')) {
      return 'The activation token is invalid or has expired. Please request a new one.';
    }

    if (upperError.contains('TOO_LONG')) {
      if (lowerError.contains('password')) {
        return 'Password is too long. Please use a shorter password.';
      }
      if (lowerError.contains('first') || lowerError.contains('name')) {
        return 'Name is too long. Please use a shorter name.';
      }
      return 'The input is too long. Please use fewer characters.';
    }

    if (upperError.contains('TOO_SHORT')) {
      if (lowerError.contains('password')) {
        return 'Password must be at least 8 characters long.';
      }
      return 'The input is too short. Please add more characters.';
    }

    if (upperError.contains('UNIDENTIFIED_CUSTOMER')) {
      return 'Customer account not found. Please check your information or create a new account.';
    }

    if (upperError.contains('THROTTLED') || lowerError.contains('limit exceeded')) {
      return 'Account creation limit reached. Please wait a few minutes before trying again.';
    }

    // Legacy error message parsing for backwards compatibility
    if (lowerError.contains('email') && lowerError.contains('taken')) {
      return 'Email already exists. Please use a different email or try logging in.';
    }

    if (lowerError.contains('email') && lowerError.contains('invalid')) {
      return 'Please enter a valid email address.';
    }

    if (lowerError.contains('password') && lowerError.contains('weak')) {
      return 'Password is too weak. Please use a stronger password.';
    }

    if (lowerError.contains('rate limit') || lowerError.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment before trying again.';
    }

    // Return original message if no specific pattern matches
    return errorMessage;
  }
}

// Login result class for better error handling and data management
class CustomerLoginResult {
  final bool success;
  final String? errorMessage;
  final CustomerErrorType? errorType;
  final String? accessToken;
  final String? expiresAt;

  CustomerLoginResult({
    required this.success,
    this.errorMessage,
    this.errorType,
    this.accessToken,
    this.expiresAt,
  });
}
