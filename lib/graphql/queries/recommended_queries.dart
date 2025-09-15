String getRecommendedProducts(String locale, String productId) {
  return '''
  query getRecommendations @inContext(language: ${locale.toUpperCase()}) {
    productRecommendations(productId: "$productId") {
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
