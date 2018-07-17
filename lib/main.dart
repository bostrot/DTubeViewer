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

import 'screens/login.dart';

var videoData;
StreamSubscription _sub;

// analytics
FirebaseAnalytics analytics = new FirebaseAnalytics();

class TabNav extends StatefulWidget {
  @override
  createState() => new TabNavState();
}

class TabNavState extends State<TabNav> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 5,
        child: new Scaffold(
          // TODO: remove appbar and add tabbar right under statusbar
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: new AppBar(
              elevation: 0.2,
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
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              return showDialog<Null>(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    content: new TextField(
                      decoration: new InputDecoration(border: InputBorder.none, hintText: 'Search...'),
                      onSubmitted: (search) {
                        Navigator.push(context, new MaterialPageRoute(builder: (context) => new SearchScreen(search: search)));
                      },
                    ),
                  );
                },
              );
            },
            child: Icon(Icons.search),
          ),
        ));
  }
}

/*
new TextField(
              decoration: new InputDecoration(border: InputBorder.none, hintText: 'Search...'),
              onSubmitted: (search) {
                Navigator.push(context, new MaterialPageRoute(builder: (context) => new SearchScreen(search: search)));
              },
            ),
 */

void main() async {
  // set theme
  var _tempTheme = await retrieveData("theme");
  if (_tempTheme != null && _tempTheme != "value") {
    print(_tempTheme);
    selectedTheme = _tempTheme;
  } else {
    selectedTheme = "normal";
  }

  var internet = true;

  // first start
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  int buildNumber = int.parse(packageInfo.buildNumber);
  var _tempBuildNumber = await retrieveData("buildNumber");

  if (_tempBuildNumber == null || int.parse(_tempBuildNumber) < buildNumber) {
    saveData("gateway", "https://video.dtube.top/ipfs/");
    saveData("buildNumber", buildNumber.toString());
    runApp(
      MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        debugShowCheckedModeBanner: false,
        home: internet ? LoginScreen() : new Center(child: new Text("An error occured. Please check your internet connection.")),
        navigatorObservers: [
          new FirebaseAnalyticsObserver(analytics: analytics),
        ],
      ),
    );
  } else {
    runApp(
      MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        debugShowCheckedModeBanner: false,
        home: internet ? TabNav() : new Center(child: new Text("An error occured. Please check your internet connection.")),
        navigatorObservers: [
          new FirebaseAnalyticsObserver(analytics: analytics),
        ],
      ),
    );
  }

  await analytics.logAppOpen();
  /* start count
  var _tempStarted = await retrieveData("started");
  var _tempLastStarted = await retrieveData("lastStarted");

  var date = new DateTime.now();
  saveData("lastStarted", date.toString());

  if (date.toString().substring(0, 8) == _tempLastStarted.toString().substring(0, 8) &&
      int.parse(date.toString().substring(8, 10)) == int.parse(_tempLastStarted.substring(8, 10)) + 1)
    saveData("started", ((_tempStarted != null ? int.parse(_tempStarted) : 0) + 1).toString());
  */

  /* lock orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);*/
}
