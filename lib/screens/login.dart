import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../components/api.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as cTab;
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import '../main.dart';

// launch in app browser
void launchUrl(String url, ctx) async {
  try {
    await cTab.launch(
      url,
      option: new cTab.CustomTabsOption(
        toolbarColor: Theme.of(ctx).primaryColor,
        enableDefaultShare: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    debugPrint(e.toString());
  }
}

StreamSubscription _sub;

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // universal links subscription for one-time use
  handleLogin() async {
    _sub = getLinksStream().listen((String link) async {
      saveData("user", link.split("username=")[1]);
      saveData("key", link.split("access_token=")[1].split("&expires")[0]);
      _sub.cancel();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabNav()));
    }, onError: (err) {
      print(err);
      // Handle exception by warning the user their action did not succeed
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Center(child: Container(height: 30.0, child: Image.asset('assets/DTube_Black.png'))),
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CarouselSlider(
              items: [1, 2, 3].map((i) {
                return new Builder(
                  builder: (BuildContext context) {
                    /*List<String> descriptions = <String>[
                      "Vote with custom voting power to show how much you like it.",
                      "Videos are loading slow? Set your own Gateway.",
                      "You don't like the theme? Set another one."
                    ];*/
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: new EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: new BoxDecoration(color: Colors.white),
                        child: Image.asset("assets/screenshot ($i).jpg"));
                  },
                );
              }).toList(),
              viewportFraction: 0.7,
              height: MediaQuery.of(context).size.height - 225,
              autoPlay: true),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: RaisedButton(
                            elevation: 0.0,
                            color: Colors.red,
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              child: Text(
                                "Sign up",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            onPressed: () {
                              launchUrl("https://signup.steemit.com/", context);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: OutlineButton(
                            borderSide: BorderSide(color: Colors.red),
                            highlightedBorderColor: Colors.red,
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              child: Text(
                                "Log in",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            onPressed: () async {
                              handleLogin();
                              if (Platform.isAndroid) {
                                launchUrl("https://v2.steemconnect.com/oauth2/authorize?client_id=dtubeviewer&redirect_uri=dtubeapp://d.tube&scope=",
                                    context);
                              } else {
                                launchUrl(
                                    "https://v2.steemconnect.com/oauth2/authorize?client_id=dtubeviewer&redirect_uri=https://dtubeviewer.firebaseapp.com&scope=",
                                    context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    FlatButton(
                      child: Text(
                        "Skip",
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabNav()));
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
