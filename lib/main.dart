import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'components/api.dart';
import 'screens/settings.dart';
import 'screens/search.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'screens/downloads.dart';
import 'screens/news.dart';
import 'screens/home.dart';

import 'screens/login.dart';

var videoData;

// analytics
FirebaseAnalytics analytics = new FirebaseAnalytics();
var pubIndex = 0;

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 5,
        child: new Scaffold(
          backgroundColor: theme(selectedTheme)["background"],
          body: new Stack(
            children: <Widget>[
              new Offstage(
                offstage: pubIndex != 0,
                child: new TickerMode(
                  enabled: pubIndex == 0,
                  child: new HomeScreen(),
                ),
              ),
              new Offstage(
                offstage: pubIndex != 1,
                child: new TickerMode(
                  enabled: pubIndex == 1,
                  child: new SearchScreen(),
                ),
              ),
              new Offstage(
                offstage: pubIndex != 2,
                child: new TickerMode(
                  enabled: pubIndex == 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: NewsScreen(),
                  ),
                ),
              ),
              new Offstage(
                offstage: pubIndex != 3,
                child: new TickerMode(
                  enabled: pubIndex == 3,
                  child: DownloadsScreen(),
                ),
              ),
              new Offstage(
                offstage: pubIndex != 4,
                child: new TickerMode(
                  enabled: pubIndex == 4,
                  child: new BuildSettings(),
                ),
              ),
            ],
          ),
          bottomNavigationBar: new BottomNavigationBar(
            currentIndex: pubIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              setState(() {
                pubIndex = index;
              });
            },
            fixedColor: theme(selectedTheme)["primary"],
            items: <BottomNavigationBarItem>[
              new BottomNavigationBarItem(
                icon: new Icon(
                  FontAwesomeIcons.fire,
                ),
                title: Text("Home"),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(
                  FontAwesomeIcons.search,
                ),
                title: Text(
                  "Search",
                ),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(
                  FontAwesomeIcons.hourglass,
                ),
                title: Text(
                  "New",
                ),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(
                  FontAwesomeIcons.download,
                ),
                title: Text(
                  "Downloads",
                ),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(
                  FontAwesomeIcons.bars,
                ),
                title: Text(
                  "More",
                ),
              ),
            ],
          ),
        ));
  }
}

/*
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
theme(selectedTheme)["background"],
          bottomNavigationBar: BottomNavigationBar(fixedColor: theme(selectedTheme)["background"], items: [
            new BottomNavigationBarItem(
                title: new Text(
                  "Home",
                  style: TextStyle(color: theme(selectedTheme)["text"]),
                ),
                icon: new Icon(FontAwesomeIcons.home, color: theme(selectedTheme)["text"])),
            new BottomNavigationBarItem(
                title: new Text(
                  "Home",
                  style: TextStyle(color: theme(selectedTheme)["text"]),
                ),
                icon: new Icon(FontAwesomeIcons.search, color: theme(selectedTheme)["text"])),
            new BottomNavigationBarItem(
                title: new Text(
                  "Home",
                  style: TextStyle(color: theme(selectedTheme)["text"]),
                ),
                icon: new Icon(FontAwesomeIcons.hourglass, color: theme(selectedTheme)["text"])),
            new BottomNavigationBarItem(
                title: new Text(
                  "Home",
                  style: TextStyle(color: theme(selectedTheme)["text"]),
                ),
                icon: new Icon(FontAwesomeIcons.download, color: theme(selectedTheme)["text"])),
            new BottomNavigationBarItem(
                title: new Text(
                  "Home",
                  style: TextStyle(color: theme(selectedTheme)["text"]),
                ),
                icon: new Icon(FontAwesomeIcons.bars, color: theme(selectedTheme)["text"])),
          ]),
new AppBar(
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

new TextField(
              decoration: new InputDecoration(border: InputBorder.none, hintText: 'Search...'),
              onSubmitted: (search) {
                Navigator.push(context, new MaterialPageRoute(builder: (context) => new SearchScreen(search: search)));
              },
            ),
 */

void main() async {
  var _temp = {"user": await retrieveData("user")};
  user = _temp["user"];

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

  if (_tempBuildNumber == null || int.parse(_tempBuildNumber) < buildNumber && user == null) {
    saveData("gateway", "https://video.dtube.top/ipfs/");
    saveData("buildNumber", buildNumber.toString());
    runApp(
      MaterialApp(
        theme: ThemeData(primaryColor: theme(selectedTheme)["background"], textSelectionColor: theme(selectedTheme)["accent"]),
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
        theme: ThemeData(primaryColor: theme(selectedTheme)["background"], textSelectionColor: theme(selectedTheme)["accent"]),
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
