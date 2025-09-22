import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:saru/graphql/mutation/cart_buyer.dart';
import 'package:saru/graphql/mutation/cart_mutation.dart';
import 'package:saru/models/cart_line.dart';
import 'package:saru/models/product.dart';
import 'package:saru/services/account_service.dart';
import 'package:saru/services/discount_service.dart';
import 'package:saru/services/language.dart';
import 'package:saru/services/shopify_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartController extends GetxController {
  RxString cartId = ''.obs;
  RxString checkoutUrl = ''.obs;
  var lines = <CartLine>[].obs;

  final accountController = Get.put(AccountController());

  RxString subtotal = '0'.obs;

  RxString total = '0'.obs;

  RxString currencyCode = 'KWD'.obs;

  RxInt totalQuantity = 0.obs;

  RxString totalDiscountAmount = '0'.obs;

  RxList<Product> alsoLikeCategory = <Product>[].obs;
  final discountController = Get.put(DiscountController());

  // Flag to prevent UI updates during checkout URL refresh
  bool _isRefreshingCheckout = false;

  /// Calculate total discount amount from cart data
  void _calculateDiscountAmount(dynamic cartJson) {
    double originalTotal = 0.0;
    for (var line in lines) {
      originalTotal += line.merchandise.price * line.quantity;
    }

    final cost = cartJson['cost'];
    final currentTotal = double.tryParse(cost['totalAmount']?['amount']?.toString() ?? '0') ?? 0.0;

    final discountAmount = originalTotal - currentTotal;

    totalDiscountAmount.value = discountAmount > 0 ? discountAmount.toStringAsFixed(3) : "0.000";
  }

  /// Force refresh checkout URL by removing and re-adding first cart item (no UI flicker)
  Future<void> forceRefreshCheckoutUrl() async {
    if (lines.isEmpty) return;

    try {
      final savedLines = List<CartLine>.from(lines);
      final savedSubtotal = subtotal.value;
      final savedTotal = total.value;
      final savedQuantity = totalQuantity.value;
      final savedDiscount = totalDiscountAmount.value;

      _isRefreshingCheckout = true;

      final firstLine = lines.first;
      final merchandiseId = firstLine.merchandise.id;
      final quantity = firstLine.quantity;

      await removeCartLines(cartId.value, [firstLine.id]);

      final newCartLineData = await _addToCartAndGetNewLine(cartId.value, merchandiseId, quantity);

      if (newCartLineData != null) {
        savedLines[0] = newCartLineData;
      }

      _isRefreshingCheckout = false;
      lines.value = savedLines;
      subtotal.value = savedSubtotal;
      total.value = savedTotal;
      totalQuantity.value = savedQuantity;

      await fetchCart(cartId.value);
    } catch (e) {
      _isRefreshingCheckout = false;
      await fetchCart(cartId.value);
    }
  }

  /// Special version of addToCart that returns the new cart line data
  Future<CartLine?> _addToCartAndGetNewLine(String cartId, String variantId, int quantity) async {
    try {
      final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;
      final result = await client.mutate(
        MutationOptions(
          document: gql(
            addLinesToCartMutation(locale: languageCode),
          ),
          variables: {
            "cartId": cartId,
            "lines": [
              {
                "merchandiseId": variantId,
                "quantity": quantity,
              },
            ],
          },
        ),
      );

      if (result.hasException) {
        print("❌ Error adding to cart: ${result.exception}");
        return null;
      }

      // Check for user errors first
      final userErrors = result.data?['cartLinesAdd']?['userErrors'];
      if (userErrors != null && userErrors.isNotEmpty) {
        print("❌ User errors: $userErrors");
        return null;
      }

      final cartJson = result.data?['cartLinesAdd']?['cart'];
      if (cartJson == null) {
        print("❌ cartJson is null - full response: ${result.data}");
        return null;
      }

      // Update cart data (checkout URL)
      final updatedCartId = cartJson['id'] as String?;
      final updatedCheckoutUrl = cartJson['checkoutUrl'] as String?;

      if (updatedCartId != null) {
        this.cartId.value = updatedCartId;
      }

      if (updatedCheckoutUrl != null) {
        checkoutUrl.value = updatedCheckoutUrl;
      }

      // Save updated cart data
      if (updatedCartId != null && updatedCheckoutUrl != null) {
        await _saveCheckoutCartIdUrl(updatedCheckoutUrl, updatedCartId);
      }

      // Find and return the newly added cart line
      final cartLines = cartJson['lines']?['edges'] as List?;
      if (cartLines != null && cartLines.isNotEmpty) {
        // Find the cart line that matches our merchandise
        for (var edge in cartLines) {
          final lineData = edge['node'];
          if (lineData != null) {
            try {
              final cartLine = CartLine.fromJson(lineData);
              // Check if this is the line we just added
              if (cartLine.merchandise.id == variantId && cartLine.quantity == quantity) {
                return cartLine;
              }
            } catch (e) {
              print("❌ Error parsing cart line: $e");
            }
          }
        }
      }

      return null;
    } catch (e) {
      print("❌ Error adding to cart: $e");
      return null;
    }
  }

  Future<void> createCart() async {
    try {
      final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;

      // Default input
      final input = <String, dynamic>{};

      // If user is logged in, attach identity immediately
      final token = accountController.customerAccessToken.value;
      if (token.isNotEmpty) {
        input['buyerIdentity'] = {
          "customerAccessToken": token,
        };
      }

      print(input);

      final result = await client.mutate(
        MutationOptions(
          document: gql(createCartMutation(locale: languageCode)),
          variables: {"input": input},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final cartData = result.data?['cartCreate']?['cart'];
      if (cartData == null) return;

      cartId.value = cartData['id'] as String;
      checkoutUrl.value = cartData['checkoutUrl'] as String;

      await _saveCheckoutCartIdUrl(checkoutUrl.value, cartId.value);
    } catch (e) {
      print("Error creating cart: $e");
    }
  }

  Future<void> addToCart(String cartId, String variantId, int quantity) async {
    try {
      final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;
      final result = await client.mutate(
        MutationOptions(
          document: gql(
            addLinesToCartMutation(locale: languageCode),
          ),
          variables: {
            "cartId": cartId,
            "lines": [
              {
                "merchandiseId": variantId,
                "quantity": quantity,
              },
            ],
          },
        ),
      );

      if (result.hasException) {
        print("❌ Error adding to cart: ${result.exception}");
        return;
      }

      // Check for user errors first
      final userErrors = result.data?['cartLinesAdd']?['userErrors'];
      if (userErrors != null && userErrors.isNotEmpty) {
        print("❌ User errors: $userErrors");
        return;
      }

      final cartJson = result.data?['cartLinesAdd']?['cart'];
      if (cartJson == null) {
        print("❌ cartJson is null - full response: ${result.data}");
        return;
      }

      // Update cart data
      final updatedCartId = cartJson['id'] as String?;
      final updatedCheckoutUrl = cartJson['checkoutUrl'] as String?;

      if (updatedCartId != null) {
        this.cartId.value = updatedCartId;
      }

      if (updatedCheckoutUrl != null) {
        checkoutUrl.value = updatedCheckoutUrl;
      }

      // Only update UI if not refreshing checkout (prevents flicker)
      if (!_isRefreshingCheckout) {
        int totalQty = 0;
        // Parse cart lines
        final cartLines = cartJson['lines']?['edges'] as List?;
        if (cartLines != null) {
          lines.clear();
          for (var edge in cartLines) {
            final lineData = edge['node'];
            if (lineData != null) {
              try {
                final cartLine = CartLine.fromJson(lineData);
                lines.add(cartLine);
                totalQty += cartLine.quantity;
              } catch (e) {
                print("❌ Error parsing cart line: $e");
              }
            }
          }
        }

        totalQuantity.value = totalQty;

        final cost = cartJson['cost'];
        subtotal.value = cost['subtotalAmount']?['amount'] ?? "0";
        total.value = cost['totalAmount']?['amount'] ?? "0";
        currencyCode.value = cost['subtotalAmount']?['currencyCode'] ?? "KWD";

        // Calculate discount amount
        _calculateDiscountAmount(cartJson);
      }

      // Save updated cart data
      if (updatedCartId != null && updatedCheckoutUrl != null) {
        await _saveCheckoutCartIdUrl(updatedCheckoutUrl, updatedCartId);
      }
    } catch (e) {
      print("❌ Error adding to cart: $e");
    }
  }

  Future<void> updateCartLines(String cartId, String lineId, int quantity) async {
    try {
      final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;
      final result = await client.mutate(
        MutationOptions(
          document: gql(
            updateCartLinesMutation(locale: languageCode),
          ),
          variables: {
            "cartId": cartId,
            "lines": [
              {
                "id": lineId,
                "quantity": quantity,
              },
            ],
          },
        ),
      );

      if (result.hasException) {
        print("❌ Error updating cart: ${result.exception}");
        return;
      }

      // Check for user errors first
      final userErrors = result.data?['cartLinesUpdate']?['userErrors'];
      if (userErrors != null && userErrors.isNotEmpty) {
        print("❌ User errors: $userErrors");
        return;
      }

      final cartJson = result.data?['cartLinesUpdate']?['cart'];
      if (cartJson == null) {
        print("❌ cartJson is null - full response: ${result.data}");
        return;
      }

      // Update cart data
      final updatedCartId = cartJson['id'] as String?;
      final updatedCheckoutUrl = cartJson['checkoutUrl'] as String?;

      if (updatedCartId != null) {
        this.cartId.value = updatedCartId;
      }

      if (updatedCheckoutUrl != null) {
        checkoutUrl.value = updatedCheckoutUrl;
      }
      int totalQty = 0;
      // Parse cart lines
      final cartLines = cartJson['lines']?['edges'] as List?;
      if (cartLines != null) {
        lines.clear();
        for (var edge in cartLines) {
          final lineData = edge['node'];
          if (lineData != null) {
            try {
              final cartLine = CartLine.fromJson(lineData);
              lines.add(cartLine);
              totalQty += cartLine.quantity;
            } catch (e) {
              print("❌ Error parsing cart line: $e");
            }
          }
        }
      }

      totalQuantity.value = totalQty;

      final cost = cartJson['cost'];
      subtotal.value = cost['subtotalAmount']?['amount'] ?? "0";
      total.value = cost['totalAmount']?['amount'] ?? "0";
      currencyCode.value = cost['subtotalAmount']?['currencyCode'] ?? "KWD";

      // Calculate discount amount
      _calculateDiscountAmount(cartJson);

      // Save updated cart data
      if (updatedCartId != null && updatedCheckoutUrl != null) {
        await _saveCheckoutCartIdUrl(updatedCheckoutUrl, updatedCartId);
      }
    } catch (e) {
      print("❌ Error updating cart: $e");
    }
  }

  Future<void> removeCartLines(String cartId, List<String> lineIds) async {
    try {
      final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;
      final result = await client.mutate(
        MutationOptions(
          document: gql(
            removeCartLinesMutation(locale: languageCode),
          ),
          variables: {
            "cartId": cartId,
            "lineIds": lineIds,
          },
        ),
      );

      if (result.hasException) {
        print("❌ Error removing from cart: ${result.exception}");
        return;
      }

      // Check for user errors first
      final userErrors = result.data?['cartLinesRemove']?['userErrors'];
      if (userErrors != null && userErrors.isNotEmpty) {
        print("❌ User errors: $userErrors");
        return;
      }

      final cartJson = result.data?['cartLinesRemove']?['cart'];
      if (cartJson == null) {
        print("❌ cartJson is null - full response: ${result.data}");
        return;
      }

      // Update cart data
      final updatedCartId = cartJson['id'] as String?;
      final updatedCheckoutUrl = cartJson['checkoutUrl'] as String?;

      if (updatedCartId != null) {
        this.cartId.value = updatedCartId;
      }

      if (updatedCheckoutUrl != null) {
        checkoutUrl.value = updatedCheckoutUrl;
      }

      // Only update UI if not refreshing checkout (prevents flicker)
      if (!_isRefreshingCheckout) {
        int totalQty = 0;
        // Parse cart lines
        final cartLines = cartJson['lines']?['edges'] as List?;
        if (cartLines != null) {
          lines.clear();
          for (var edge in cartLines) {
            final lineData = edge['node'];
            if (lineData != null) {
              try {
                final cartLine = CartLine.fromJson(lineData);
                lines.add(cartLine);
                totalQty += cartLine.quantity;
              } catch (e) {
                print("❌ Error parsing cart line: $e");
              }
            }
          }
        }

        totalQuantity.value = totalQty;

        final cost = cartJson['cost'];
        subtotal.value = cost['subtotalAmount']?['amount'] ?? "0";
        total.value = cost['totalAmount']?['amount'] ?? "0";
        currencyCode.value = cost['subtotalAmount']?['currencyCode'] ?? "KWD";

        // Calculate discount amount
        _calculateDiscountAmount(cartJson);
      }

      // Save updated cart data
      if (updatedCartId != null && updatedCheckoutUrl != null) {
        await _saveCheckoutCartIdUrl(updatedCheckoutUrl, updatedCartId);
      }
    } catch (e) {
      print("❌ Error removing from cart: $e");
    }
  }

  Future<void> fetchCart(String cartId) async {
    try {
      final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;

      final result = await client.query(
        QueryOptions(
          document: gql(
            getCartQuery(locale: languageCode),
          ),
          variables: {
            "cartId": cartId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print("❌ Error fetching cart: ${result.exception}");
        return;
      }

      final cartJson = result.data?['cart'];
      if (cartJson == null) {
        print("❌ Cart not found or is null");
        return;
      }

      // Update cart data
      final fetchedCartId = cartJson['id'] as String?;
      final fetchedCheckoutUrl = cartJson['checkoutUrl'] as String?;

      if (fetchedCartId != null) {
        this.cartId.value = fetchedCartId;
      }

      if (fetchedCheckoutUrl != null) {
        checkoutUrl.value = fetchedCheckoutUrl;
      }
      int totalQty = 0;
      // Parse cart lines
      final cartLines = cartJson['lines']?['edges'] as List?;
      if (cartLines != null) {
        lines.clear();
        for (var edge in cartLines) {
          final lineData = edge['node'];
          if (lineData != null) {
            try {
              final cartLine = CartLine.fromJson(lineData);
              lines.add(cartLine);
              totalQty += cartLine.quantity;
            } catch (e) {
              print("❌ Error parsing cart line: $e");
            }
          }
        }
      }

      // Update applied discounts
      discountController.appliedDiscountCodes.value =
          (cartJson['discountCodes'] as List?)
              ?.where((d) => d['applicable'] == true)
              .map((d) => d['code'] as String)
              .toList() ??
          [];

      totalQuantity.value = totalQty;

      final cost = cartJson['cost'];
      subtotal.value = cost['subtotalAmount']?['amount'] ?? "0";
      total.value = cost['totalAmount']?['amount'] ?? "0";
      currencyCode.value = cost['subtotalAmount']?['currencyCode'] ?? "KWD";

      // Calculate discount amount
      _calculateDiscountAmount(cartJson);
    } catch (e) {
      print("❌ Error fetching cart: $e");
    }
  }

  // ==================== SHARED PREFERENCES FUNCTIONS ====================

  /// Save checkout URL and cartId to SharedPreferences
  Future<void> _saveCheckoutCartIdUrl(String url, String cartId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('checkout_url', url);
      await prefs.setString('cart_id', cartId);
    } catch (e) {
      print("Error saving checkout URL: $e");
    }
  }

  /// Check if cart exists in SharedPreferences
  bool hasExistingCart() {
    try {
      return cartId.value.isNotEmpty && checkoutUrl.value.isNotEmpty;
    } catch (e) {
      print("Error checking existing cart: $e");
      return false;
    }
  }

  /// Load existing cart data from SharedPreferences
  Future<void> loadExistingCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCartId = prefs.getString('cart_id');
      final savedCheckoutUrl = prefs.getString('checkout_url');

      if (savedCartId != null) {
        cartId.value = savedCartId;
      }

      if (savedCheckoutUrl != null) {
        checkoutUrl.value = savedCheckoutUrl;
      }
    } catch (e) {
      print("Error loading existing cart: $e");
    }
  }

  /// Clear cart data from SharedPreferences (useful for logout/reset)
  Future<void> clearCartData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cart_id');
      await prefs.remove('checkout_url');

      cartId.value = '';
      checkoutUrl.value = '';
    } catch (e) {
      print("Error clearing cart data: $e");
    }
  }

  /// Update cart data and save to SharedPreferences
  Future<void> updateCartData(String newCartId, String newCheckoutUrl) async {
    cartId.value = newCartId;
    checkoutUrl.value = newCheckoutUrl;

    await _saveCheckoutCartIdUrl(
      newCheckoutUrl,
      newCartId,
    );
  }

  // ==================== Link cart with the account ====================

  Future<bool> attachCartToCustomer(String cartId, String customerAccessToken) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql(
          cartBuyerIdentityUpdateMutation,
        ),
        variables: {
          "cartId": cartId, // 👈 pass as variable
          "buyerIdentity": {
            "customerAccessToken": customerAccessToken,
          },
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      print(result.exception.toString());
      return false;
    }

    final errors = result.data?['cartBuyerIdentityUpdate']?['userErrors'] as List?;
    if (errors != null && errors.isNotEmpty) {
      print("Cart attach error: ${errors.first['code']}");
      return false;
    }

    return true;
  }

  Future<bool> deattachCartToCustomer(
    String cartId,
  ) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql(
          cartBuyerIdentitydeleteMutation,
        ),
        variables: {
          "cartId": cartId, // 👈 pass as variable
          "buyerIdentity": {
            "customerAccessToken": null, // 👈 explicitly remove link
          },
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      print(result.exception.toString());
      return false;
    }

    final errors = result.data?['cartBuyerIdentityUpdate']?['userErrors'] as List?;
    if (errors != null && errors.isNotEmpty) {
      print("Cart attach error: ${errors.first['code']}");
      return false;
    }

    return true;
  }
}
