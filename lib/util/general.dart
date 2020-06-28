class GeneralUtility {
  static RegExp _numeric = RegExp(r'^-?[0-9]+$');

  static bool isNumeric(String str) {
    return _numeric.hasMatch(str);
  }
}
