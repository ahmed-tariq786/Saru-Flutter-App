String createCartMutation({String locale = 'EN'}) {
  return '''
  mutation CreateCart(\$lines: [CartLineInput!]) @inContext(language: ${locale.toUpperCase()}) {
    cartCreate(input: { lines: \$lines }) {
      cart {
        id
        checkoutUrl
        lines(first: 20) {
          edges {
            node {
              id
              quantity
              merchandise {
                ... on ProductVariant {
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

String addLinesToCartMutation({String locale = 'EN'}) {
  return '''
  mutation AddLinesToCart(\$cartId: ID!, \$lines: [CartLineInput!]!) @inContext(language: ${locale.toUpperCase()}) {
    cartLinesAdd(cartId: \$cartId, lines: \$lines) {
      cart {
        id
        checkoutUrl
        cost {
          subtotalAmount {
            amount
            currencyCode
          }
          totalAmount {
            amount
            currencyCode
          }
          totalTaxAmount {
            amount
            currencyCode
          }
          totalDutyAmount {
            amount
            currencyCode
          }
        }
        lines(first: 20) {
          edges {
            node {
              id
              quantity
              merchandise {
                ... on ProductVariant {
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

String getCartQuery({String locale = 'EN'}) {
  return '''
  query GetCart(\$cartId: ID!) @inContext(language: ${locale.toUpperCase()}) {
    cart(id: \$cartId) {
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
        totalTaxAmount {
          amount
          currencyCode
        }
        totalDutyAmount {
          amount
          currencyCode
        }
      }
      lines(first: 20) {
        edges {
          node {
            id
            quantity
            discountAllocations {
              discountedAmount {
                amount
                currencyCode
              }
            }
            merchandise {
              ... on ProductVariant {
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
  ''';
}

String updateCartLinesMutation({String locale = 'EN'}) {
  return '''
  mutation UpdateCartLines(\$cartId: ID!, \$lines: [CartLineUpdateInput!]!) @inContext(language: ${locale.toUpperCase()}) {
    cartLinesUpdate(cartId: \$cartId, lines: \$lines) {
      cart {
        id
        checkoutUrl
        lines(first: 20) {
          edges {
            node {
              id
              quantity
              merchandise {
                ... on ProductVariant {
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

String removeCartLinesMutation({String locale = 'EN'}) {
  return '''
  mutation RemoveCartLines(\$cartId: ID!, \$lineIds: [ID!]!) @inContext(language: ${locale.toUpperCase()}) {
    cartLinesRemove(cartId: \$cartId, lineIds: \$lineIds) {
      cart {
        id
        checkoutUrl
        lines(first: 20) {
          edges {
            node {
              id
              quantity
              merchandise {
                ... on ProductVariant {
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
