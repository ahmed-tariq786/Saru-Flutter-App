const String cartBuyerIdentityUpdateMutation = r'''
  mutation cartBuyerIdentityUpdate($cartId: ID!, $buyerIdentity: CartBuyerIdentityInput!) {
    cartBuyerIdentityUpdate(cartId: $cartId, buyerIdentity: $buyerIdentity) {
      cart {
        id
        buyerIdentity {
          customer {
            id
            email
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

const String cartBuyerIdentitydeleteMutation = r'''
mutation cartBuyerIdentityUpdate($cartId: ID!, $buyerIdentity: CartBuyerIdentityInput!) {
  cartBuyerIdentityUpdate(cartId: $cartId, buyerIdentity: $buyerIdentity) {
    cart {
      id
      buyerIdentity {
        customer {
          id
        }
      }
    }
  }
}
''';
