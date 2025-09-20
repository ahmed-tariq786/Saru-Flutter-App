String createCustomerMutation({String locale = 'EN'}) {
  return '''
  mutation customerCreate(\$input: CustomerCreateInput!) @inContext(language: ${locale.toUpperCase()}) {
    customerCreate(input: \$input) {
      customer {
        id
        email
        firstName
        lastName
      }
      customerUserErrors {
        code
        field
        message
      }
    }
  }
  ''';
}

String customerLoginMutation({String locale = 'EN'}) {
  return '''
  mutation customerAccessTokenCreate(\$input: CustomerAccessTokenCreateInput!) {
    customerAccessTokenCreate(input: \$input) {
      customerAccessToken {
        accessToken
        expiresAt
      }
      customerUserErrors {
        field
        message
      }
    }
  }
  ''';
}

String customerQuery({String locale = 'EN'}) {
  return '''
  query customer(\$customerAccessToken: String!) 
  @inContext(language: ${locale.toUpperCase()}) {
    customer(customerAccessToken: \$customerAccessToken) {
      id
      email
      firstName
      lastName
      phone
      acceptsMarketing
      createdAt
      updatedAt
      tags
      
      defaultAddress {
        id
        address1
        city
      }
    }
  }
  ''';
}

String customerOrdersQuery({String locale = 'EN', int first = 10, String? after}) {
  return '''
  query customerOrders(\$customerAccessToken: String!, \$first: Int!, \$after: String) @inContext(language: ${locale.toUpperCase()}) {
    customer(customerAccessToken: \$customerAccessToken) {
      id
      orders(first: \$first, after: \$after, sortKey: PROCESSED_AT, reverse: true) {
        edges {
          node {
            id
            orderNumber
            email
            phone
            createdAt
            updatedAt
            processedAt
            fulfillmentStatus
            financialStatus
            cancelledAt
            cancelReason
            totalPriceV2 {
              amount
              currencyCode
            }
            subtotalPriceV2 {
              amount
              currencyCode
            }
            totalTaxV2 {
              amount
              currencyCode
            }
            totalShippingPriceV2 {
              amount
              currencyCode
            }
            currencyCode
            customerUrl
            statusUrl
            shippingAddress {
              id
              firstName
              lastName
              company
              address1
              address2
              city
              province
              provinceCode
              country
              countryCode
              zip
              phone
            }
            billingAddress {
              id
              firstName
              lastName
              company
              address1
              address2
              city
              province
              provinceCode
              country
              countryCode
              zip
              phone
            }
            lineItems(first: 50) {
              edges {
                node {
                  title
                  quantity
                  variant {
                    id
                    title
                    price
                    image {
                      url
                      altText
                    }
                    product {
                      id
                      title
                      handle
                    }
                  }
                  originalTotalPrice {
                    amount
                    currencyCode
                  }
                  discountedTotalPrice {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
      }
    }
  }
  ''';
}

String customerOrderDetailsQuery({String locale = 'EN'}) {
  return '''
  query customerOrder(\$customerAccessToken: String!, \$id: ID!) @inContext(language: ${locale.toUpperCase()}) {
    customer(customerAccessToken: \$customerAccessToken) {
      orders(first: 1, query: "id:\$id") {
        edges {
          node {
            id
            orderNumber
            email
            phone
            createdAt
            updatedAt
            processedAt
            fulfillmentStatus
            financialStatus
            cancelledAt
            cancelReason
            totalPriceV2 {
              amount
              currencyCode
            }
            subtotalPriceV2 {
              amount
              currencyCode
            }
            totalTaxV2 {
              amount
              currencyCode
            }
            totalShippingPriceV2 {
              amount
              currencyCode
            }
            currencyCode
            customerUrl
            statusUrl
            note
            shippingAddress {
              id
              firstName
              lastName
              company
              address1
              address2
              city
              province
              provinceCode
              country
              countryCode
              zip
              phone
            }
            billingAddress {
              id
              firstName
              lastName
              company
              address1
              address2
              city
              province
              provinceCode
              country
              countryCode
              zip
              phone
            }
            lineItems(first: 100) {
              edges {
                node {
                  title
                  quantity
                  variant {
                    id
                    title
                    price
                    compareAtPrice
                    image {
                      url
                      altText
                    }
                    product {
                      id
                      title
                      handle
                      productType
                      vendor
                    }
                    selectedOptions {
                      name
                      value
                    }
                  }
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
                      ... on DiscountCodeApplication {
                        code
                      }
                      ... on AutomaticDiscountApplication {
                        title
                      }
                    }
                  }
                }
              }
            }
            discountApplications(first: 10) {
              edges {
                node {
                  ... on DiscountCodeApplication {
                    code
                    applicable
                  }
                  ... on AutomaticDiscountApplication {
                    title
                  }
                  targetType
                  value {
                    ... on MoneyV2 {
                      amount
                      currencyCode
                    }
                    ... on PricingPercentageValue {
                      percentage
                    }
                  }
                }
              }
            }
            successfulFulfillments(first: 10) {
              trackingCompany
              trackingInfo {
                number
                url
              }
              fulfillmentLineItems(first: 50) {
                edges {
                  node {
                    lineItem {
                      title
                      quantity
                    }
                    quantity
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
