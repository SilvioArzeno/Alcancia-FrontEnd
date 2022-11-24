extension StringExtension on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }

  bool isValidPassword() {
    return RegExp(
            r'(^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@_\-$!%*?&./#^*])[A-Za-z\d@_\-$!%*?&./#^*]{8,}$)')
        .hasMatch(this);
  }

  String isDepositOrWithdraw() {
    switch (this) {
      case 'DEPOSIT':
        return 'DEPOSITO';
      case 'WITHDRAW':
        return 'RETIRO';
      case 'YIELD':
        return 'RENDIMIENTO';
    }
    return '';
  }
}
