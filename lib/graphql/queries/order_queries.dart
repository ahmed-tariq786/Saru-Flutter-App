String customerOrdersQuery({String locale = 'EN', int first = 10, String? afterCursor}) {
  // Only include after: "..." if afterCursor is provided
  final afterClause = afterCursor != null ? 'after: "$afterCursor",' : '';

  return '''
  query customerOrders(\$customerAccessToken: String!) 
  @inContext(language: ${locale.toUpperCase()}) {
    customer(customerAccessToken: \$customerAccessToken) {
      id
      orders(first: $first, $afterClause sortKey: PROCESSED_AT, reverse: true) {
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
        edges {
          node {
            id
            name
            orderNumber
            processedAt
            financialStatus
            fulfillmentStatus
            statusUrl
            canceledAt
            cancelReason

            
            currentSubtotalPrice {
              amount
              currencyCode
            }
            totalRefunded {
              amount
              currencyCode
            }
            currentTotalPrice {
              amount
              currencyCode
            }
            currentTotalShippingPrice {
              amount
              currencyCode
            }
            billingAddress {
              firstName
              lastName
              address1
              address2
              province
              phone
              city
              country
              zip
            }
            shippingAddress {
              firstName
              lastName
              address1
              address2
              province
              phone
              city
              country
              zip
            }
            # 👇 Get applied discounts (codes, automatic, etc.)
            discountApplications(first: 10) {
              edges {
                node {
                  __typename
                  ... on DiscountCodeApplication {
                    code
                    applicable
                  }
                  ... on ManualDiscountApplication {
                    title
                  }
                  ... on AutomaticDiscountApplication {
                    title
                  }
                }
              }
            }
            lineItems(first: 20) {
              edges {
                node {
                  title
                  quantity
                  originalTotalPrice {
                    amount
                    currencyCode
                  }
                  discountedTotalPrice {
                    amount
                    currencyCode
                  }
                  discountAllocations {
                    allocatedAmount {
                      amount
                      currencyCode
                    }
                    discountApplication {
                      __typename
                      ... on DiscountCodeApplication {
                        code
                        applicable
                      }
                      ... on ManualDiscountApplication {
                        title
                      }
                      ... on AutomaticDiscountApplication {
                        title
                      }
                    }
                  }
                  variant {
                    id
                    title
                    sku
                    availableForSale
                    quantityAvailable
                    price {
                      amount
                      currencyCode
                    }
                    compareAtPrice {
                      amount
                      currencyCode
                    }
                    image {
                      url
                      altText
                    }
                    selectedOptions {
                      name
                      value
                    }
                    product {
                      id
                      title
                      vendor
                      tags
                      descriptionHtml
                      images(first: 5) {
                        edges {
                          node {
                            url
                            altText
                          }
                        }
                      }
                      collections(first: 5) {
                        edges {
                          node {
                            title
                          }
                        }
                      }
                      specifications: metafield(namespace: "custom", key: "specifications2") {
                        value
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  ''';
}
