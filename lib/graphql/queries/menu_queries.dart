String getMenus(String locale) {
  return '''
  query GetMenu(\$handle: String!) @inContext(language: ${locale.toUpperCase()}) {
      menu(handle: \$handle) {
      id
      title
      items {
        id
        title
        type
        url
        resource {
          ... on Collection {
            id
            title
            image {
              url
              altText
            }
          }
        }
        items {
          id
          title
          type
          url
          resource {
            ... on Collection {
              id
              title
              image {
                url
                altText
              }
            }
          }
          items {
            id
            title
            type
            url
            resource {
              ... on Collection {
                id
                title
                image {
                  url
                  altText
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

// New query for fetching multiple menus in a single request
String getMultipleMenus(String locale, List<String> handles) {
  final menuFields = '''
    id
    title
    items {
      id
      title
      type
      url
      resource {
        ... on Collection {
          id
          title
          image {
            url
            altText
          }
        }
      }
      items {
        id
        title
        type
        url
        resource {
          ... on Collection {
            id
            title
            image {
              url
              altText
            }
          }
        }
        items {
          id
          title
          type
          url
          resource {
            ... on Collection {
              id
              title
              image {
                url
                altText
              }
            }
          }
        }
      }
    }
  ''';

  final menuQueries = handles
      .asMap()
      .entries
      .map((entry) {
        final index = entry.key;
        final handle = entry.value;
        return '''
      menu$index: menu(handle: "$handle") {
        $menuFields
      }
    ''';
      })
      .join('\n');

  return '''
  query GetMultipleMenus @inContext(language: ${locale.toUpperCase()}) {
    $menuQueries
  }
  ''';
}
