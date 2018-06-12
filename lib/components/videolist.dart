import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:english_words/english_words.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:simple_moment/simple_moment.dart';
import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';
import 'package:screen/screen.dart';
import '../flutter_html_view/flutter_html_text.dart';
import 'api.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:video_launcher/video_launcher.dart';

const String testDevice = 'YOUR_DEVICE_ID';

int initialShowAd = 3;
int tempShowAd = initialShowAd;

Future<Null> _launch(String url) async {
  if (await canLaunchVideo(url)) {
    await launchVideo(url);
  } else {
    throw 'Could not launch $url';
  }
}

class VideoScreen extends StatefulWidget {
  final String permlink;
  var data;
  var description;
  var json_metadata;
  VideoScreen({
    this.data,
    this.permlink,
    this.description,
    this.json_metadata,
  });
  @override
  VideoScreenState createState() => new VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  var upvoteColor = theme(selectedTheme)["accent"];
  var downvoteColor = theme(selectedTheme)["accent"];
  var subscribed = "Subscribe";
  var gateway = "https://ipfs.io/ipfs/";
  VideoPlayerController _controller;
  String _vidString;

  InterstitialAd myInterstitial = new InterstitialAd(
    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
    // https://developers.google.com/admob/android/test-ads
    // https://developers.google.com/admob/ios/test-ads
    adUnitId: "ca-app-pub-9430927632405311/4144105868",
    listener: (MobileAdEvent event) {
      print("InterstitialAd event is $event");
    },
  );

  @override
  void initState() {
    super.initState();
    getVideo(widget.permlink, widget.data["author"]);
    () async {
      if (await retrieveData("no_ads") == null) {
        FirebaseAdMob.instance.initialize(appId: "ca-app-pub-9430927632405311~3245387668");
        myInterstitial..load();
      }
    };
  }

  double sliderValue;
  var content;
  var result = "loading";
  getVideo(var permlink, var author) async {
    Dio dio = new Dio();
    Response response = await dio.post("https://api.steemit.com", data: {
      "id": 0,
      "jsonrpc": "2.0",
      "method": "call",
      "params": [
        "database_api",
        "get_state",
        ["/dtube/@" + author + "/" + permlink]
      ]
    });
    content = response.data["result"]["content"];
    var _temp = await retrieveData("gateway");
    if (_temp == "https://video.dtube.top/ipfs/") {
      saveData("gateway", "https://ipfs.io/ipfs/");
    }
    setState(() {
      result = "loaded";
      gateway = _temp;
    });
    await sVideoController(widget.json_metadata);
  }

  sVideoController(var videoJSON) async {
    var sourcesInit = [
      "480",
      "240",
      "720",
      "1080",
      "",
    ];
    var sources = {};
    int b = 0;
    String _tempVideo;
    for (int i = 0; i < 5; i++) {
      _tempVideo = videoJSON["video"]["content"]["video${sourcesInit[i]}hash"];
      if (_tempVideo != null) {
        sources[b] = gateway + _tempVideo;
        b++;
      }
      if (i == 4) {
        setState(() {
          _controller = VideoPlayerController.network(sources[0]);
          _vidString = gateway + sources[0];
        });
      }
    }
  }

  setSlider(e) {
    setState(() {
      sliderValue = e;
    });
  }

