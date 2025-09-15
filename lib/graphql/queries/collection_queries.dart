String getProductsByCollectionId(String locale) {
  return '''
  query ProductsByCollection(
    \$id: ID!, 
    \$filters: [ProductFilter!], 
    \$first: Int = 50, 
    \$after: String,
    \$sortKey: ProductCollectionSortKeys = BEST_SELLING,
    \$reverse: Boolean = false
  ) @inContext(language: ${locale.toUpperCase()}) {
    collection(id: \$id) {
      id
      title
      products(
        first: \$first, 
        after: \$after, 
        filters: \$filters, 
        sortKey: \$sortKey, 
        reverse: \$reverse
      ) {
        pageInfo {
          hasNextPage
          endCursor
        }
        filters {
          id
          label
          type
          values {
            id
            label
            count
            input
          }
        }
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
  }
  ''';
}
