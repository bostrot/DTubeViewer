import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:simple_moment/simple_moment.dart';
import '../components/api.dart';
import '../components/videolist.dart';

class SearchScreen extends StatefulWidget {
  final String search;
  SearchScreen({
    this.search,
  });
  @override
  SearchScreenState createState() => new SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  var content;
  var result = "loading";
  var apiData3;

  _getVideos() async {
    apiData3 = await getDiscussions(3, widget.search, null);
    setState(() {
      apiData3 = apiData3;
    });
  }

  @override
  void initState() {
    _getVideos();
    super.initState();
  }

  //getVideo(permlink);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white,
        title: new Text(widget.search),
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
      body: new Center(child: apiData3 != null ? _buildSubtitles() : new CircularProgressIndicator()),
    );
  }

  Widget _buildSubtitles() {
    int jump = 0;
    return new RefreshIndicator(
        onRefresh: () {
          print("test");
        },
        child: new Center(
          child: GridView.builder(
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
                    var data = apiData3["results"][index];
                    var permlink = data["permlink"];
                    try {
                      String title = data['meta']['video']['info']['title'];
                      String description = data['meta']['video']['content']['description'];
                      return _buildRow(
                          data, index, title, description, permlink);
                    } catch (e) {
                      return new InkResponse(
                        child: new Column(
                          children: <Widget>[
                            _placeholderImage(null),
                            new Text("uploader messed up",
                                style: new TextStyle(fontSize: 14.0),
                                maxLines: 2),
                          ],
                        ),
                        onTap: () {
                          print('tabbed');
                        },
                      );
                    }
                  })
        ));
  }

  Widget _placeholderImage(var imgURL) {
    try {
      return Image.network("https://ipfs.io/ipfs/" + imgURL, fit: BoxFit.scaleDown,);
    } catch (e) {
      return Image.network(
          "https://ipfs.io/ipfs/Qma585tFzjmzKemYHmDZoKMZHo8Ar7YMoDAS66LzrM2Lm1", fit: BoxFit.scaleDown,);
    }
  }

  Widget _buildRow(
      var data, var index, var title, var description, var permlink) {
    var moment = new Moment.now();
    // handle metadata from (string)json_metadata
    var json_metadata = data['meta'];
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
                  data['payout'].toString() +
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
              builder: (context) => new VideoScreenSearch(
                  permlink: permlink,
                  data: data,
                  description: description,
                  json_metadata: json_metadata)),
        );
      },
    );
  }
}
