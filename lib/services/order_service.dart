import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:saru/graphql/queries/order_queries.dart';
import 'package:saru/models/address.dart';
import 'package:saru/models/orders.dart';
import 'package:saru/services/language.dart';
import 'package:saru/services/shopify_client.dart';

class OrderController extends GetxController {
  final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;
  RxMap<String, dynamic> orderData = <String, dynamic>{}.obs;

  RxList<OrderSummary> orders = <OrderSummary>[].obs;

  Future<GetOrdersResult> fetchOrders(String token, {int first = 10, String? afterCursor}) async {
    try {
      final result = await client.query(
        QueryOptions(
          document: gql(
            customerOrdersQuery(
              locale: languageCode,
              afterCursor: afterCursor,
              first: first,
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
        return GetOrdersResult(
          success: false,
          errorMessage: result.exception.toString(),
          orders: [],
          pageInfo: PageInfo(hasNextPage: false, hasPreviousPage: false, startCursor: null, endCursor: null),
        );
      }

      final edges = result.data?['customer']?['orders']?['edges'] as List?;
      final pageInfoJson = result.data?['customer']?['orders']?['pageInfo'];

      return GetOrdersResult(
        success: true,
        errorMessage: null,
        orders: edges?.map((edge) => OrderSummary.fromJson(edge['node'] as Map<String, dynamic>)).toList() ?? [],
        pageInfo: PageInfo.fromJson(pageInfoJson),
      );
    } catch (e) {
      print('Error fetching order data: $e');
      return GetOrdersResult(
        success: false,
        errorMessage: e.toString(),
        orders: [],
        pageInfo: PageInfo(hasNextPage: false, hasPreviousPage: false, startCursor: null, endCursor: null),
      );
    }
  }
}
