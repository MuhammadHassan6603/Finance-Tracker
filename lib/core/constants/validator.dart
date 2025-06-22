class Validator {
  static String? valueExists(String? value) {
    if (value == null || value.isEmpty) {
      return '* Please fill this field';
    } else {
      return null;
    }
  }

  static String? passwordCorrect(String? value) {
    var emptyResult = valueExists(value);
    if (emptyResult == null || emptyResult.isEmpty) {
      // var pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[#?!@$%^&*-]).{8,}$';
      var pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[#?!~@$%^&*-]).{8,}$';
      var regExp = RegExp(pattern);
      if (!regExp.hasMatch(value!)) {
        return 'Your password must be at least 8 symbols with number, big and small letter and special character (!@#\$%^&*).';
      } else {
        return null;
      }
    } else {
      return emptyResult;
    }
  }

  static String? validateEmail(String? value) {
    var pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    var regExp = RegExp(pattern);
    var emptyResult = valueExists(value);
    if (emptyResult != null) {
      return emptyResult;
    } else if (!regExp.hasMatch(value!)) {
      return 'Not a valid email address. Should be your@email.com';
    } else {
      return null;
    }
  }

  static String? passwordConfirmed(String? value, String? pass) {
    var emptyResult = valueExists(value);
    if (emptyResult != null) {
      return emptyResult;
    } else if (value != pass) {
      return "Passwords didn't matched";
    } else {
      return null;
    }
  }

  static String? validatePhoneNumber(String? value) {
    var pattern = r'^\+?1?\d{9,15}$';
    var regExp = RegExp(pattern);
    var emptyResult = valueExists(value);
    if (emptyResult != null) {
      return emptyResult;
    } else if (!regExp.hasMatch(value!)) {
      return 'Not a valid phone number. Should be 9 to 15 digits.';
    } else {
      return null;
    }
  }

  static String? validateWebsite(String? value) {
    var pattern =
        r'^(https?:\/\/)?([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,6})(\/[a-zA-Z0-9&%_.-]+)*\/?$';
    var regExp = RegExp(pattern);
    var emptyResult = valueExists(value);
    if (emptyResult != null) {
      return emptyResult;
    } else if (!regExp.hasMatch(value!)) {
      return 'Not a valid website URL. Should be in the format https://example.com';
    } else {
      return null;
    }
  }
}
