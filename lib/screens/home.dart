import 'package:flutter/material.dart';
import '../components/api.dart';
import 'dart:convert';
import '../components/videolist.dart';
import 'login.dart';
import 'feed.dart';
import '../main.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => new HomeScreenState();
}

var design = true;
var initialFutureData;
var initialFutureDataDesign;

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: !design
          ? new FutureBuilder(
              future: steemit.getAll(user), // a Future<String> or null
              initialData: initialFutureData,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Center(child: new Text('No connection...'));
                  case ConnectionState.waiting:
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new CircularProgressIndicator(),
                    ));
                  default:
                    if (snapshot.hasError) return Center(child: new Text('Error: ${snapshot.error}'));

                    initialFutureData = snapshot.data;

                    int jump = 0;
                    var indexerNum = 0;
                    var indexer = [];

                    var videoItemList = <Widget>[];
                    for (var i = 0; i < snapshot.data[0]["result"].length; i++) {
                      {
                        int index = i + jump;
                        var data = snapshot.data[0]["result"][index];
                        var permlink = data["permlink"];
                        if (json.decode(data['json_metadata'])["video"] != null) {
                          var title = data['title'];
                          String description;
                          description = json.decode(data['json_metadata'])["video"]["content"]["description"];
                          videoItemList.add(buildRow(data, index, title, description, permlink, context, true));
                          indexer.add(indexerNum);
                          indexerNum++;
                        }
                      }
                    }

                    int jump1 = 0;
                    int jump2 = 0;
                    int jump3 = 0;

                    List videoItemListArray = [<Widget>[], <Widget>[], <Widget>[], <Widget>[]];
                    _buildList(num, jump0) {
                      var resdata = snapshot.data[num];
                      for (var i = 0; i < resdata["result"].length - 1; i++) {
                        {
                          int index = i + jump0;
                          var data = resdata["result"][index];
                          var permlink = data["permlink"];
                          if (json.decode(data['json_metadata'])["video"] != null) {
                            var title = data['title'];
                            String description;
                            description = json.decode(data['json_metadata'])["video"]["content"]["description"];
                            videoItemListArray[num].add(buildRow(data, index, title, description, permlink, context, false));
                          }
                        }
                      }
                    }
                    _buildList(1, jump1);
                    _buildList(2, jump2);
                    _buildList(3, jump3);

                    return NestedScrollView(
                      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          sliverAppBar(),
                        ];
                      },
                      body: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            CarouselSlider(
                                items: [0, 1, 2].map((i) {
                                  return new Builder(builder: (BuildContext context) => videoItemList[i]);
                                }).toList(),
                                aspectRatio: 16 / 7,
                                autoPlay: true),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Divider(),
                            ),
                            new Container(
                                height: 210.0,
                                color: theme(selectedTheme)["background"],
                                child: new ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, i) =>
                                        Padding(padding: EdgeInsets.only(left: 4.0, right: 4.0), child: videoItemListArray[1][i]))),
                            new Container(
                                height: 210.0,
                                color: theme(selectedTheme)["background"],
                                child: new ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, i) =>
                                        Padding(padding: EdgeInsets.only(left: 4.0, right: 4.0), child: videoItemListArray[2][i]))),
                            new Container(
                                height: 210.0,
                                color: theme(selectedTheme)["background"],
                                child: new ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, i) =>
                                        Padding(padding: EdgeInsets.only(left: 4.0, right: 4.0), child: videoItemListArray[3][i]))),
                          ],
                        ),
                      ),
                    );
                }
              })
          : new FutureBuilder(
              future: steemit.getDiscussionsByHot(), // a Future<String> or null
              initialData: initialFutureDataDesign,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Center(child: new Text('No connection...'));
                  case ConnectionState.waiting:
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new CircularProgressIndicator(),
                    ));
                  default:
                    if (snapshot.hasError) return Center(child: new Text('Error: ${snapshot.error}'));

                    initialFutureDataDesign = snapshot.data;

                    int jump2 = 0;
                    List videoItemListArray = [<Widget>[], <Widget>[], <Widget>[], <Widget>[]];
                    _buildList(num) {
                      var resdata = snapshot.data;
                      for (var i = 0; i < resdata["result"].length - 1; i++) {
                        {
                          int index = i + jump2;
                          var data = resdata["result"][index];
                          var permlink = data["permlink"];
                          if (json.decode(data['json_metadata'])["video"] != null) {
                            var title = data['title'];
                            String description;
                            description = json.decode(data['json_metadata'])["video"]["content"]["description"];
                            videoItemListArray[num].add(buildRow(data, index, title, description, permlink, context, false));
                          }
                        }
                      }
                    }
                    _buildList(0);

                    return NestedScrollView(
                        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            sliverAppBar(),
                          ];
                        },
                        body: new Container(
                            color: theme(selectedTheme)["background"],
                            child: new ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: videoItemListArray[0].length,
                                itemBuilder: (context, i) => Padding(padding: EdgeInsets.only(bottom: 20.0), child: videoItemListArray[0][i]))));
                }
              }),
    );
  }

  SliverAppBar sliverAppBar() {
    return SliverAppBar(
        pinned: true,
        title: Stack(
          children: <Widget>[
            Center(child: Container(height: 30.0, child: Image.asset('assets/DTube_Black.png'))),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Switch(
                  activeColor: theme(selectedTheme)["primary"],
                  value: design,
                  onChanged: (e) {
                    setState(() {
                      design = e;
                    });
                  },
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: user == null
                      ? Icon(Icons.person)
                      : new CircleAvatar(
                          backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
                          backgroundImage: new NetworkImage("https://steemitimages.com/u/" + user + "/avatar/small"),
                        ),
                  onPressed: () {
                    if (user == null) {
                      Navigator.push(context, new MaterialPageRoute(builder: (context) => LoginScreen()));
                    } else {
                      Navigator.push(context, new MaterialPageRoute(builder: (context) => BuildFeed()));
                    }
                  },
                ),
              ],
            ),
          ],
        ));
  }
}
