const String loginMutation = """
  mutation(\$loginUserInput: LoginUserInput!) {
    login(loginUserInput: \$loginUserInput) {
      access_token,
      user {
        balance,
        email
      }
    }
  }
""";