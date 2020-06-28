import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwlaa/screen/home.dart';
import 'package:uwlaa/screen/welcome.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isAnimationDone = false;

  @override
  void initState() {
    super.initState();
  }

  _initPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id');
    print(userId);
    if (userId == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(width: 1242, height: 2688, allowFontScaling: false);
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Stack(
          children: <Widget>[
            Center(
              child: Container(
                width: 300.0,
                // padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: FlareActor(
                  'assets/uwlaa_logo_anim.flr',
                  animation: 'animate_logo',
                  fit: BoxFit.contain,
                  callback: (name) {
                    if (name == 'animate_logo') {
                      setState(() {
                        _isAnimationDone = true;
                      });
                      Future.delayed(Duration(milliseconds: 1000))
                          .then((onValue) {
                        _initPreferences();
                      });
                    }
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 100.0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Visibility(
                        visible: _isAnimationDone,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              width: 30.0,
                              height: 30.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                            ),
                            Text(
                              "Copyright (c) Uwlaa Sdn Bhd",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(48.0),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
