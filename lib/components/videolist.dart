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
import 'package:admob/admob.dart';
import 'package:flutter/services.dart';

String APP_ID = "ca-app-pub-9430927632405311~3245387668";
String AD_UNIT_ID = "ca-app-pub-9430927632405311/4144105868";
String DEVICE_ID = "Only necessary for testing: The device id you are testing with";
bool TESTING = true;

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
  var _loadInterstitialResponse;
  var _showInterstitialResponse;

  @override
  void initState() {
    super.initState();
    print(_loadInterstitialResponse);
    loadInterstitialAd();
    getVideo(widget.permlink, widget.data["author"]);
  }

  loadInterstitialAd() async {
    var loadResponse;
    try {
      loadResponse = await Admob.loadInterstitial(APP_ID, AD_UNIT_ID, DEVICE_ID, TESTING);
    } on PlatformException {
      loadResponse = "false";
    }
    setState(() {
      _loadInterstitialResponse = loadResponse;
    });
  }

  showInterstitialAd() async {
    var showResponse;
    try {
      showResponse = await Admob.showInterstitial;
    } on PlatformException {
      showResponse = "false";
    }
    setState(() {
      _showInterstitialResponse = showResponse;
    });
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
    setState(() {
      result = "loaded";
    });
  }

  videoController(var vidURL) {
    try {
      return new VideoPlayerController.network("https://ipfs.io/ipfs/" + vidURL["video"]["content"]["video480hash"]);
    } catch (e) {
      try {
        return new VideoPlayerController.network("https://ipfs.io/ipfs/" + vidURL["video"]["content"]["video240hash"]);
      } catch (e) {
        try {
          return new VideoPlayerController.network("https://ipfs.io/ipfs/" + vidURL["video"]["content"]["video720hash"]);
        } catch (e) {
          try {
            return new VideoPlayerController.network("https://ipfs.io/ipfs/" + vidURL["video"]["content"]["video1080hash"]);
          } catch (e) {
            return new VideoPlayerController.network("https://ipfs.io/ipfs/" + vidURL["video"]["content"]["videohash"]);
          }
        }
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
        backgroundColor: Colors.white,
        title: new Text(widget.data["title"], style: new TextStyle(color: Colors.grey)),
        automaticallyImplyLeading: false,
        leading: new Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new IconButton(
              icon: new Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.pop(contextWidget);
                showInterstitialAd();
              },
            ),
          ],
        ),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new Chewie(
              videoController(widget.json_metadata),
              aspectRatio: 3 / 2,
              autoPlay: true,
              looping: true,
            ),
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
                                              color: Colors.redAccent,
                                              onPressed: () {
                                                print("pressed");
                                              },
                                              child: new Text("Subscribe", style: new TextStyle(color: Colors.white)),
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
                                            color: Colors.grey,
                                            onPressed: () {
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
                                                          onPressed: () async {
                                                            Navigator.of(contextStatefulBuilder, rootNavigator: true).pop(result);
                                                            var voted = await broadcast(widget.data["author"], widget.permlink, toInt(sliderValue));

                                                            return Scaffold.of(contextListViewBuilder).showSnackBar(new SnackBar(
                                                                  content: new Text(voted["result"] != null
                                                                      ? "Success"
                                                                      : voted["error_description"].toString().split(":")[1]),
                                                                ));
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
                                            color: Colors.grey,
                                            onPressed: () {
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
                                                            var voted = await broadcast(widget.data["author"], widget.permlink, toInt(sliderValue));

                                                            return Scaffold.of(contextListViewBuilder)
                                                              ..showSnackBar(new SnackBar(
                                                                content: new Text(voted["result"] != null
                                                                    ? "Success"
                                                                    : voted["error_description"].toString().split(":")[1]),
                                                              ));
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
                                color: Colors.grey,
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
                                          decoration: new InputDecoration(hintText: 'Comment something...'),
                                          onSubmitted: (comment) {},
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
                                                    style: TextStyle(color: Colors.grey, fontSize: 12.0),
                                                  ),
                                                  new Padding(
                                                    padding: const EdgeInsets.only(left: 4.0),
                                                    child: new Text("\$" + reply["pending_payout_value"].toString().replaceFirst("SBD", ""),
                                                        style: TextStyle(color: Colors.grey, fontSize: 12.0)),
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
                                          color: Colors.grey,
                                        ),
                                      ),
                                      new Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: new Icon(
                                          FontAwesomeIcons.thumbsDown,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  new Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new TextField(
                                      decoration: new InputDecoration(hintText: 'Comment something...'),
                                      onSubmitted: (comment) {},
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
    setState(() {
      result = "loaded";
    });
  }

  videoController(var vidURL) {
    try {
      return new VideoPlayerController.network("https://ipfs.io/ipfs/" + vidURL["video"]["content"]["video480hash"]);
    } catch (e) {
      try {
        return new VideoPlayerController.network("https://ipfs.io/ipfs/" + vidURL["video"]["content"]["video240hash"]);
      } catch (e) {
        try {
          return new VideoPlayerController.network("https://ipfs.io/ipfs/" + vidURL["video"]["content"]["video720hash"]);
        } catch (e) {
          try {
            return new VideoPlayerController.network("https://ipfs.io/ipfs/" + vidURL["video"]["content"]["video1080hash"]);
          } catch (e) {
            return new VideoPlayerController.network("https://ipfs.io/ipfs/" + vidURL["video"]["content"]["videohash"]);
          }
        }
      }
    }
  }

  //getVideo(permlink);
  @override
  Widget build(BuildContext context) {
    Screen.keepOn(true);
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white,
        title: new Text(widget.data["title"], style: new TextStyle(color: Colors.grey)),
        automaticallyImplyLeading: false,
        leading: new Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new IconButton(
              icon: new Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new Chewie(
              videoController(widget.json_metadata),
              aspectRatio: 3 / 2,
              autoPlay: true,
              looping: true,
            ),
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
                                    color: Colors.redAccent,
                                    onPressed: () {
                                      print("pressed");
                                    },
                                    child: new Text("Subscribe", style: new TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  new IconButton(
                                      icon: const Icon(FontAwesomeIcons.thumbsUp),
                                      color: Colors.grey,
                                      onPressed: () {
                                        print("pressed");
                                      }),
                                  new IconButton(
                                      icon: const Icon(FontAwesomeIcons.thumbsDown),
                                      color: Colors.grey,
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
                          color: Colors.grey,
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
