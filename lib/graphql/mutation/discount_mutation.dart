String cartDiscountCodesUpdateMutation({String locale = 'EN'}) {
  return '''
  mutation cartDiscountCodesUpdate(\$cartId: ID!, \$discountCodes: [String!]!) @inContext(language: ${locale.toUpperCase()}) {
    cartDiscountCodesUpdate(cartId: \$cartId, discountCodes: \$discountCodes) {
      cart {
        id
        checkoutUrl
        discountCodes {
          code
          applicable
        }
        discountAllocations {
          discountedAmount {
            amount
            currencyCode
          }
        }
        cost {
          subtotalAmount {
            amount
            currencyCode
          }
          totalAmount {
            amount
            currencyCode
          }
        }
      }
      userErrors {
        field
        message
      }
    }
  }
  ''';
}
