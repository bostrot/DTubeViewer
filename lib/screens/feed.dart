import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart';
import '../components/api.dart';
import '../components/videolist.dart';
import 'package:simple_moment/simple_moment.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class buildFeed extends StatefulWidget {
  @override
  createState() => new buildFeedState();
}

class buildFeedState extends State<buildFeed> {
  var user;
  var key;
  var apiData4;
  var userData;

  checkUser() async {
    var _temp = {"user": await retrieveData("user"), "key": await retrieveData("key")};
    setState(() {
      user = _temp["user"];
      key = _temp["key"];
    });
    if (user != null && key != null) {
      _getVideos();
      var _tempData = await steemit.getAccount(user);
      var _tempPrice = await steemit.getSteemPrice();
      setState(() {
        userData = _tempData;
      });

      print(double.parse(userData["result"][0]["balance"].toString().replaceAll(" STEEM", "")) * double.parse(_tempPrice[0]["price_usd"]));
    }
    ;
  }

  _getVideos() async {
    apiData4 = await steemit.getDiscussionsByFeed(user);
    setState(() {
      apiData4 = apiData4;
    });
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
          : apiData4 != null
              ? new Container(
                  child: _buildSubtitles(),
                )
              : new Center(
                  child: new CircularProgressIndicator(),
                ),
    );
  }

  Widget _buildSubtitles() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;
    int jump = 0;
    return new RefreshIndicator(
      child: Column(
        children: <Widget>[
          new FlatButton(
            onPressed: () {
              print("pressed");
            },
            child: new ListTile(
              leading: new CircleAvatar(
                backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
                backgroundImage: new NetworkImage("https://steemitimages.com/u/" + user + "/avatar/small"),
              ),
              title: new Text(user),
              trailing: userData != null ? new Text("data") : new Text("loading"),
            ),
          ),
          new Expanded(
            child: new GridView.builder(
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 2.0,
                  crossAxisCount: isLandscape ? 4 : 2,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: 100, // TODO: add _subtitles.length after update
                padding: const EdgeInsets.all(4.0),
                itemBuilder: (context, i) {
                  int index = i + jump;
                  var data = apiData4["result"][index];
                  var permlink = data["permlink"];
                  print(index);
                  try {
                    var title = data['json_metadata'].split('"title":"')[1].split('",')[0];
                    String description = data['json_metadata'].split(',"description":"')[1].split('",')[0];
                    return _buildRow(data, index, title, description, permlink);
                  } catch (e) {
                    try {
                      index++;
                      jump++;
                      data = apiData4["result"][index];
                      permlink = data["permlink"];
                      var title = data['json_metadata'].split('"title":"')[1].split('",')[0];
                      String description = data['json_metadata'].split(',"description":"')[1].split('",')[0];
                      return _buildRow(data, index, title, description, permlink);
                    } catch (e) {
                      try {
                        index++;
                        jump++;
                        data = apiData4["result"][index];
                        permlink = data["permlink"];
                        var title = data['json_metadata'].split('"title":"')[1].split('",')[0];
                        String description = data['json_metadata'].split(',"description":"')[1].split('",')[0];
                        return _buildRow(data, index, title, description, permlink);
                      } catch (e) {}
                    }
                  }
                  return null;
                }),
          ),
        ],
      ),
      onRefresh: () async {
        /*
        setState(() async {
          apiData = [
            await getDiscussions(0, null, null),
            await getDiscussions(1, null, null),
            await getDiscussions(2, null, null)
          ];
        });
        return apiData;*/
      },
    );
  }

  Widget _placeholderImage(var imgURL) {
    try {
      return Image.network(
        "https://ipfs.io/ipfs/" + imgURL,
        fit: BoxFit.scaleDown,
      );
    } catch (e) {
      return Image.network(
        "https://ipfs.io/ipfs/Qma585tFzjmzKemYHmDZoKMZHo8Ar7YMoDAS66LzrM2Lm1",
        fit: BoxFit.scaleDown,
      );
    }
  }

  Widget _buildRow(var data, var index, var title, var description, var permlink) {
    var moment = new Moment.now();
    // handle metadata from (string)json_metadata
    var json_metadata = json.decode(data['json_metadata'].replaceAll(description, "").replaceAll(title, ""));
    return new InkWell(
      child: new Column(
        children: <Widget>[
          _placeholderImage(json_metadata['video']['info']['snaphash']),
          new Text(title, style: new TextStyle(fontSize: 14.0, color: theme(selectedTheme)["text"]), maxLines: 2),
          new Text("by " + data['author'], style: new TextStyle(fontSize: 12.0, color: theme(selectedTheme)["accent"]), maxLines: 1),
          new Text("\$" + data['pending_payout_value'].replaceAll("SBD", "") + " • " + moment.from(DateTime.parse(data['created'])),
              style: new TextStyle(fontSize: 12.0, color: theme(selectedTheme)["accent"]), maxLines: 1),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new VideoScreen(
                    permlink: permlink,
                    data: data,
                    description: description,
                    json_metadata: json_metadata,
                    search: false,
                  )),
        );
      },
    );
  }
}
