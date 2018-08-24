import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:simple_moment/simple_moment.dart';
import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:screen/screen.dart';
import 'package:flutter_html_view/flutter_html_text.dart';
import 'api.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:video_launcher/video_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../screens/profile.dart';
import '../components/videolist.dart';


class VideoScreen extends StatefulWidget {
  final String permlink;
  final data;
  final description;
  final meta;
  final search;
  VideoScreen({
    this.data,
    this.search,
    this.permlink,
    this.description,
    this.meta,
  });
  @override
  VideoScreenState createState() => new VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  // colors for videos
  var upvoteColor = theme(selectedTheme)["accent"];
  var downvoteColor = theme(selectedTheme)["accent"];
  // colors for comments
  var upvoteColors = {};
  var downvoteColors = {};

  var subscribeColor = Colors.white;
  var subscribeButtonColor = Colors.red;
  var subscribed = "Subscribe";
  var gateway = "https://video.dtube.top/ipfs/";
  Chewie chewiePlayer;
  VideoPlayerController videoController;

  var _ios = Platform.isIOS;
  InterstitialAd myInterstitial;

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    keywords: <String>[
      'crypto',
      'dtube',
      'business',
      'currency',
      'blockchain',
      'bitcoin',
      'steem',
      'steemit'
    ],
    contentUrl: 'https://d.tube',
    childDirected: false,
    designedForFamilies:
    false, // or MobileAdGender.female, MobileAdGender.unknown
    testDevices: <String>[
      testDevice
    ], // Android emulators are considered test devices
  );

  @override
  void initState() {
    super.initState();
    getVideo(widget.permlink, widget.data["author"]);
    if (_ios == true) {
      FirebaseAdMob.instance
          .initialize(appId: "ca-app-pub-9430927632405311~9708042281");
    } else {
      FirebaseAdMob.instance
          .initialize(appId: "ca-app-pub-9430927632405311~3245387668");
    }
    if (_ios == true) {
      myInterstitial = new InterstitialAd(
        targetingInfo: targetingInfo,
        adUnitId: "ca-app-pub-9430927632405311/9921156081",
        listener: (MobileAdEvent event) {
          print("InterstitialAd event is $event");
        },
      );
    } else {
      myInterstitial = new InterstitialAd(
        targetingInfo: targetingInfo,
        adUnitId: "ca-app-pub-9430927632405311/4144105868",
        listener: (MobileAdEvent event) {
          print("InterstitialAd event is $event");
        },
      );
    }
    myInterstitial..load();
    initializeNotifications();
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
    setState(() {
      result = "loaded";
      gateway = _temp;
    });

    if (videoController == null) {
      setState(() {
        print(gateway +
            widget.meta["video"]["content"]["video${sources()[0]}hash"]);
        videoController = VideoPlayerController.network(gateway +
            widget.meta["video"]["content"]["video${sources()[0]}hash"]);
        chewiePlayer = new Chewie(
          videoController,
          aspectRatio: 16 / 9,
          autoPlay: true,
          looping: false,
          placeholder: new Container(
              child: Image.network("https://snap1.d.tube/ipfs/" +
                  widget.meta['video']['info']['snaphash'])),
        );
      });
    }
  }

  List sources() {
    var sourcesInit = [
      "480",
      "240",
      "720",
      "1080",
      "",
    ];
    List _tempSources = [];
    int b = 0;
    String _tempVideo;
    for (int i = 0; i < 5; i++) {
      _tempVideo =
      widget.meta["video"]["content"]["video${sourcesInit[i]}hash"];
      if (_tempVideo != null) {
        _tempSources.add(sourcesInit[i]);
      }
      if (i == 4) {
        return _tempSources;
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
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;
    if (isLandscape && videoController != null) {}
    Screen.keepOn(true);
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        backgroundColor: theme(selectedTheme)["background"],
        body: result == "loading"
            ? Center(child: new CircularProgressIndicator())
            : Column(
          children: <Widget>[
            Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: videoController != null
                    ? chewiePlayer
                    : new CircularProgressIndicator(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (contextListViewBuilder, index) {
                  if (index == 0)
                    return new Column(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: new Text(
                                widget.data["title"],
                                style: TextStyle(
                                    color: theme(selectedTheme)["text"],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                            new Text(
                              "\$" +
                                  (widget.search
                                      ? widget.data["payout"]
                                      : widget.data[
                                  "pending_payout_value"])
                                      .toString()
                                      .replaceFirst(" SBD", ""),
                              style: new TextStyle(
                                  fontSize: 14.0,
                                  color: theme(selectedTheme)["accent"]),
                            ),
                          ],
                        ),
                        new Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: new Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // interaction row
                              new IconButton(
                                  icon: const Icon(Icons.thumb_up),
                                  color: upvoteColor,
                                  onPressed: () {
                                    if (downvoteColor !=
                                        theme(selectedTheme)["accent"]) {
                                      setState(() {
                                        downvoteColor = theme(
                                            selectedTheme)["accent"];
                                      });
                                    }
                                    setState(() {
                                      upvoteColor =
                                      theme(selectedTheme)["primary"];
                                    });
                                    return voteDialog(
                                        true,
                                        widget.data["author"],
                                        widget.permlink,
                                        contextListViewBuilder);
                                  }),
                              new IconButton(
                                  icon: const Icon(Icons.thumb_down),
                                  color: downvoteColor,
                                  onPressed: () {
                                    if (upvoteColor !=
                                        theme(selectedTheme)["accent"]) {
                                      setState(() {
                                        upvoteColor = theme(
                                            selectedTheme)["accent"];
                                      });
                                    }
                                    setState(() {
                                      downvoteColor =
                                      theme(selectedTheme)["primary"];
                                    });
                                    return voteDialog(
                                        false,
                                        widget.data["author"],
                                        widget.permlink,
                                        contextListViewBuilder);
                                  }),
                              new IconButton(
                                icon: const Icon(Icons.share),
                                color: theme(selectedTheme)["accent"],
                                onPressed: () {
                                  Share.share("https://d.tube/v/" +
                                      widget.data["author"] +
                                      "/" +
                                      widget.data["permlink"]);
                                },
                              ),
                              new IconButton(
                                icon: const Icon(Icons.file_download),
                                color: theme(selectedTheme)["accent"],
                                onPressed: () async {
                                  return showDialog<Null>(
                                    context: context,
                                    builder:
                                        (BuildContext dialogContext) {
                                      List<Widget> resolutions =
                                      <Widget>[];
                                      print(sources());
                                      for (int i = 0;
                                      i < sources().length;
                                      i++) {
                                        String _tempName;
                                        switch (sources()[i]) {
                                          case "240":
                                            _tempName = "SD - 240p";
                                            break;
                                          case "480":
                                            _tempName = "SD - 480p";
                                            break;
                                          case "720":
                                            _tempName = "HD - 720p";
                                            break;
                                          case "1080":
                                            _tempName = "HD - 1080p";
                                            break;
                                          case "":
                                            _tempName =
                                            "Source (Highest)";
                                            break;
                                        }
                                        resolutions.add(FlatButton(
                                          onPressed: () {
                                            downloadFile(
                                                widget.meta["video"]
                                                ["content"][
                                                "video${sources()[i]}hash"],
                                                false,
                                                contextListViewBuilder,
                                                widget.meta["title"]);
                                            Navigator.pop(dialogContext);
                                          },
                                          child: Text(
                                            _tempName,
                                            style: TextStyle(
                                                color:
                                                theme(selectedTheme)[
                                                "text"]),
                                          ),
                                        ));
                                        if (i == sources().length - 1) {
                                          resolutions.add(FlatButton(
                                            onPressed: () {
                                              downloadFile(
                                                  widget.meta["video"]
                                                  ["content"][
                                                  "video${sources()[i]}hash"],
                                                  true,
                                                  contextListViewBuilder,
                                                  widget.meta["title"]);
                                              Navigator
                                                  .pop(dialogContext);
                                            },
                                            child: Text(
                                              "Audio only",
                                              style: TextStyle(
                                                color:
                                                theme(selectedTheme)[
                                                "text"],
                                              ),
                                            ),
                                          ));
                                        }
                                      }
                                      return new AlertDialog(
                                          title: Text(
                                              "Select video quality:"),
                                          content: SingleChildScrollView(
                                            child: Column(
                                                children: resolutions),
                                          ));
                                    },
                                  );
                                },
                              ),
                              new IconButton(
                                icon: const Icon(Icons.open_in_new),
                                color: theme(selectedTheme)["accent"],
                                onPressed: () {
                                  launchVideo(videoController.dataSource);
                                },
                              ),
                            ],
                          ),
                        ),
                        new Divider(
                          height: 1.0,
                          color: theme(selectedTheme)["text"],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 6.0, right: 10.0),
                          child: new Row(
                            // avatar, name, subscribe row
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                          new ProfileScreen(
                                              profile: widget
                                                  .data["author"])));
                                },
                                child: Row(
                                  children: <Widget>[
                                    new Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: new CircleAvatar(
                                        radius: 18.0,
                                        backgroundImage: new NetworkImage(
                                            "https://steemitimages.com/u/" +
                                                widget.data["author"] +
                                                "/avatar/big"),
                                      ),
                                    ),
                                    new Text(
                                      widget.data["author"],
                                      style: TextStyle(
                                        color:
                                        theme(selectedTheme)["text"],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              new RaisedButton(
                                color: subscribeButtonColor,
                                onPressed: () async {
                                  setState(() {
                                    subscribed = subscribed == "Subscribe"
                                        ? "Unsubscribe"
                                        : "Subscribe";
                                    subscribeColor =
                                    subscribed == "Subscribe"
                                        ? Colors.white
                                        : Colors.white;
                                    subscribeButtonColor =
                                    subscribed == "Subscribe"
                                        ? Colors.red
                                        : Colors.grey;
                                  });
                                  await broadcastSubscribe(
                                      contextListViewBuilder,
                                      widget.data["author"],
                                      subscribed == "Subscribe"
                                          ? true
                                          : false);
                                },
                                child: new Text(subscribed,
                                    style: new TextStyle(
                                        color: subscribeColor)),
                              ),
                            ],
                          ),
                        ),
                        new Divider(
                          height: 1.0,
                          color: theme(selectedTheme)["text"],
                        ),
                        new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Text(
                                    "added " +
                                        moment.from(DateTime
                                            .parse(widget.data["created"])
                                            .add(Duration(hours: 2))),
                                    style: TextStyle(
                                      color: theme(selectedTheme)["text"],
                                    ),
                                  ),
                                ),
                                new HtmlText(
                                    data: theme(selectedTheme)["text"] ==
                                        Colors.white
                                        ? "<p style=\"color: #fff;\">" +
                                        linkify(
                                            (widget.description)) +
                                        "</p>"
                                        : linkify((widget.description))),
                                new Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new TextField(
                                    decoration: new InputDecoration(
                                        hintText: 'Comment something...',
                                        hintStyle: TextStyle(
                                          color: theme(selectedTheme)[
                                          "text"],
                                        )),
                                    onSubmitted: (comment) {
                                      broadcastComment(
                                          contextListViewBuilder,
                                          widget.data["author"],
                                          widget.permlink,
                                          comment.toString());
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
                      var reply = content[content[widget.data["author"] +
                          "/" +
                          widget.permlink]["replies"][index - 1]
                          .toString()];
                      var comment = linkify(reply["body"]);
                      if ((reply["body"].toString()).length > 100) {
                        comment = linkify(reply["body"].substring(0, 100))
                            .toString() +
                            "...";
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
                                    radius: 13.0,
                                    backgroundImage: new NetworkImage(
                                        "https://steemitimages.com/u/" +
                                            reply["author"] +
                                            "/avatar/small"),
                                  ),
                                  new Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        new Text(
                                          reply["author"],
                                          style:
                                          TextStyle(fontSize: 14.0),
                                        ),
                                        new Row(
                                          children: <Widget>[
                                            new Text(
                                              moment.from(DateTime
                                                  .parse(reply["created"])
                                                  .add(Duration(
                                                  hours: 2))),
                                              style: TextStyle(
                                                  color: theme(
                                                      selectedTheme)[
                                                  "accent"],
                                                  fontSize: 12.0),
                                            ),
                                            new Padding(
                                              padding:
                                              const EdgeInsets.only(
                                                  left: 4.0),
                                              child: new Text(
                                                  "\$" +
                                                      reply["pending_payout_value"]
                                                          .toString()
                                                          .replaceFirst(
                                                          "SBD", ""),
                                                  style: TextStyle(
                                                      color: theme(
                                                          selectedTheme)[
                                                      "accent"],
                                                      fontSize: 12.0)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              new Text(
                                comment,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: theme(selectedTheme)["text"],
                                ),
                              ),
                            ],
                          ),
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(16.0),
                              child:
                              (reply["body"].toString()).length > 100
                                  ? new HtmlText(
                                  data: linkify(reply["body"]))
                                  : new Container(),
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                new Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new IconButton(
                                      icon: const Icon(Icons.thumb_up),
                                      color: upvoteColors[
                                      reply["permlink"]] ??
                                          theme(selectedTheme)["accent"],
                                      onPressed: () {
                                        print(reply["permlink"]);
                                        if (downvoteColors[
                                        reply["permlink"]] !=
                                            null) {
                                          setState(() {
                                            downvoteColors.remove(
                                                reply["permlink"]);
                                          });
                                        }
                                        setState(() {
                                          upvoteColors[
                                          reply["permlink"]] =
                                          theme(selectedTheme)[
                                          "primary"];
                                        });
                                        return voteDialog(
                                            true,
                                            reply["author"],
                                            reply["permlink"],
                                            contextListViewBuilder);
                                      }),
                                ),
                                new Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new IconButton(
                                      icon: const Icon(Icons.thumb_down),
                                      color: downvoteColors[
                                      reply["permlink"]] ??
                                          theme(selectedTheme)["accent"],
                                      onPressed: () {
                                        if (upvoteColors[
                                        reply["permlink"]] !=
                                            null) {
                                          setState(() {
                                            upvoteColors.remove(
                                                reply["permlink"]);
                                          });
                                        }
                                        setState(() {
                                          downvoteColors[
                                          reply["permlink"]] =
                                          theme(selectedTheme)[
                                          "primary"];
                                        });
                                        return voteDialog(
                                            false,
                                            reply["author"],
                                            reply["permlink"],
                                            contextListViewBuilder);
                                      }),
                                ),
                              ],
                            ),
                            new Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: new TextField(
                                decoration: new InputDecoration(
                                    hintText: 'Comment something...',
                                    hintStyle: TextStyle(
                                      color: theme(selectedTheme)["text"],
                                    )),
                                onSubmitted: (comment) {
                                  broadcastComment(
                                      contextListViewBuilder,
                                      reply["author"],
                                      reply["permlink"],
                                      comment);
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    } catch (e) {}
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
