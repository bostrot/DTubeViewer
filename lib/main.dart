import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'components/videolist.dart';
import 'components/api.dart';
import 'screens/feed.dart';
import 'screens/settings.dart';
import 'screens/search.dart';
import 'package:uni_links/uni_links.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

var videoData;
StreamSubscription _sub;

// analytics
FirebaseAnalytics analytics = new FirebaseAnalytics();

class TabNav extends StatefulWidget {
  @override
  createState() => new TabNavState();
}

Future<Null> initUniLinks() async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  // Attach a listener to the stream
  _sub = getLinksStream().listen((String link) async {
    saveData("user", link.split("username=")[1]);
    saveData("key", link.split("access_token=")[1].split("&expires")[0]);
    //print(link.split("access_token=")[1].split("&expires")[0]);
    // Parse the link and warn the user, if it is not correct
    await analytics.logLogin();
  }, onError: (err) {
    print(err);
    // Handle exception by warning the user their action did not succeed
  });
  _sub;
}

class TabNavState extends State<TabNav> {
  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 5,
      child: new Scaffold(
          // TODO: remove appbar and add tabbar right under statusbar
          appBar: new AppBar(
            backgroundColor: theme(selectedTheme)["background"],
            bottom: new TabBar(
              isScrollable: false,
              indicatorColor: theme(selectedTheme)["primary"],
              labelColor: theme(selectedTheme)["primary"],
              unselectedLabelColor: theme(selectedTheme)["accent"],
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
              decoration: new InputDecoration(border: InputBorder.none, hintText: 'Search...'),
              onSubmitted: (search) {
                Navigator.push(context, new MaterialPageRoute(builder: (context) => new SearchScreen(search: search)));
              },
            ),
          ),
          body: new TabBarView(
            children: [
              buildSubtitles(steemit.getDiscussionsByHot(), context),
              buildSubtitles(steemit.getDiscussionsByTrending(), context),
              buildSubtitles(steemit.getDiscussionsByCreated(), context),
              BuildFeed(),
              BuildSettings(),
            ],
          )),
    );
  }
}

void main() async {
  // set theme
  var _tempTheme = await retrieveData("theme");
  if (_tempTheme != null && _tempTheme != "value") {
    print(_tempTheme);
    selectedTheme = _tempTheme;
  } else {
    selectedTheme = "normal";
  }

  // first start
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  int buildNumber = int.parse(packageInfo.buildNumber);
  var _tempBuildNumber = await retrieveData("buildNumber");
  if (_tempBuildNumber == null || int.parse(_tempBuildNumber) < buildNumber) {
    saveData("gateway", "https://video.dtube.top/ipfs/");
    saveData("buildNumber", buildNumber.toString());
  }

  /* start count
  var _tempStarted = await retrieveData("started");
  var _tempLastStarted = await retrieveData("lastStarted");

  var date = new DateTime.now();
  saveData("lastStarted", date.toString());

  if (date.toString().substring(0, 8) == _tempLastStarted.toString().substring(0, 8) &&
      int.parse(date.toString().substring(8, 10)) == int.parse(_tempLastStarted.substring(8, 10)) + 1)
    saveData("started", ((_tempStarted != null ? int.parse(_tempStarted) : 0) + 1).toString());
  */

  // set up linking listener
  initUniLinks();
  var internet = true;

  /* lock orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);*/

  // get api data
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: internet ? TabNav() : new Center(child: new Text("An error occured. Please check your internet connection.")),
      navigatorObservers: [
        new FirebaseAnalyticsObserver(analytics: analytics),
      ],
    ),
  );
  analytics.logAppOpen();
}
