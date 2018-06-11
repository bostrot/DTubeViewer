import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
      response = await dio.get("https://api.asksteem.com/search?q=meta.video.info.title%3A*%20AND%20" + search + "&include=meta%2Cpayout");
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

broadcastVote(String author, String permlink, int weight) async {
  var _tempAuthData = { "user": await retrieveData("user"), "key": await retrieveData("key") };
  Dio dio = new Dio();
  dio.options.headers = {'Content-Type': 'application/json', 'authorization': await _tempAuthData["key"]};
  Response response = await dio.post("https://v2.steemconnect.com/api/broadcast", data: {
    "operations": [
      [
        "vote",
        {"voter": await _tempAuthData["user"], "author": author, "permlink": permlink, "weight": weight}
      ]
    ]
  });
  return (response.data);
}

broadcastComment(String author, String permlink, String text) async {
  var _tempAuthData = { "user": await retrieveData("user"), "key": await retrieveData("key") };
  var rng = new Random().nextInt(25);
  String randStr = rng.toString();
  Dio dio = new Dio();
  dio.options.headers = {'Content-Type': 'application/json', 'authorization': await _tempAuthData["key"]};
  Response response = await dio.post("https://v2.steemconnect.com/api/broadcast", data: {
    "operations": [
      [
        "comment",
        {
          "parent_author": author,
          "parent_permlink": permlink,
          "author": _tempAuthData["user"],
          "permlink": randStr,
          "title": randStr,
          "body": text,
          "json_metadata": "{\"app\":\"dtube/0.7\"}"
        }
      ]
    ]
  });
  return (response.data);
}

broadcastSubscribe(context, String author) async {
  var _tempAuthData = { "user": await retrieveData("user"), "key": await retrieveData("key") };
  Dio dio = new Dio();
  dio.options.headers = {'Content-Type': 'application/json', 'authorization': await _tempAuthData["key"]};
  Response response = await dio.post("https://v2.steemconnect.com/api/broadcast", data: {
    "operations": [
      [
        "custom_json",
        {
          "required_auths": [],
          "required_posting_auths": [_tempAuthData["user"]],
          "id": "follow",
          "json": "[\"follow\",{\"follower\":\"" + _tempAuthData["user"] + "\",\"following\":\"" + author + "\",\"what\":[\"blog\"]}]"
        }
      ]
    ]
  });
  print(response.data);
  toast(context, "Subscribed");
  return (response.data);
}

launchURL(var url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void saveData(var key, var data) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, data);
}

retrieveData(var key) async {
  final prefs = await SharedPreferences.getInstance();
  return (prefs.getString(key));
}

String linkify(String text) {
  text = text.replaceAll("\\n", "\n");
  var urlPattern = r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
  var result = new RegExp(urlPattern, caseSensitive: false).allMatches(text);

  for (Match m in result) {
    String match = m.group(0);
    text = text.replaceFirst(match, "<a href=\"" + match + "\">" + match + "</a>");
  }
  return text;
}

toast(context, text) {
  return Scaffold.of(context)
    ..showSnackBar(new SnackBar(
      content: new Text(text),
    ));
}