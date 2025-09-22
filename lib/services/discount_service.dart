import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:saru/graphql/mutation/discount_mutation.dart';
import 'package:saru/services/language.dart';
import 'package:saru/services/shopify_client.dart';

class DiscountController extends GetxController {
  RxList<String> appliedDiscountCodes = <String>[].obs;
  RxBool isApplyingDiscount = false.obs;
  RxString lastDiscountError = ''.obs;

  Future<Map<String, dynamic>?> applyDiscount(String discountCode, String cartId) async {
    try {
      isApplyingDiscount.value = true;
      lastDiscountError.value = '';

      final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;

      // Always append to existing codes
      final discountCodes = [...appliedDiscountCodes, discountCode];

      final result = await client.mutate(
        MutationOptions(
          document: gql(cartDiscountCodesUpdateMutation(locale: languageCode)),
          variables: {
            "cartId": cartId,
            "discountCodes": discountCodes,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final error = result.exception.toString();
        lastDiscountError.value = "Failed to apply discount: $error";
        print("❌ GraphQL error: $error");
        return {'success': false, 'error': error};
      }

      final updateData = result.data?['cartDiscountCodesUpdate'];
      if (updateData == null) {
        lastDiscountError.value = "No response from server";
        return {'success': false, 'error': 'No response from server'};
      }

      // Check userErrors from Shopify
      final userErrors = updateData['userErrors'] as List?;
      if (userErrors != null && userErrors.isNotEmpty) {
        final errorMessage = userErrors[0]['code'] ?? 'Unknown discount error';
        lastDiscountError.value = errorMessage;
        print("❌ Discount error: $errorMessage");
        return {'success': false, 'error': errorMessage};
      }

      // Parse cart data
      final cartData = updateData['cart'];
      if (cartData == null) {
        lastDiscountError.value = "Cart data missing after discount update";
        return {'success': false, 'error': 'Cart data missing'};
      }

      // Update applied discounts
      appliedDiscountCodes.value =
          (cartData['discountCodes'] as List?)
              ?.where((d) => d['applicable'] == true)
              .map((d) => d['code'] as String)
              .toList() ??
          [];

      final wasApplied = appliedDiscountCodes.contains(discountCode);

      return {
        'success': wasApplied,
        'cart': cartData,
        'appliedCodes': appliedDiscountCodes,
        'error': wasApplied ? null : 'Invalid or expired coupon code',
      };
    } catch (e) {
      lastDiscountError.value = "Unexpected error: $e";
      print("❌ Unexpected error applying discount: $e");
      return {'success': false, 'error': e.toString()};
    } finally {
      isApplyingDiscount.value = false;
    }
  }

  Future<Map<String, dynamic>?> removeDiscount(String discountCode, String cartId) async {
    try {
      isApplyingDiscount.value = true;
      lastDiscountError.value = '';

      final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;

      // Remove the discount code from the list - explicitly create empty list if removing all
      final discountCodes = appliedDiscountCodes.where((code) => code != discountCode).toList();

      final result = await client.mutate(
        MutationOptions(
          document: gql(
            cartDiscountCodesUpdateMutation(locale: languageCode),
          ),
          variables: {
            "cartId": cartId,
            "discountCodes": discountCodes,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        lastDiscountError.value = "Failed to remove discount: ${result.exception.toString()}";
        print("❌ Error removing discount: ${result.exception}");
        return null;
      }

      final cartData = result.data?['cartDiscountCodesUpdate']?['cart'];
      if (cartData == null) {
        lastDiscountError.value = "Failed to get cart data";
        print("❌ Cart data is null");
        return null;
      }

      // Clear error state when removing discount
      lastDiscountError.value = '';

      // Update applied discount codes
      final discountCodesData = cartData['discountCodes'] as List?;
      if (discountCodesData != null) {
        appliedDiscountCodes.value = discountCodesData
            .where((discount) => discount['applicable'] == true)
            .map((discount) => discount['code'] as String)
            .toList();
      } else {
        // If no discount codes data, clear the applied codes
        appliedDiscountCodes.clear();
      }

      return {
        'success': true,
        'cart': cartData,
        'appliedCodes': appliedDiscountCodes,
      };
    } catch (e) {
      lastDiscountError.value = "Error removing discount: $e";
      print("❌ Error removing discount: $e");
      return null;
    } finally {
      isApplyingDiscount.value = false;
    }
  }

  void clearDiscountError() {
    lastDiscountError.value = '';
  }

  void clearAppliedCodes() {
    appliedDiscountCodes.clear();
  }
}
