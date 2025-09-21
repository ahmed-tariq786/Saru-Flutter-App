import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/graphql/mutation/address_mutation.dart';
import 'package:saru/models/address.dart';
import 'package:saru/services/language.dart';
import 'package:saru/services/shopify_client.dart';

class AddressController extends GetxController {
  final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;

  RxList<CustomerAddress> addresses = <CustomerAddress>[].obs;
  Rxn<CustomerAddress> defaultAddress = Rxn<CustomerAddress>();

  Future<AddressCreationResult> createAddress({
    required String firstName,
    required String lastName,
    required String address1,
    required String city,
    required String country,
    required String zip,
    required String token,
    String? phone,
    String? company, // optional
    String? address2, // optional
    String? province, // optional
    String? provinceCode, // optional
  }) async {
    try {
      // Build the address input map
      final addressInput = {
        "firstName": firstName,
        "lastName": lastName,
        "address1": address1,
        "city": city,
        "country": country,
        "zip": zip,
        if (phone != null) "phone": phone,
        if (company != null) "company": company,
        if (address2 != null) "address2": address2,
        if (province != null) "province": province,
        if (provinceCode != null) "provinceCode": provinceCode,
      };

      final result = await client.mutate(
        MutationOptions(
          document: gql(customerAddressCreateMutation(locale: languageCode)),
          variables: {
            "customerAccessToken": token,
            "address": addressInput,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      // Check for GraphQL exceptions
      if (result.hasException) {
        print('GraphQL Exception: ${result.exception.toString()}');

        // Network error
        if (result.exception!.graphqlErrors.isEmpty && result.exception!.linkException != null) {
          return AddressCreationResult(
            success: false,
            errorMessage: S.current.networkErrorPleaseCheckYourConnectionAndTryAgain,
          );
        }

        // GraphQL errors
        final graphqlErrors = result.exception!.graphqlErrors;
        if (graphqlErrors.isNotEmpty) {
          final errorMessage = graphqlErrors.first.message;
          return AddressCreationResult(
            success: false,
            errorMessage: _parseShopifyError(errorMessage),
          );
        }

        return AddressCreationResult(
          success: false,
          errorMessage: S.current.anUnexpectedErrorOccurredPleaseTryAgain,
        );
      }

      // Check for Shopify customer address errors
      final customerAddressCreate = result.data?['customerAddressCreate'];
      final userErrors = customerAddressCreate?['customerUserErrors'] as List?;
      if (userErrors != null && userErrors.isNotEmpty) {
        final errorMessage = userErrors.first['message'] as String;
        return AddressCreationResult(
          success: false,
          errorMessage: _parseShopifyError(errorMessage),
        );
      }

      // Success
      return AddressCreationResult(
        success: true,
        errorMessage: "",
        address: customerAddressCreate?['customerAddress'] != null
            ? CustomerAddress.fromJson(customerAddressCreate!['customerAddress'])
            : null,
      );
    } catch (e) {
      print('Exception in createAddress: $e');
      return AddressCreationResult(
        success: false,
        errorMessage: S.current.anUnexpectedErrorOccurredPleaseTryAgain,
      );
    }
  }

  Future<AddressUpdateResult> setDefaultAddress({
    required String token,
    required String addressId,
  }) async {
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(
            customerDefaultAddressUpdateMutation(locale: languageCode),
          ),
          variables: {
            "customerAccessToken": token,
            "addressId": addressId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      // Handle GraphQL exceptions
      if (result.hasException) {
        print('GraphQL Exception: ${result.exception.toString()}');

        // Network error
        if (result.exception!.graphqlErrors.isEmpty && result.exception!.linkException != null) {
          return AddressUpdateResult(
            success: false,
            errorMessage: S.current.networkErrorPleaseCheckYourConnectionAndTryAgain,
          );
        }

        // GraphQL errors
        final graphqlErrors = result.exception!.graphqlErrors;
        if (graphqlErrors.isNotEmpty) {
          final errorMessage = graphqlErrors.first.message;
          return AddressUpdateResult(
            success: false,
            errorMessage: _parseShopifyError(errorMessage),
          );
        }

        return AddressUpdateResult(
          success: false,
          errorMessage: S.current.unexpectedErrorOccurred,
        );
      }

      final updateData = result.data?['customerDefaultAddressUpdate'];
      final userErrors = updateData?['customerUserErrors'] as List?;
      if (userErrors != null && userErrors.isNotEmpty) {
        final errorMessage = userErrors.first['message'] as String;
        return AddressUpdateResult(
          success: false,
          errorMessage: _parseShopifyError(errorMessage),
        );
      }

      // ✅ Success
      final defaultAddressJson = updateData?['customer']?['defaultAddress'];
      CustomerAddress? updatedDefault;
      if (defaultAddressJson != null) {
        updatedDefault = CustomerAddress.fromJson(defaultAddressJson);
      }

      return AddressUpdateResult(
        success: true,
        errorMessage: null,
        defaultAddress: updatedDefault,
      );
    } catch (e) {
      print("Exception in setDefaultAddress: $e");
      return AddressUpdateResult(
        success: false,
        errorMessage: S.current.anUnexpectedErrorOccurredPleaseTryAgain,
      );
    }
  }

  Future<GetAddressResult> getAddresses(String token, {int first = 10, String? afterCursor}) async {
    final result = await client.query(
      QueryOptions(
        document: gql(
          customerAddressesQuery(
            locale: languageCode,
            first: first,
            afterCursor: afterCursor,
          ),
        ),
        variables: {
          "customerAccessToken": token,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      print('GraphQL Exception: ${result.exception.toString()}');

      // Handle network errors
      if (result.exception!.graphqlErrors.isEmpty && result.exception!.linkException != null) {
        return GetAddressResult(
          success: false,
          errorMessage: S.current.networkErrorPleaseCheckYourConnectionAndTryAgain,
          addresses: [],
          pageInfo: PageInfo(hasNextPage: false, hasPreviousPage: false, startCursor: null, endCursor: null),
          defaultAddress: CustomerAddress(
            id: '',
            firstName: '',
            lastName: '',
            address1: '',
            city: '',
            country: '',
            zip: '',
            phone: '',
          ),
        );
      }

      // Handle GraphQL errors
      final graphqlErrors = result.exception!.graphqlErrors;
      if (graphqlErrors.isNotEmpty) {
        final errorMessage = graphqlErrors.first.message;
        return GetAddressResult(
          success: false,
          errorMessage: _parseShopifyError(errorMessage),
          addresses: [],
          pageInfo: PageInfo(hasNextPage: false, hasPreviousPage: false, startCursor: null, endCursor: null),
          defaultAddress: CustomerAddress(
            id: '',
            firstName: '',
            lastName: '',
            address1: '',
            city: '',
            country: '',
            zip: '',
            phone: '',
          ),
        );
      }

      return GetAddressResult(
        success: false,
        errorMessage: S.current.networkErrorPleaseCheckYourConnectionAndTryAgain,
        addresses: [],
        pageInfo: PageInfo(hasNextPage: false, hasPreviousPage: false, startCursor: null, endCursor: null),
        defaultAddress: CustomerAddress(
          id: '',
          firstName: '',
          lastName: '',
          address1: '',
          city: '',
          country: '',
          zip: '',
          phone: '',
        ),
      );
    }

    // ✅ Parse addresses properly from edges
    final edges = result.data?['customer']?['addresses']?['edges'] as List<dynamic>? ?? [];
    final addresses = edges
        .map((edge) => CustomerAddress.fromJson((edge as Map<String, dynamic>)['node'] as Map<String, dynamic>))
        .toList();

    // ✅ Parse pageInfo safely
    final pageInfoJson =
        result.data?['customer']?['addresses']?['pageInfo'] as Map<String, dynamic>? ??
        {
          "hasNextPage": false,
          "hasPreviousPage": false,
          "startCursor": null,
          "endCursor": null,
        };

    return GetAddressResult(
      success: true,
      errorMessage: null,
      addresses: addresses,
      pageInfo: PageInfo.fromJson(pageInfoJson),
      defaultAddress: result.data?['customer']?['defaultAddress'] != null
          ? CustomerAddress.fromJson(result.data!['customer']['defaultAddress'])
          : CustomerAddress(
              id: '',
              firstName: '',
              lastName: '',
              address1: '',
              city: '',
              country: '',
              zip: '',
              phone: '',
            ),
    );
  }

  String _parseShopifyError(String errorMessage) {
    // Parse Shopify error codes from their official documentation
    final upperError = errorMessage.toUpperCase();
    final lowerError = errorMessage.toLowerCase();

    // Official Shopify error codes
    if (upperError.contains('ALREADY_ENABLED')) {
      return S.current.thisCustomerAccountIsAlreadyActive;
    }

    if (upperError.contains('BAD_DOMAIN')) {
      return S.current.pleaseEnterAValidEmailAddressTheDomainNameIs;
    }

    if (upperError.contains('BLANK')) {
      return S.current.pleaseFillInAllRequiredFields;
    }

    if (upperError.contains('CONTAINS_HTML_TAGS')) {
      return S.current.pleaseRemoveAnyHtmlTagsFromYourInput;
    }

    if (upperError.contains('CONTAINS_URL')) {
      return S.current.urlsAreNotAllowedInThisField;
    }

    if (upperError.contains('CUSTOMER_DISABLED')) {
      return S.current.thisCustomerAccountHasBeenDisabledPleaseContactSupport;
    }

    if (upperError.contains('INVALID')) {
      if (lowerError.contains('email')) {
        return 'Please enter a valid email address.';
      }
      return S.current.theInformationYouEnteredIsInvalidPleaseCheckAndTry;
    }

    if (upperError.contains('INVALID_MULTIPASS_REQUEST')) {
      return S.current.authenticationTokenIsInvalidPleaseTryLoggingInAgain;
    }

    if (upperError.contains('NOT_FOUND')) {
      return S.current.theRequestedInformationCouldNotBeFound;
    }

    if (upperError.contains('PASSWORD_STARTS_OR_ENDS_WITH_WHITESPACE')) {
      return S.current.passwordCannotStartOrEndWithSpacesPleaseRemoveExtra;
    }

    if (upperError.contains('TAKEN')) {
      if (lowerError.contains('email')) {
        return S.current.emailAlreadyExistsPleaseUseADifferentEmailOrTry;
      }
      return S.current.thisInformationIsAlreadyInUsePleaseTryADifferent;
    }

    if (upperError.contains('TOKEN_INVALID')) {
      return S.current.theActivationTokenIsInvalidOrHasExpiredPleaseRequest;
    }

    if (upperError.contains('TOO_LONG')) {
      if (lowerError.contains('password')) {
        return S.current.passwordIsTooLongPleaseUseAShorterPassword;
      }
      if (lowerError.contains('first') || lowerError.contains('name')) {
        return S.current.nameIsTooLongPleaseUseAShorterName;
      }
      return S.current.theInputIsTooLongPleaseUseFewerCharacters;
    }

    if (upperError.contains('TOO_SHORT')) {
      if (lowerError.contains('password')) {
        return S.current.passwordMustBeAtLeast8CharactersLong;
      }
      return S.current.theInputIsTooShortPleaseAddMoreCharacters;
    }

    if (upperError.contains('UNIDENTIFIED_CUSTOMER')) {
      return S.current.customerAccountNotFoundPleaseCheckYourInformationOrCreate;
    }

    if (upperError.contains('THROTTLED') || lowerError.contains('limit exceeded')) {
      return S.current.accountCreationLimitReachedPleaseWaitAFewMinutesBefore;
    }

    // Legacy error message parsing for backwards compatibility
    if (lowerError.contains('email') && lowerError.contains('taken')) {
      return S.current.emailAlreadyExistsPleaseUseADifferentEmailOrTry;
    }

    if (lowerError.contains('email') && lowerError.contains('invalid')) {
      return S.current.pleaseEnterAValidEmailAddress;
    }

    if (lowerError.contains('password') && lowerError.contains('weak')) {
      return S.current.passwordIsTooWeakPleaseUseAStrongerPassword;
    }

    if (lowerError.contains('rate limit') || lowerError.contains('too many requests')) {
      return S.current.tooManyAttemptsPleaseWaitAMomentBeforeTryingAgain;
    }

    // Return original message if no specific pattern matches
    return errorMessage;
  }

  Future<AddressDeletionResult> deleteAddress({
    required String token,
    required String addressId,
  }) async {
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(customerAddressDeleteMutation(locale: languageCode)),
          variables: {
            "customerAccessToken": token,
            "id": addressId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print("GraphQL Exception: ${result.exception}");
        return AddressDeletionResult(
          success: false,
          errorMessage: S.current.anErrorOccurredWhileDeletingTheAddressPleaseTryAgain,
        );
      }

      final data = result.data?['customerAddressDelete'];
      final userErrors = data?['customerUserErrors'] as List?;
      if (userErrors != null && userErrors.isNotEmpty) {
        print("Shopify Error: ${userErrors.first['message']}");
        return AddressDeletionResult(
          success: false,
          errorMessage: _parseShopifyError(userErrors.first['message']),
        );
      }

      final deletedId = data?['deletedCustomerAddressId'];
      if (deletedId != null) {
        return AddressDeletionResult(
          success: true,
          errorMessage: null,
        );
      }

      return AddressDeletionResult(
        success: false,
        errorMessage: S.current.anUnknownErrorOccurred,
      );
    } catch (e) {
      print("Exception deleting address: $e");
      return AddressDeletionResult(
        success: false,
        errorMessage: S.current.anErrorOccurredWhileDeletingTheAddressPleaseTryAgain,
      );
    }
  }

  Future<AddressDeletionResult> updateAddress({
    required String token,
    required String addressId,
    required Map<String, dynamic> addressInput,
  }) async {
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(customerAddressUpdateMutation(locale: languageCode)),
          variables: {
            "customerAccessToken": token,
            "id": addressId,
            "address": addressInput,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print("GraphQL Exception: ${result.exception}");
        return AddressDeletionResult(
          success: false,
          errorMessage: S.current.anErrorOccurredWhileUpdatingTheAddressPleaseTryAgain,
        );
      }

      final data = result.data?['customerAddressUpdate'];
      final userErrors = data?['customerUserErrors'] as List?;
      if (userErrors != null && userErrors.isNotEmpty) {
        print("Shopify Error: ${userErrors.first['message']}");
        return AddressDeletionResult(
          success: false,
          errorMessage: _parseShopifyError(userErrors.first['message']),
        );
      }

      final updated = data?['customerAddress'];
      if (updated != null) {
        return AddressDeletionResult(
          success: true,
          errorMessage: null,
        );
      }

      return AddressDeletionResult(
        success: false,
        errorMessage: S.current.anUnknownErrorOccurred,
      );
    } catch (e) {
      print("Exception deleting address: $e");
      return AddressDeletionResult(
        success: false,
        errorMessage: S.current.anErrorOccurredWhileUpdatingTheAddressPleaseTryAgain,
      );
    }
  }
}
