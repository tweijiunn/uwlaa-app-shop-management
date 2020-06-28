class CountryCode {
  final String countryName;
  final String countryFlag;
  final String countryCode;

  CountryCode({this.countryName, this.countryFlag, this.countryCode});

  factory CountryCode.fromJson(Map<String, dynamic> json) {
    return new CountryCode(
      countryName: json["name"],
      countryFlag: json["emoji"],
      countryCode: json["dialCode"],
    );
  }
}

class CountryCodeList {
  final List<dynamic> countryCodeList;

  CountryCodeList({this.countryCodeList});

  factory CountryCodeList.fromJson(Map<String, dynamic> json) {
    return new CountryCodeList(countryCodeList: json["country_code"]);
  }
}
