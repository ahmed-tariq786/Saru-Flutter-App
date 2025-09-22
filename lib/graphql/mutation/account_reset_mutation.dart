/// 1️⃣ Ask Shopify to send the reset email
String customerRecoverMutation() {
  return '''
  mutation customerRecover(\$email: String!) {
    customerRecover(email: \$email) {
      customerUserErrors {
        code
        field
        message
      }
    }
  }
  ''';
}
