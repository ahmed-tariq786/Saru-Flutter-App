String getProductsByIds(String locale) {
  return '''
  query getProductsByIds(\$ids: [ID!]!) @inContext(language: ${locale.toUpperCase()}) {
    nodes(ids: \$ids) {
      ... on Product {
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
  ''';
}
