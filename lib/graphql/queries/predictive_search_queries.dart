String getPredictiveSearch(String locale) {
  return '''
  query PredictiveSearch(\$query: String!) @inContext(language: ${locale.toUpperCase()}) {
    predictiveSearch(query: \$query, limit: 10) {
      queries {
        text
      }
      products {
        id
        title
        handle
        featuredImage {
          url
          altText
        }
        priceRange {
          minVariantPrice {
            amount
            currencyCode
          }
        }
      }
    }
  }
  ''';
}

String getProductSearch(String locale) {
  return '''
query AllProductsForSearch @inContext(language: AR) {
                  products(first: 50) {
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
                        variants(first: 100) {
                          edges {
                            node {
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
