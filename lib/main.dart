import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:english_words/english_words.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:simple_moment/simple_moment.dart';
import 'dart:async';
import 'components/videolist.dart';
import 'components/api.dart';
import 'package:flutter/services.dart';
import 'screens/feed.dart';
import 'screens/settings.dart';
import 'screens/search.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'dart:io';

var apiData;
var videoData;
StreamSubscription _sub;

class TabNav extends StatefulWidget {
  @override
  createState() => new TabNavState();
}

Future<Null> initUniLinks() async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    String initialLink = await getInitialLink();
    print("link: " + initialLink);
    // Parse the link and warn the user, if it is not correct,
    // but keep in mind it could be `null`.
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
  }

  // Attach a listener to the stream
  _sub = getLinksStream().listen((String link) {
    saveData(link.split("username=")[1], link.split("access_token=")[1].split("&expires")[0]);
    print(link.split("username=")[1] + link.split("access_token=")[1].split("&expires")[0]);
    // Parse the link and warn the user, if it is not correct
  }, onError: (err) {
    // Handle exception by warning the user their action did not succeed
  });
}

class TabNavState extends State<TabNav> {
  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 5,
      child: new Scaffold(
        // TODO: remove appbar and add tabbar right under statusbar
        appBar: new AppBar(
          backgroundColor: Colors.white,
          bottom: new TabBar(
            indicatorColor: Colors.redAccent,
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 0.5,
            tabs: [
              new Tab(icon: new Icon(FontAwesomeIcons.fire)),
              new Tab(icon: new Icon(FontAwesomeIcons.trophy)),
              new Tab(icon: new Icon(FontAwesomeIcons.hourglass)),
              new Tab(icon: new Icon(FontAwesomeIcons.th)),
              new Tab(icon: new Icon(FontAwesomeIcons.cogs)),
            ],
          ),
          title: new TextField(
            decoration: new InputDecoration(
                border: InputBorder.none, hintText: 'Search...'),
            onSubmitted: (search) {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                  builder: (context) => new SearchScreen(
                  search: search))
              );
            },
          ),
        ),
        body: new TabBarView(
          children: [
            _buildSubtitles(0),
            _buildSubtitles(1),
            _buildSubtitles(2),
            buildFeed(),
            buildSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitles(int tab) {
    int jump = 0;
    return new RefreshIndicator(
      child: new GridView.builder(
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 2.0,
            crossAxisCount: 2,
            mainAxisSpacing: 5.0,
          ),
          itemCount: 30, // TODO: add _subtitles.length after update
          padding: const EdgeInsets.all(4.0),
          itemBuilder: (context, i) {
            i = i + jump;
            final index = i;
            var data = apiData[tab]["result"][index];
            var permlink = data["permlink"];
            try {
              var title =
                  data['json_metadata'].split('"title":"')[1].split('",')[0];
              String description = data['json_metadata']
                  .split(',"description":"')[1]
                  .split('",')[0];
              return _buildRow(data, index, title, description, permlink);
            } catch (e) {
              return new InkResponse(
                child: new Column(
                  children: <Widget>[
                    _placeholderImage(null),
                    new Text("uploader messed up.",
                        style: new TextStyle(fontSize: 14.0), maxLines: 2),
                  ],
                ),
                onTap: () {
                  print('tabbed');
                },
              );
            }
          }),
      onRefresh: () async {
        setState(() async {
          apiData = [
            await getDiscussions(0, null, null),
            await getDiscussions(1, null, null),
            await getDiscussions(2, null, null)
          ];
        });
        return apiData;
      },
    );
  }

  Widget _placeholderImage(var imgURL) {
    try {
      return Image.network("https://snap1.d.tube/ipfs/" + imgURL, fit: BoxFit.scaleDown,);
    } catch (e) {
      return Image.network(
          "https://snap1.d.tube/ipfs/Qma585tFzjmzKemYHmDZoKMZHo8Ar7YMoDAS66LzrM2Lm1", fit: BoxFit.scaleDown,);
    }
  }

  Widget _buildRow(
      var data, var index, var title, var description, var permlink) {
    var moment = new Moment.now();
    // handle metadata from (string)json_metadata
    var json_metadata = json.decode(data['json_metadata']
        .replaceAll(description, "")
        .replaceAll(title, ""));
    return new InkWell(
      child: new Column(
        children: <Widget>[
          _placeholderImage(json_metadata['video']['info']['snaphash']),
          new Text(title, style: new TextStyle(fontSize: 14.0), maxLines: 2),
          new Text("by " + data['author'],
              style: new TextStyle(fontSize: 12.0, color: Colors.grey),
              maxLines: 1),
          new Text(
              "\$" +
                  data['pending_payout_value'].replaceAll("SBD", "") +
                  " • " +
                  moment.from(DateTime.parse(data['created'])),
              style: new TextStyle(fontSize: 12.0, color: Colors.grey),
              maxLines: 1),
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
                  json_metadata: json_metadata)),
        );
      },
    );
  }
}

void main() async {
  initUniLinks();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // TODO: splashscreen
  // TODO: icons
  apiData = [
    await getDiscussions(0, null, null),
    await getDiscussions(1, null, null),
    await getDiscussions(2, null, null)
  ];
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TabNav(),
    ),
  );
}