  //getVideo(permlink);
  @override
  Widget build(BuildContext contextWidget) {
    Screen.keepOn(true);
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: theme(selectedTheme)["background"],
        title: new Text(widget.data["title"], style: new TextStyle(color: theme(selectedTheme)["accent"])),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              _launch(_vidString);
            },
            child: new Icon(Icons.open_in_new, color: theme(selectedTheme)["accent"]),
          )
        ],
        automaticallyImplyLeading: false,
        leading: new Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new IconButton(
              icon: new Icon(
                Icons.arrow_back,
                color: theme(selectedTheme)["accent"],
              ),
              onPressed: () async {
                try {
                  _controller.pause();
                } catch (e) {
                  try {
                    _controller.dispose();
                  } catch (e) {}
                  ;
                }
                Navigator.pop(contextWidget);
                tempShowAd--;
                if (tempShowAd == 0 && await retrieveData("no_ads") == null) {
                  myInterstitial
                    ..load()
                    ..show().then((e) {
                      myInterstitial..load();
                    });
                  tempShowAd = initialShowAd;
                }
              },
            ),
          ],
        ),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            _controller != null
                ? new Chewie(
                    _controller,
                    aspectRatio: 16 / 9,
                    autoPlay: true,
                    looping: false,
                  )
                : new Text("Loading video..."),
            new Container(
              child: result == "loading"
                  ? new Text("loading...")
                  : new Expanded(
                      child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (contextListViewBuilder, index) {
                        if (index == 0)
                          return new Column(
                            children: <Widget>[
                              new Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Row(
                                      children: <Widget>[
                                        new Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: new CircleAvatar(
                                            backgroundImage:
                                                new NetworkImage("https://steemitimages.com/u/" + widget.data["author"] + "/avatar/small"),
                                          ),
                                        ),
                                        new Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: new Text(widget.data["author"]),
                                            ),
                                            new RaisedButton(
                                              color: theme(selectedTheme)["primary"],
                                              onPressed: () async {
                                                var tempSub = await broadcastSubscribe(contextListViewBuilder, widget.data["author"]);
                                                setState(() {
                                                  subscribed = "Subscribed";
                                                });
                                              },
                                              child: new Text(subscribed, style: new TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        new IconButton(
                                            icon: const Icon(FontAwesomeIcons.thumbsUp),
                                            color: upvoteColor,
                                            onPressed: () {
                                              setState(() {
                                                upvoteColor = theme(selectedTheme)["primary"];
                                              });
                                              return showDialog(
                                                context: contextListViewBuilder,
                                                barrierDismissible: false, // user must tap button!
                                                builder: (BuildContext contextDialog) {
                                                  return new StatefulBuilder(builder: (BuildContext contextStatefulBuilder, setState) {
                                                    return new AlertDialog(
                                                      title: new Text('Select Upvoting power'),
                                                      content: new SingleChildScrollView(
                                                        child: new ListBody(
                                                          children: <Widget>[
                                                            new Padding(
                                                              padding: const EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
                                                              child: new Slider(
                                                                onChanged: (e) {
                                                                  setState(() {
                                                                    sliderValue = e;
                                                                  });
                                                                },
                                                                value: sliderValue != null ? sliderValue : 10.0,
                                                                min: 10.0,
                                                                max: 100.0,
                                                                divisions: 9,
                                                                label: sliderValue.toString(),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        new FlatButton(
                                                          child: new Text('CLOSE'),
                                                          onPressed: () {
                                                            Navigator.of(contextStatefulBuilder, rootNavigator: true).pop(result);
                                                          },
                                                        ),
                                                        new FlatButton(
                                                          child: new Text('UPVOTE'),
                                                          onPressed: () {
                                                            Navigator.of(contextStatefulBuilder, rootNavigator: true).pop(result);
                                                            broadcastVote(
                                                                contextStatefulBuilder, widget.data["author"], widget.permlink, toInt(sliderValue));
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                                },
                                              );
                                            }),
                                        new IconButton(
                                            icon: const Icon(FontAwesomeIcons.thumbsDown),
                                            color: downvoteColor,
                                            onPressed: () {
                                              setState(() {
                                                downvoteColor = theme(selectedTheme)["primary"];
                                              });
                                              return showDialog(
                                                context: contextListViewBuilder,
                                                barrierDismissible: false, // user must tap button!
                                                builder: (BuildContext contextDialog) {
                                                  return new StatefulBuilder(builder: (BuildContext contextStatefulBuilder, setState) {
                                                    return new AlertDialog(
                                                      title: new Text('Select Downvoting power'),
                                                      content: new SingleChildScrollView(
                                                        child: new ListBody(
                                                          children: <Widget>[
                                                            new Padding(
                                                              padding: const EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
                                                              child: new Slider(
                                                                onChanged: (e) {
                                                                  setState(() {
                                                                    sliderValue = e;
                                                                  });
                                                                },
                                                                value: sliderValue != null ? sliderValue : 10.0,
                                                                min: 10.0,
                                                                max: 100.0,
                                                                divisions: 9,
                                                                label: sliderValue.toString(),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        new FlatButton(
                                                          child: new Text('CLOSE'),
                                                          onPressed: () {
                                                            Navigator.of(contextStatefulBuilder, rootNavigator: true).pop(result);
                                                          },
                                                        ),
                                                        new FlatButton(
                                                          child: new Text('DOWNVOTE'),
                                                          onPressed: () async {
                                                            Navigator.of(contextStatefulBuilder, rootNavigator: true).pop(result);
                                                            await broadcastVote(
                                                                contextListViewBuilder, widget.data["author"], widget.permlink, toInt(sliderValue));
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                                },
                                              );
                                            }),
                                        new Text(
                                          "\$" + widget.data["pending_payout_value"].toString().replaceFirst(" SBD", ""),
                                          style: new TextStyle(fontSize: 15.0),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              new Divider(
                                height: 1.0,
                                color: theme(selectedTheme)["accent"],
                                indent: 0.0,
                              ),
                              new Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Column(
                                    children: <Widget>[
                                      new Text("Added on " + widget.data["created"]),
                                      new HtmlText(data: linkify(widget.description)),
                                      new Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: new TextField(
                                          autofocus: true,
                                          decoration: new InputDecoration(hintText: 'Comment something...'),
                                          onSubmitted: (comment) {
                                            broadcastComment(contextListViewBuilder, widget.data["author"], widget.permlink, comment.toString());
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                              new Divider(),
                              // TODO: comments class
                            ],
                          );
                        else if (index > 0) {
                          try {
                            var moment = new Moment.now();
                            var reply = content[content[widget.data["author"] + "/" + widget.permlink]["replies"][index - 1].toString()];
                            var comment = linkify(reply["body"]);
                            if ((reply["body"].toString()).length > 100) {
                              comment = linkify(reply["body"].substring(0, 100)).toString() + "...";
                            }
                            return new Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: new ExpansionTile(
                                title: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Row(
                                      children: <Widget>[
                                        new CircleAvatar(
                                          maxRadius: 13.0,
                                          backgroundImage: new NetworkImage("https://steemitimages.com/u/" + reply["author"] + "/avatar/small"),
                                        ),
                                        new Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: new Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Text(
                                                reply["author"],
                                                style: TextStyle(fontSize: 14.0),
                                              ),
                                              new Row(
                                                children: <Widget>[
                                                  new Text(
                                                    moment.from(DateTime.parse(reply["created"])),
                                                    style: TextStyle(color: theme(selectedTheme)["accent"], fontSize: 12.0),
                                                  ),
                                                  new Padding(
                                                    padding: const EdgeInsets.only(left: 4.0),
                                                    child: new Text("\$" + reply["pending_payout_value"].toString().replaceFirst("SBD", ""),
                                                        style: TextStyle(color: theme(selectedTheme)["accent"], fontSize: 12.0)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    new HtmlText(data: comment),
                                  ],
                                ),
                                children: <Widget>[
                                  new HtmlText(data: linkify(reply["body"])),
                                  new Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      new Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: new Icon(
                                          FontAwesomeIcons.thumbsUp,
                                          color: theme(selectedTheme)["accent"],
                                        ),
                                      ),
                                      new Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: new Icon(
                                          FontAwesomeIcons.thumbsDown,
                                          color: theme(selectedTheme)["accent"],
                                        ),
                                      ),
                                    ],
                                  ),
                                  new Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new TextField(
                                      autofocus: true,
                                      decoration: new InputDecoration(hintText: 'Comment something...'),
                                      onSubmitted: (comment) {
                                        broadcastComment(contextListViewBuilder, reply["author"], reply["permlink"], comment);
                                      },
                                    ),
                                  )
                                ],
                              ),
                            );
                          } catch (e) {}
                        }
                      },
                    )),
            )
          ],
        ),
      ),
    );
  }
}

class VideoScreenSearch extends StatefulWidget {
  final String permlink;
  var data;
  var description;
  var json_metadata;
  VideoScreenSearch({
    this.data,
    this.permlink,
    this.description,
    this.json_metadata,
  });
  @override
  VideoScreenSearchState createState() => new VideoScreenSearchState();
}

class VideoScreenSearchState extends State<VideoScreenSearch> {
  @override
  void initState() {
    super.initState();
    getVideo(widget.permlink, widget.data["author"]);
  }

  var content;
  var result = "loading";
  var subscribed = "Subscribe";
  var gateway = "https://video.dtube.top/ipfs/";
  VideoPlayerController _controller;
  String _vidString = "";

  getVideo(var permlink, var author) async {
    Dio dio = new Dio();
    Response response = await dio.post("https://api.steemit.com", data: {
      "id": 0,
      "jsonrpc": "2.0",
      "method": "call",
      "params": [
        "database_api",
        "get_state",
        ["/dtube/@" + author + "/" + permlink]
      ]
    });
    content = response.data["result"];
    var _temp = await retrieveData("gateway");
    setState(() {
      result = "loaded";
      gateway = _temp;
    });

    await sVideoController;
  }

  sVideoController(var videoJSON) async {
    var sourcesInit = [
      "480",
      "240",
      "720",
      "1080",
      "",
    ];
    var sources = {};
    int b = 0;
    String _tempVideo;
    for (int i = 0; i < 5; i++) {
      print(i);
      _tempVideo = videoJSON["video"]["content"]["video${sourcesInit[i]}hash"];
      if (_tempVideo != null) {
        print(_tempVideo);
        sources[b] = gateway + _tempVideo;
        b++;
      }
      if (i == 4) {
        setState(() {
          _controller = VideoPlayerController.network(sources[0]);
          _vidString = gateway + sources[0];
        });
      }
    }
  }

  //getVideo(permlink);
  @override
  Widget build(BuildContext context) {
    Screen.keepOn(true);
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: theme(selectedTheme)["background"],
        title: new Row(
          children: <Widget>[
            new Text(widget.data["title"], style: new TextStyle(color: theme(selectedTheme)["accent"])),
            new FlatButton(
                onPressed: () {
                  _launch(_vidString);
                },
                child: new Icon(Icons.open_in_new))
          ],
        ),
        automaticallyImplyLeading: false,
        leading: new Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new IconButton(
              icon: new Icon(
                Icons.arrow_back,
                color: theme(selectedTheme)["accent"],
              ),
              onPressed: () {
                try {
                  _controller.pause();
                } catch (e) {
                  try {
                    _controller.dispose();
                  } catch (e) {}
                  ;
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            _controller != null
                ? new Chewie(
                    _controller,
                    aspectRatio: 16 / 9,
                    autoPlay: true,
                    looping: false,
                  )
                : new Text("Loading video..."),
            new Container(
              child: result == "loading"
                  ? new Text("loading...")
                  : new Expanded(
                      child: new ListView(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: new Row(
                            children: <Widget>[
                              new Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: new CircleAvatar(
                                  backgroundImage: new NetworkImage("https://steemitimages.com/u/" + widget.data["author"] + "/avatar/small"),
                                ),
                              ),
                              new Column(
                                children: <Widget>[
                                  new Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: new Text(widget.data["author"]),
                                  ),
                                  new RaisedButton(
                                    color: theme(selectedTheme)["primary"],
                                    onPressed: () async {
                                      var tempSub = await broadcastSubscribe(context, widget.data["author"]);
                                      subscribed = "Subscribed";
                                    },
                                    child: new Text(subscribed, style: new TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  new IconButton(
                                      icon: const Icon(FontAwesomeIcons.thumbsUp),
                                      color: theme(selectedTheme)["accent"],
                                      onPressed: () {
                                        print("pressed");
                                      }),
                                  new IconButton(
                                      icon: const Icon(FontAwesomeIcons.thumbsDown),
                                      color: theme(selectedTheme)["accent"],
                                      onPressed: () {
                                        print("pressed");
                                      }),
                                  new Text(
                                    widget.data["payout"].toString(),
                                    style: new TextStyle(fontSize: 15.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        new Divider(
                          height: 1.0,
                          color: theme(selectedTheme)["accent"],
                          indent: 0.0,
                        ),
                        new Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: new Column(
                              children: <Widget>[
                                new Text("Added on " + widget.data["created"]),
                                new HtmlText(data: linkify(widget.description)),
                              ],
                            ))
                        // TODO: comments class
                      ],
                    )),
            )
          ],
        ),
      ),
    );
  }
}
