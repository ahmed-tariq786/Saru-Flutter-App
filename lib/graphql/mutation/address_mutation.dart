String customerAddressCreateMutation({String locale = 'EN'}) {
  return '''
  mutation customerAddressCreate(\$customerAccessToken: String!, \$address: MailingAddressInput!) @inContext(language: ${locale.toUpperCase()}) {
    customerAddressCreate(customerAccessToken: \$customerAccessToken, address: \$address) {
      customerAddress {
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
      customerUserErrors {
        code
        field
        message
      }
    }
  }
  ''';
}

String customerDefaultAddressUpdateMutation({String locale = 'EN'}) {
  return '''
  mutation customerDefaultAddressUpdate(\$customerAccessToken: String!, \$addressId: ID!) @inContext(language: ${locale.toUpperCase()}) {
    customerDefaultAddressUpdate(customerAccessToken: \$customerAccessToken, addressId: \$addressId) {
      customer {
        id
        defaultAddress {
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

String customerAddressesQuery({String locale = 'EN', int first = 10, String? afterCursor}) {
  final afterClause = afterCursor != null ? ', after: "$afterCursor"' : '';
  return '''
  query customerAddresses(\$customerAccessToken: String!) @inContext(language: ${locale.toUpperCase()}) {
    customer(customerAccessToken: \$customerAccessToken) {
      id
      addresses(first: $first$afterClause) {
        edges {
          node {
            id
            firstName
            lastName
            company
            address1
            address2
            city
            country
            zip
            phone
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
      }
        defaultAddress {
      id
      address1
      city
    }
    }
  }
  ''';
}

String customerAddressDeleteMutation({String locale = 'EN'}) {
  return '''
  mutation customerAddressDelete(\$customerAccessToken: String!, \$id: ID!) 
  @inContext(language: ${locale.toUpperCase()}) {
    customerAddressDelete(customerAccessToken: \$customerAccessToken, id: \$id) {
      deletedCustomerAddressId
      customerUserErrors {
        code
        field
        message
      }
    }
  }
  ''';
}

String customerAddressUpdateMutation({String locale = 'EN'}) {
  return '''
  mutation customerAddressUpdate(\$customerAccessToken: String!, \$id: ID!, \$address: MailingAddressInput!) 
  @inContext(language: ${locale.toUpperCase()}) {
    customerAddressUpdate(customerAccessToken: \$customerAccessToken, id: \$id, address: \$address) {
      customerAddress {
        id
        firstName
        lastName
        company
        address1
        address2
        city
        province
        country
        zip
        phone
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
