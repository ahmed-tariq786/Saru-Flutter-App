String createCustomerMutation({String locale = 'EN'}) {
  return '''
  mutation customerCreate(\$input: CustomerCreateInput!) @inContext(language: ${locale.toUpperCase()}) {
    customerCreate(input: \$input) {
      customer {
        id
        email
        firstName
        lastName
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

String customerLoginMutation({String locale = 'EN'}) {
  return '''
  mutation customerAccessTokenCreate(\$input: CustomerAccessTokenCreateInput!) {
    customerAccessTokenCreate(input: \$input) {
      customerAccessToken {
        accessToken
        expiresAt
      }
      customerUserErrors {
        field
        message
      }
    }
  }
  ''';
}

String customerQuery({String locale = 'EN'}) {
  return '''
  query customer(\$customerAccessToken: String!) 
  @inContext(language: ${locale.toUpperCase()}) {
    customer(customerAccessToken: \$customerAccessToken) {
      id
      email
      firstName
      lastName
      phone
      acceptsMarketing
      createdAt
      updatedAt
      tags
      
      defaultAddress {
        id
        address1
        city
      }
    }
  }
  ''';
}

String customerUpdateMutation = '''
mutation customerUpdate(\$customerAccessToken: String!, \$firstName: String, \$lastName: String, \$phone: String) {
  customerUpdate(
    customerAccessToken: \$customerAccessToken,
    customer: {
      firstName: \$firstName,
      lastName: \$lastName,
      phone: \$phone
    }
  ) {
    customer {
      id
      firstName
      lastName
      phone
      email
    }
    customerUserErrors {
      code
      field
      message
    }
  }
}
''';
