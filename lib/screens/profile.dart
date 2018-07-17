import 'package:flutter/material.dart';
import '../components/api.dart';
import '../components/videolist.dart';

class ProfileScreen extends StatefulWidget {
  final String profile;
  ProfileScreen({
    this.profile,
  });
  @override
  ProfileScreenState createState() => new ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: theme(selectedTheme)["background"],
        title: new Text(widget.profile),
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
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: buildSubtitles(steemit.getDiscussionsByBlog(widget.profile), context),
    );
  }
}
