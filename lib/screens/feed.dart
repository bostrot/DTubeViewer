import 'package:flutter/material.dart';
import '../components/api.dart';
import '../components/videolist.dart';
import 'dart:io' show Platform;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

var apiData4;

class BuildFeed extends StatefulWidget {
  @override
  createState() => new BuildFeedState();
}

class BuildFeedState extends State<BuildFeed> {
  var user;
  var key;
  var userData;
  var steemPriceData;

  checkUser() async {
    var _temp = {"user": await retrieveData("user"), "key": await retrieveData("key")};
    setState(() {
      user = _temp["user"];
      key = _temp["key"];
    });
    if (user != null && key != null) {
      var _tempData = await steemit.getAccount(user);
      var _tempPrice = await steemit.getSteemPrice();
      setState(() {
        userData = _tempData;
        steemPriceData = _tempPrice;
      });
      print(steemPriceData);
    }
  }

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: theme(selectedTheme)["background"],
        child: user == null
            ? new Column(
                children: <Widget>[
                  new Card(
                    color: theme(selectedTheme)["background"],
                    child: new Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: new Center(
                        child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.only(top: 16.0, left: 4.0, right: 4.0),
                              child: new Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new RaisedButton(
                                    onPressed: () {
                                      if (Platform.isAndroid) {
                                        launchURL(
                                            "https://v2.steemconnect.com/oauth2/authorize?client_id=dtubeviewer&redirect_uri=dtubeapp://d.tube&scope=");
                                      } else {
                                        launchURL(
                                            "https://v2.steemconnect.com/oauth2/authorize?client_id=dtubeviewer&redirect_uri=https://dtubeviewer.firebaseapp.com&scope=");
                                      }
                                    },
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Text(
                                          "Login with Steemconnect",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                    color: Colors.blueAccent,
                                  ),
                                  new FlatButton(
                                      onPressed: () {
                                        launchURL("https://signup.steemit.com/");
                                      },
                                      child: new Text(
                                        "No account? Register now on steemit.com",
                                        style: TextStyle(color: theme(selectedTheme)["text"]),
                                      )),
                                  new FlatButton(
                                      onPressed: () {
                                        launchURL("https://about.d.tube/#faq1");
                                      },
                                      child: new Text(
                                        "Trouble logging in? Visit the FAQ",
                                        style: TextStyle(color: theme(selectedTheme)["text"]),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Stack(
                children: <Widget>[
                  buildSubtitles(steemit.getDiscussionsByFeed(user), context),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      userData != null && steemPriceData != null && userData["result"] != null
                          ? new Opacity(
                              opacity: 0.9,
                              child: new FlatButton(
                                color: theme(selectedTheme)["background"],
                                onPressed: () {
                                  print("pressed");
                                },
                                child: new ListTile(
                                  leading: new CircleAvatar(
                                    backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
                                    backgroundImage: new NetworkImage("https://steemitimages.com/u/" + user + "/avatar/small"),
                                  ),
                                  title: new Text(user),
                                  trailing: new Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Card(
                                        color: Colors.green,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: <Widget>[
                                              new Icon(
                                                FontAwesomeIcons.bolt,
                                                color: Colors.white,
                                                size: 12.0,
                                              ),
                                              new Text(
                                                " " + (userData["result"][0]["voting_power"] / 100).toString() + "%",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      new Card(
                                        color: Colors.green,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: new Text(
                                            "\$" +
                                                (double.parse(userData["result"][0]["balance"].toString().replaceAll(" STEEM", "")) +
                                                        double.parse(steemPriceData[0]["price_usd"]))
                                                    .toStringAsFixed(2)
                                                    .toString(),
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ));
  }
}
