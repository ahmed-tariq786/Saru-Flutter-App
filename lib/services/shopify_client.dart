import 'package:graphql_flutter/graphql_flutter.dart';

final HttpLink httpLink = HttpLink(
  'https://xtjhqp-rk.myshopify.com/api/2023-07/graphql.json',
  defaultHeaders: {
    'X-Shopify-Storefront-Access-Token': 'ee0dce4e1cb8f0f37db8a06cd629c822',
    'Shopify-Storefront-Buyer-Country-Code': 'KW', // 👈 Kuwait for KWD
  },
);

final GraphQLClient client = GraphQLClient(
  cache: GraphQLCache(store: InMemoryStore()), // Fresh cache store
  link: httpLink,
);
