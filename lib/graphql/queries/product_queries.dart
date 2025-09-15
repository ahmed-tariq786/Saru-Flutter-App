String getLocalizedProducts(String locale) {
  return '''
query getProductsAR @inContext(language: ${locale.toUpperCase()}) {
  products(first: 10) {
    edges {
      node {
        id
        title
        descriptionHtml
        vendor
        tags
        specifications: metafield(namespace: "custom", key: "specifications2") {
          value
        }
        images(first: 20) {
          edges {
            node {
              url
              altText
            }
          }
        }
        collections(first: 10) {
          edges {
            node {
              title
            }
          }
        }
        variants(first: 100) {
          edges {
            node {
              id
              title
              sku
              image {
                url
                altText
              }
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
              selectedOptions {
                name
                value
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

String getProductById(String locale) {
  return '''
  query getProductById(\$id: ID!) @inContext(language: ${locale.toUpperCase()}) {
    product(id: \$id) {
      id
      title
      descriptionHtml
      vendor
      tags
      specifications: metafield(namespace: "custom", key: "specifications2") {
        value
      }
      images(first: 20) {
        edges {
          node {
            url
            altText
          }
        }
      }
      collections(first: 10) {
        edges {
          node {
            title
          }
        }
      }
      variants(first: 100) {
        edges {
          node {
            id
            title
            sku
            image {
              url
              altText
            }
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
            selectedOptions {
              name
              value
            }
          }
        }
      }
    }
  }
  ''';
}
