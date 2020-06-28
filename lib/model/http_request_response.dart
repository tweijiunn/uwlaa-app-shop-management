class HttpRequestResponse {
  var status;
  var message;

  HttpRequestResponse({this.status, this.message});

  factory HttpRequestResponse.fromJson(Map<String, dynamic> json) {
    return HttpRequestResponse(
      status: json['status'],
      message: json['message'],
    );
  }
}
