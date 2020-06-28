import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwlaa/model/country_code.dart';
import 'dart:io';
import 'dart:convert';
import 'package:password_strength/password_strength.dart';

import 'package:uwlaa/model/http_request_response.dart';
import 'package:uwlaa/screen/home.dart';
import 'package:uwlaa/util/general.dart';
import 'package:quiver/async.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final _verifyPhoneKey = GlobalKey<FormState>();
  final _infoKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FocusNode _nodeFullName = FocusNode();
  final FocusNode _nodePassword = FocusNode();
  final FocusNode _nodeConfirmPassword = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  bool _autovalidate = false;
  bool _isPhoneNumberValid = false;
  bool _isOTPValid = false;
  bool _isResendValid = false;
  bool _obscureText = true;

  String _stage = "welcome";
  String _header1 = "Welcome!";
  String _description1 = "Enter your email account to continue.";
  String _phoneErrorText = "";
  String _resendOTPButtonText = "Resend";

  String _email = "";
  String _fullName = "";
  String _photoURL = "";
  String _userId = "";
  String _countryCode = "🇲🇾 +60";
  String _phoneNumber = "";
  String _otpCode = "";
  String _password = "";
  String _signupType = "";

  TextEditingController _emailController = TextEditingController();
  TextEditingController _countryCodeController =
      TextEditingController(text: "🇲🇾 +60");
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _otpPasscodeController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  int _timerStart = 60;
  int _timerCurrent = 10;

  void _startTimer() {
    _avoidResend = false;
    _isResendValid = false;
    _otpPasscodeController.text = "";
    CountdownTimer countdownTimer = CountdownTimer(
      Duration(seconds: _timerStart),
      Duration(seconds: 1),
    );

    var sub = countdownTimer.listen(null);
    sub.onData((duration) {
      if (mounted) {
        setState(() {
          _timerCurrent = _timerStart - duration.elapsed.inSeconds;
          _resendOTPButtonText = "Resend (" + _timerCurrent.toString() + "s)";
        });
      }
    });

    sub.onDone(() {
      print("Done");
      if (mounted) {
        setState(() {
          _resendOTPButtonText = "Resend";
          _isResendValid = true;
        });
      }

      sub.cancel();
    });
  }

  bool _avoidResend = false;

  Future<void> _finalSignUp(YYDialog dialog) async {
    if (_infoKey.currentState.validate()) {
      // print(_email);
      // print(_userId);
      // print(_fullName);
      // print(_photoURL);
      // print(_phoneNumber);
      // print(_countryCode);
      // print(_password);
      // print(_signupType);
      // print(_signupType == '');
      var queryParameters;
      var endPoint = "";
      if (_signupType == '') {
        queryParameters = {
          'email': _email,
          'name': _fullName,
          'phoneNumber': _phoneNumber,
          'countryCode': _countryCode,
          'password': _password,
        };
        endPoint = "/mobileSignupWithEmail";
      } else if (_signupType == 'Facebook') {
        queryParameters = {
          'email': _email,
          'name': _fullName,
          'phoneNumber': _phoneNumber,
          'countryCode': _countryCode,
          'profile_pic_url': _photoURL,
          'user_id': _userId
        };
        endPoint = "/mobileSignUpWithFacebook";
      } else {
        queryParameters = {
          'email': _email,
          'name': _fullName,
          'phoneNumber': _phoneNumber,
          'countryCode': _countryCode,
          'profile_pic_url': _photoURL,
          'user_id': _userId
        };
        endPoint = "/mobileSignUpWithGoogle";
      }
      dialog.show();
      try {
        new HttpClient()
            .postUrl(new Uri.https('us-central1-uwlaamart.cloudfunctions.net',
                '/httpFunction/api/v1' + endPoint, queryParameters))
            .then((HttpClientRequest request) => request.close())
            .then((HttpClientResponse response) {
          response
              .transform(Utf8Decoder())
              .transform(json.decoder)
              .listen((contents) {
            setState(() async {
              HttpRequestResponse httpRequestResponse =
                  HttpRequestResponse.fromJson(contents);
              if (httpRequestResponse.status == "OK") {
                var uid = httpRequestResponse.message;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString("user_id", uid);
                await prefs.setString("name", _fullName);
                await prefs.setString("email", _email);
                await prefs.setString(
                    "signup_type", _signupType == '' ? "Email" : _signupType);
                dialog.dismiss();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (BuildContext context) => HomePage()),
                );
              } else {
                dialog.dismiss();
                _showMessage("Something went wrong", Colors.red);
              }
            });
          });
        });
      } catch (error) {
        dialog.dismiss();
        _showMessage(error.toString(), Colors.red);
      }
    }
  }

  Future<void> _signIn(YYDialog dialog) async {
    if (_passwordKey.currentState.validate()) {
      print(_email);
      print(_password);
      dialog.show();
      try {
        var queryParameters = {'email': _email, 'password': _password};
        new HttpClient()
            .postUrl(new Uri.https('us-central1-uwlaamart.cloudfunctions.net',
                '/httpFunction/api/v1/mobileSignInWithEmail', queryParameters))
            .then((HttpClientRequest request) => request.close())
            .then((HttpClientResponse response) {
          response
              .transform(Utf8Decoder())
              .transform(json.decoder)
              .listen((contents) {
            setState(() async {
              HttpRequestResponse httpRequestResponse =
                  HttpRequestResponse.fromJson(contents);
              if (httpRequestResponse.status == "OK") {
                if (httpRequestResponse.message == 'Invalid Password') {
                  dialog.dismiss();
                  _showMessage("Invalid password", Colors.red);
                } else {
                  var result = httpRequestResponse.message.split("||@||");
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString("user_id", result[1]);
                  await prefs.setString("name", result[0]);
                  await prefs.setString("email", result[2]);
                  await prefs.setString("signup_type", result[3]);
                  dialog.dismiss();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()),
                  );
                }
              } else {
                dialog.dismiss();
                _showMessage("Something went wrong", Colors.red);
              }
            });
          });
        });
      } catch (error) {
        dialog.dismiss();
        _showMessage(error.toString(), Colors.red);
      }
    }
  }

  _verifyOTP(YYDialog dialog, BuildContext context) {
    if (!_avoidResend) {
      Future.delayed(Duration.zero, () async {
        dialog.show();
        print(_otpCode);
        _avoidResend = true;
        try {
          var queryParameters = {
            'countryCode': _countryCode,
            'phoneNumber': _phoneNumber,
            'code': _otpCode
          };
          new HttpClient()
              .postUrl(new Uri.https('us-central1-uwlaamart.cloudfunctions.net',
                  '/httpFunction/api/v1/mobileVerifyCode', queryParameters))
              .then((HttpClientRequest request) => request.close())
              .then((HttpClientResponse response) {
            response
                .transform(Utf8Decoder())
                .transform(json.decoder)
                .listen((contents) {
              dialog.dismiss();
              setState(() {
                HttpRequestResponse httpRequestResponse =
                    HttpRequestResponse.fromJson(contents);
                if (httpRequestResponse.status == "OK") {
                  if (httpRequestResponse.message == "Approved") {
                    print("Verified phone");
                    _autovalidate = false;
                    setState(() {
                      if (_stage == "verify_phone_email") {
                        _stage = "information_email";
                      } else {
                        _stage = "information";
                      }
                      _header1 = "A little bit more";
                      _description1 = "Fill up or confirm your details";
                    });
                  } else {
                    _showMessage(httpRequestResponse.message, Colors.red);
                  }
                } else {
                  _showMessage("Something went wrong", Colors.red);
                }
              });
            });
          });
        } catch (error) {
          dialog.dismiss();
          _showMessage(error.toString(), Colors.red);
        }
      });
    }
  }

  Future<void> _verifyPhone(YYDialog dialog) async {
    print("Country Code: $_countryCode, Phone number: $_phoneNumber");
    dialog.show();
    try {
      var queryParameters = {
        'countryCode': _countryCode,
        'phoneNumber': _phoneNumber
      };
      new HttpClient()
          .postUrl(new Uri.https('us-central1-uwlaamart.cloudfunctions.net',
              '/httpFunction/api/v1/mobilePhoneVerification', queryParameters))
          .then((HttpClientRequest request) => request.close())
          .then((HttpClientResponse response) {
        response
            .transform(Utf8Decoder())
            .transform(json.decoder)
            .listen((contents) {
          dialog.dismiss();
          setState(() {
            HttpRequestResponse httpRequestResponse =
                HttpRequestResponse.fromJson(contents);
            if (httpRequestResponse.status == "OK") {
              if (httpRequestResponse.message == "Verifying") {
                print("Verifying phone");
                _startTimer();
                setState(() {
                  if (_stage == "phone_number_email") {
                    _stage = "verify_phone_email";
                  } else {
                    _stage = "verify_phone";
                  }

                  _description1 =
                      "Enter the 6-digits OTP sent to your phone via SMS";
                });
              } else {
                _showMessage(httpRequestResponse.message, Colors.red);
              }
            } else {
              _showMessage("Something went wrong", Colors.red);
            }
          });
        });
      });
    } catch (error) {
      dialog.dismiss();
      _showMessage(error.toString(), Colors.red);
    }
  }

  YYDialog yyProgressDialogNoBody() {
    return YYDialog().build()
      ..width = 200
      ..borderRadius = 4.0
      ..circularProgress(
        padding: EdgeInsets.all(24.0),
        valueColor: Colors.orange[500],
      )
      ..barrierDismissible = false
      ..text(
        padding: EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 12.0),
        text: "Loading...Please wait",
        alignment: Alignment.center,
        color: Colors.orange[500],
        fontSize: ScreenUtil().setSp(50.0),
      );
  }

  List<Widget> countryList = new List<Widget>();

  Widget _createCountry(
      String countryName, String countryCode, String countryFlag) {
    return ListTile(
      leading: Text(
        countryFlag,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(48.0),
        ),
      ),
      title: Text(
        countryName + " " + countryCode,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(48.0),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        print(countryName);
        _countryCodeController.text = countryFlag + " " + countryCode;
        _countryCode = countryFlag + " " + countryCode;
      },
    );
  }

  Future<void> _getCountryCodeList() async {
    CountryCodeList ccList = CountryCodeList(countryCodeList: []);
    List<CountryCode> countryCodeList = List<CountryCode>();

    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/country_code.json");
    final jsonResult = json.decode(data);
    ccList = CountryCodeList.fromJson(jsonResult);
    for (var item in ccList.countryCodeList) {
      String countryName = "", countryFlag = "", countryCode = "";
      for (String key in item.keys) {
        if (key == "dialCode") {
          countryCode = item[key];
        } else if (key == "name") {
          countryName = item[key];
        } else if (key == "emoji") {
          countryFlag = item[key];
        }
      }

      countryCodeList.add(CountryCode(
        countryCode: countryCode,
        countryName: countryName,
        countryFlag: countryFlag,
      ));
    }
    for (var item in countryCodeList) {
      countryList.add(
          _createCountry(item.countryName, item.countryCode, item.countryFlag));
    }
  }

  _showMessage(String message, Color color) {
    SnackBar snackBar = SnackBar(
      backgroundColor: color,
      content: Text(
        '$message',
        style: TextStyle(
          fontSize: ScreenUtil().setSp(50.0),
        ),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<void> _signInWithFacebook(YYDialog dialog) async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token);
        final AuthResult authResult =
            await _auth.signInWithCredential(credential);
        final FirebaseUser user = authResult.user;

        _checkIsUserIdExist(dialog, user.uid);

        _fullName = user.displayName;
        _fullNameController.text = _fullName;
        _email = user.email;
        _photoURL = user.photoUrl;
        _userId = user.uid;
        _signupType = "Facebook";
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage("Cancel Facebook Sign In", Colors.red);
        print("cancelled by user");
        break;
      case FacebookLoginStatus.error:
        _showMessage("Something went wrong", Colors.red);
        print("something went wrong");
        break;
    }
  }

  Future<void> _signOutFromFacebook() async {
    await facebookSignIn.logOut();
    print("Facebook user log out");
  }

  Future<void> _signInWithGoogle(YYDialog dialog) async {
    final GoogleSignInAccount googleSignInAccount =
        await googleSignIn.signIn().catchError((onError) {
      _showMessage(onError.toString(), Colors.red);
      print(onError.toString());
    });
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    _fullName = user.displayName;
    _fullNameController.text = _fullName;
    _email = user.email;
    _photoURL = user.photoUrl;
    _userId = user.uid;
    _signupType = "Google";

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    _checkIsUserIdExist(dialog, user.uid);
  }

  Future<void> signOutGoogle() async {
    // await googleSignIn.signOut();
    print("User Sign Out");
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }

  Future<void> _signWithEmail(YYDialog dialog) async {
    dialog.show();
    try {
      var queryParameters = {'email': _email};
      new HttpClient()
          .postUrl(new Uri.https('us-central1-uwlaamart.cloudfunctions.net',
              '/httpFunction/api/v1/mobileCheckEmail', queryParameters))
          .then((HttpClientRequest request) => request.close())
          .then((HttpClientResponse response) {
        response
            .transform(Utf8Decoder())
            .transform(json.decoder)
            .listen((contents) {
          dialog.dismiss();
          setState(() {
            HttpRequestResponse httpRequestResponse =
                HttpRequestResponse.fromJson(contents);
            if (httpRequestResponse.status == "OK") {
              if (httpRequestResponse.message == "existing") {
                // TODO: Email Existing
                // Save ID and other information to shared preferences, navigate to homepage
                print("Existing Email");
                setState(() {
                  _stage = "password";
                  _header1 = "Authentication";
                  _description1 = "Enter the password to sign in";
                });
              } else if (httpRequestResponse.message == "not-existing") {
                // Fill up details
                print("ID doesn't exist");
                setState(() {
                  _stage = "phone_number_email";
                  _header1 = "Verification";
                  _description1 = "Enter your phone number for verification";
                });
              } else {
                _showMessage(httpRequestResponse.message, Colors.red);
              }
            } else {
              _showMessage("Something went wrong", Colors.red);
            }
          });
        });
      });
    } catch (error) {
      dialog.dismiss();
      _showMessage(error.toString(), Colors.red);
    }
  }

  Future<void> _checkIsUserIdExist(YYDialog dialog, String userId) async {
    dialog.show();
    try {
      var queryParameters = {'user_id': userId};
      new HttpClient()
          .postUrl(new Uri.https(
              'us-central1-uwlaamart.cloudfunctions.net',
              '/httpFunction/api/v1/checkIsUserIDExistInDatabase',
              queryParameters))
          .then((HttpClientRequest request) => request.close())
          .then((HttpClientResponse response) {
        response
            .transform(Utf8Decoder())
            .transform(json.decoder)
            .listen((contents) {
          setState(() async {
            HttpRequestResponse httpRequestResponse =
                HttpRequestResponse.fromJson(contents);
            if (httpRequestResponse.status == "OK") {
              if (httpRequestResponse.message == "existing") {
                // Save ID and other information to shared preferences, navigate to homepage
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString("user_id", userId);
                await prefs.setString("name", _fullName);
                await prefs.setString("email", _email);
                await prefs.setString("signup_type", _signupType);
                print("Existing ID");
                dialog.dismiss();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (BuildContext context) => HomePage()),
                );
              } else if (httpRequestResponse.message == "not-existing") {
                // Fill up details
                dialog.dismiss();
                print("ID doesn't exist");
                setState(() {
                  _stage = "phone_number";
                  _header1 = "Verification";
                  _description1 = "Enter your phone number for verification";
                });
              }
            } else {
              dialog.dismiss();
              _showMessage("Something went wrong", Colors.red);
            }
          });
        });
      });
    } catch (error) {
      dialog.dismiss();
      _showMessage(error.toString(), Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    _countryCodeController.text = "🇲🇾 +60";
    _getCountryCodeList();
    Future.delayed(Duration.zero, () async {});
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _countryCodeController.dispose();
    _phoneNumberController.dispose();
    _otpPasscodeController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);

    var dialog = yyProgressDialogNoBody();

    ScreenUtil.init(width: 1242, height: 2688, allowFontScaling: false);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: _stage == "phone_number" ||
              _stage == "verify_phone" ||
              _stage == "phone_number_email" ||
              _stage == "verify_phone_email" ||
              _stage == "password"
          ? true
          : false,
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Uwlaa.",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(145.0),
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _photoURL != '' && _photoURL != null,
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0),
                          child: _photoURL != '' && _photoURL != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(_photoURL),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: _stage == "information_email" ? 25.0 : 80.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        _header1,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(70.0),
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        _description1,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(50.0),
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 25.0),
                    child: Column(
                      children: <Widget>[
                        Visibility(
                          visible: _stage == "welcome",
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(48.0),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              controller: _emailController,
                              decoration: InputDecoration(
                                isDense: false,
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Email Address',
                                border: InputBorder.none,
                                errorStyle: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onChanged: (value) {
                                _email = value;
                                setState(() {
                                  _autovalidate = true;
                                });
                              },
                              onFieldSubmitted: (value) {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  _email = _emailController.text;
                                  _autovalidate = false;
                                  _signWithEmail(dialog);
                                }
                              },
                              autovalidate: _autovalidate,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'This field is required';
                                } else if (!validateEmail(value)) {
                                  return 'Invalid email';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _stage == "phone_number" ||
                              _stage == "phone_number_email",
                          child: Form(
                            key: _phoneFormKey,
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  flex: 4,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 5.0),
                                    child: TextFormField(
                                      readOnly: true,
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(60.0),
                                        fontWeight: FontWeight.w800,
                                      ),
                                      onTap: () {
                                        showModalBottomSheet(
                                          // expand: true,
                                          context: context,
                                          // backgroundColor: Colors.transparent,
                                          builder: (context) {
                                            return ListView(
                                              children: countryList,
                                            );
                                          },
                                        );
                                      },
                                      controller: _countryCodeController,
                                      decoration: InputDecoration(
                                        isDense: false,
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: InputBorder.none,
                                        hintText: "",
                                        errorText: _phoneErrorText,
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                        errorStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 8,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 5.0),
                                    child: TextFormField(
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(60.0),
                                        fontWeight: FontWeight.w800,
                                      ),
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.done,
                                      controller: _phoneNumberController,
                                      decoration: InputDecoration(
                                        isDense: false,
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: '123456789',
                                        border: InputBorder.none,
                                        errorText: _phoneErrorText,
                                        errorStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (GeneralUtility.isNumeric(value) &&
                                            value.length >= 5) {
                                          _isPhoneNumberValid = true;
                                        } else {
                                          _isPhoneNumberValid = false;
                                        }
                                        setState(() {
                                          _phoneNumber = value;
                                          _phoneErrorText = "";
                                          _autovalidate = true;
                                        });
                                      },
                                      onFieldSubmitted: (value) {
                                        if (_phoneFormKey.currentState
                                            .validate()) {
                                          _phoneFormKey.currentState.save();
                                          // TODO: Proceed next step
                                          print(_phoneNumberController.text);
                                          print(_countryCodeController.text);
                                          setState(() {
                                            _phoneNumber =
                                                _phoneNumberController.text;
                                            _countryCode =
                                                _countryCodeController.text;
                                            _autovalidate = false;
                                          });
                                        }
                                      },
                                      autovalidate: _autovalidate,
                                      validator: (value) {
                                        return null;
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _stage == "verify_phone" ||
                              _stage == "verify_phone_email",
                          child: Form(
                            key: _verifyPhoneKey,
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(60.0),
                                fontWeight: FontWeight.w800,
                              ),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              controller: _otpPasscodeController,
                              decoration: InputDecoration(
                                isDense: false,
                                filled: true,
                                fillColor: Colors.white,
                                hintText: '6-digits OTP',
                                border: InputBorder.none,
                                errorStyle: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onChanged: (value) {
                                _otpCode = value;
                                _autovalidate = true;
                                _avoidResend = false;
                                if (_isResendValid) {
                                  setState(() {});
                                }
                              },
                              onFieldSubmitted: (value) {
                                if (_verifyPhoneKey.currentState.validate()) {
                                  _verifyPhoneKey.currentState.save();
                                  _otpCode = _otpPasscodeController.text;
                                }
                              },
                              autovalidate: _autovalidate,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Check your phone SMS to retrieve the code';
                                } else if (!GeneralUtility.isNumeric(value)) {
                                  return 'Not a number';
                                } else if (value.length != 6) {
                                  return 'Invalid length';
                                }
                                _verifyOTP(dialog, context);
                                return null;
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _stage == "information" ||
                              _stage == "information_email",
                          child: Form(
                            key: _infoKey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 5.0),
                                  child: TextFormField(
                                    focusNode: _nodeFullName,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(48.0),
                                    ),
                                    controller: _fullNameController,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Full Name',
                                      labelText: 'Full Name',
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      border: InputBorder.none,
                                      errorStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    textInputAction:
                                        _stage == "information_email"
                                            ? TextInputAction.next
                                            : TextInputAction.done,
                                    onChanged: (value) {
                                      _fullName = value;
                                      setState(() {
                                        _autovalidate = true;
                                      });
                                    },
                                    onFieldSubmitted: (value) {
                                      if (_stage == "information_email") {
                                        _nodeFullName.unfocus();
                                        FocusScope.of(context)
                                            .requestFocus(_nodePassword);
                                      }
                                      _fullName = _fullNameController.text;
                                    },
                                    autovalidate: _autovalidate,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'This field is required';
                                      } else if (value.length > 50) {
                                        return 'Name is too long';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible: _stage == "information_email",
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(top: 5.0, bottom: 5.0),
                                    child: TextFormField(
                                      focusNode: _nodePassword,
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(48.0),
                                      ),
                                      textInputAction: TextInputAction.next,
                                      controller: _passwordController,
                                      obscureText: _obscureText,
                                      decoration: InputDecoration(
                                        isDense: false,
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: 'Password',
                                        border: InputBorder.none,
                                        errorStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: _obscureText
                                              ? Icon(
                                                  Icons.visibility_off,
                                                  color: Colors.grey,
                                                )
                                              : Icon(
                                                  Icons.visibility,
                                                  color: Colors.grey,
                                                ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                        ),
                                      ),
                                      onChanged: (value) {
                                        _password = value;
                                        _autovalidate = true;
                                      },
                                      onFieldSubmitted: (value) {
                                        _password = _passwordController.text;
                                        _nodePassword.unfocus();
                                        FocusScope.of(context)
                                            .requestFocus(_nodeConfirmPassword);
                                      },
                                      autovalidate: _autovalidate,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'This field is required';
                                        } else if (value.contains(' ')) {
                                          return 'Spacing is not allowed';
                                        } else if (value.length < 8) {
                                          return 'At least 8 characters';
                                        } else if (estimatePasswordStrength(
                                                value) <
                                            0.9) {
                                          return 'Please use a stronger password';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _stage == "information_email",
                                  child: Container(
                                    margin: EdgeInsets.only(top: 5.0),
                                    child: TextFormField(
                                      focusNode: _nodeConfirmPassword,
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(48.0),
                                      ),
                                      textInputAction: TextInputAction.done,
                                      controller: _confirmPasswordController,
                                      obscureText: _obscureText,
                                      decoration: InputDecoration(
                                        isDense: false,
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: 'Confirm Password',
                                        border: InputBorder.none,
                                        errorStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: _obscureText
                                              ? Icon(
                                                  Icons.visibility_off,
                                                  color: Colors.grey,
                                                )
                                              : Icon(
                                                  Icons.visibility,
                                                  color: Colors.grey,
                                                ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                        ),
                                      ),
                                      onChanged: (value) {
                                        _autovalidate = true;
                                      },
                                      onFieldSubmitted: (value) {
                                        _nodeConfirmPassword.unfocus();
                                      },
                                      autovalidate: _autovalidate,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'This field is required';
                                        } else if (value != _password) {
                                          return 'Password does not match';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _stage == "password",
                          child: Form(
                            key: _passwordKey,
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(48.0),
                              ),
                              textInputAction: TextInputAction.done,
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                isDense: false,
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Password',
                                border: InputBorder.none,
                                errorStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                suffixIcon: IconButton(
                                  icon: _obscureText
                                      ? Icon(
                                          Icons.visibility_off,
                                          color: Colors.grey,
                                        )
                                      : Icon(
                                          Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              onChanged: (value) {
                                _password = value;
                                _autovalidate = true;
                                setState(() {});
                              },
                              onFieldSubmitted: (value) {
                                _password = _passwordController.text;
                              },
                              autovalidate: _autovalidate,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'This field is required';
                                } else if (value.contains(' ')) {
                                  return 'Spacing is not allowed';
                                } else if (value.length < 8) {
                                  return 'At least 8 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Visibility(
                    visible: _stage == "welcome",
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Divider(
                                color: Colors.white,
                                thickness: 1,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(40.0),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Divider(
                                color: Colors.white,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        RaisedButton(
                          color: Colors.white,
                          onPressed: () {
                            _signInWithGoogle(dialog);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Image(
                                    image: AssetImage("assets/google_logo.png"),
                                    height: 25.0),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Continue With Google',
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(50.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                        ),
                        RaisedButton(
                          color: Colors.white,
                          onPressed: () {
                            _signInWithFacebook(dialog);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Image(
                                  image: AssetImage("assets/facebook_logo.png"),
                                  height: 25.0,
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Continue With Facebook',
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(50.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _stage == "phone_number" ||
                        _stage == "phone_number_email",
                    child: Container(
                      child: FlatButton(
                        onPressed: _isPhoneNumberValid
                            ? () {
                                _verifyPhone(dialog);
                              }
                            : null,
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(50.0),
                            fontWeight: FontWeight.w800,
                            color: _isPhoneNumberValid
                                ? Colors.white
                                : Color(0x99FFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _stage == "verify_phone" ||
                        _stage == "verify_phone_email",
                    child: Container(
                      child: FlatButton(
                        onPressed: _isResendValid
                            ? () {
                                _verifyPhone(dialog);
                              }
                            : null,
                        child: Text(
                          _resendOTPButtonText,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(50.0),
                            fontWeight: FontWeight.w800,
                            color: _isResendValid
                                ? Colors.white
                                : Color(0x99FFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _stage == "information" ||
                        _stage == "information_email",
                    child: Container(
                      child: FlatButton(
                        onPressed: () {
                          _finalSignUp(dialog);
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(50.0),
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _stage == "password",
                    child: Container(
                      child: FlatButton(
                        onPressed: () {
                          _signIn(dialog);
                        },
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(50.0),
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
