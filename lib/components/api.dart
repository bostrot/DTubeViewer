import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttersteem/fluttersteem.dart';

getDiscussions(var tab, String search, var user) async {
  Dio dio = new Dio();
  Response response;
  switch (tab) {
    case 0:
      response = await dio.post("https://api.steemit.com", data: {
        "id": "0",
        "jsonrpc": "2.0",
        "method": "call",
        "params": [
          "database_api",
          "get_discussions_by_hot",
          [
            {"tag": "dtube", "limit": 30, "truncate_body": 1}
          ]
        ]
      });
      break;
    case 1:
      response = await dio.post("https://api.steemit.com", data: {
        "id": "1",
        "jsonrpc": "2.0",
        "method": "call",
        "params": [
          "database_api",
          "get_discussions_by_trending",
          [
            {"tag": "dtube", "limit": 30, "truncate_body": 1}
          ]
        ]
      });
      break;
    case 2:
      response = await dio.post("https://api.steemit.com", data: {
        "id": "2",
        "jsonrpc": "2.0",
        "method": "call",
        "params": [
          "database_api",
          "get_discussions_by_created",
          [
            {"tag": "dtube", "limit": 30, "truncate_body": 1}
          ]
        ]
      });
      break;
    case 3:
      response = await dio.get(
          "https://api.asksteem.com/search?q=meta.video.info.title%3A*%20AND%20" +
              search +
              "&include=meta%2Cpayout");
      break;
    case 4:
      response = await dio.post("https://api.steemit.com", data: {
        "id": "4",
        "jsonrpc": "2.0",
        "method": "call",
        "params": [
          "database_api",
          "get_discussions_by_feed",
          [
            {"tag": user, "limit": 30, "truncate_body": 1}
          ]
        ]
      });
      break;
    default:
      break;
  }
  return (response.data);
}

int toInt(double doub) {
  double multiplier = 100.0;
  return (multiplier * doub).round();
}

broadcast(String author, String permlink, int weight) async {
  var _tempAuthData = await retrieveData();
  print(_tempAuthData["key"]);
  Dio dio = new Dio();
  dio.options.headers = {
    'Content-Type': 'application/json',
    'authorization': await _tempAuthData["key"]
  };
  Response response =
      await dio.post("https://v2.steemconnect.com/api/broadcast", data: {
    "operations": [
      [
        "vote",
        {
          "voter": await _tempAuthData["user"],
          "author": author,
          "permlink": permlink,
          "weight": weight
        }
      ]
    ]
  });
  print(response.data);
  return (response.data);
}

launchURL(var url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void saveData(var user, var key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('user', user);
  prefs.setString('key', key);
}

retrieveData() async {
  final prefs = await SharedPreferences.getInstance();
  return ({"user": prefs.getString('user'), "key": prefs.getString('key')});
}

String linkify(String text) {
  text = text.replaceAll("\\n", "\n");
  var urlPattern =
      r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
  var result = new RegExp(urlPattern, caseSensitive: false).allMatches(text);

  for (Match m in result) {
    String match = m.group(0);
    text =
        text.replaceFirst(match, "<a href=\"" + match + "\">" + match + "</a>");
  }
  return text;
}
