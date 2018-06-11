import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart';
import '../components/api.dart';
import 'package:flutter_billing/flutter_billing.dart';

class buildSettings extends StatefulWidget {
  @override
  createState() => new buildSettingsState();
}

class buildSettingsState extends State<buildSettings> {
  var user;
  var key;
  var _gateway;
  var currentGateway;

  _getCurrentGateway() async {
    var _temp = await retrieveData("gateway");
    setState(() {
      currentGateway = _temp;
    });
  }

  @override
  void initState() {
    _getCurrentGateway();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        new ListTile(
          leading: const Icon(FontAwesomeIcons.shoppingCart),
          title: const Text("Remove ads"),
          onTap: () async {
            final Billing billing = new Billing(onError: (e) {
              return Scaffold.of(context)
                ..showSnackBar(new SnackBar(
                  content: new Text(e.toString()),
                ));
            });
            final bool purchased = await billing.isPurchased('no_ads');
            if (purchased) {
              await saveData("no_ads", "true");
              return Scaffold.of(context)
                ..showSnackBar(new SnackBar(
                  content: new Text("Thanks for supporting me! Ads will not show up again."),
                ));
            } else {
              final bool purchased = await billing.purchase('no_ads');
              if (purchased) {
                await saveData("no_ads", "true");
                return Scaffold.of(context)
                  ..showSnackBar(new SnackBar(
                    content: new Text("Thanks for supporting me! Ads will not show up again."),
                  ));
              }
            }
          },
        ),
        new Divider(),
        new ListTile(
          title: const Text("Options"),
        ),
        new ListTile(
          leading: const Icon(FontAwesomeIcons.server),
          title: const Text("Gateway"),
          onTap: () {
            return showDialog<Null>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return new AlertDialog(
                  title: new Text('Enter your gateway'),
                  content: new SingleChildScrollView(
                    child: new ListBody(
                      children: <Widget>[
                        TextField(
                          decoration: new InputDecoration(hintText: currentGateway),
                          onChanged: (e) {
                            _gateway = e;
                          },
                        )
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text('CANCEL'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    new FlatButton(
                      child: new Text('OK'),
                      onPressed: () async {
                        await saveData("gateway", _gateway);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        new Divider(),
        new ListTile(
          leading: const Icon(FontAwesomeIcons.paintBrush),
          title: const Text("Theme"),
          onTap: () {
            final snackBar = new SnackBar(
              content: new Text('This feature is planned!'),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          },
        ),
        new Divider(),
        new ListTile(
          leading: const Icon(FontAwesomeIcons.upload),
          title: const Text("Upload"),
          onTap: () {
            launchURL("https://d.tube/#!/upload");
          },
        ),
        new Divider(),
        new ListTile(
          leading: const Icon(FontAwesomeIcons.signOutAlt),
          title: const Text("Logout"),
          onTap: () {
            saveData(null, null);
            final snackBar = new SnackBar(
              content: new Text('All user data has been cleared. You may need to restart the app.'),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          },
        ),
        new Divider(),
        new ListTile(
          title: const Text("Ressources"),
        ),
        new Divider(),
        new ListTile(
          leading: const Icon(FontAwesomeIcons.infoCircle),
          title: const Text("About"),
          onTap: () {
            return showDialog<Null>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return new AlertDialog(
                  title: new Text('Content streaming app v0.1.0'),
                  content: new SingleChildScrollView(
                    child: new ListBody(
                      children: <Widget>[
                        new Text('This application is a web video player which ' +
                            'can be connected and used with various open source video ' +
                            'projects. It is open source and available on. Feel free to ' +
                            'contribute.'),
                        new Text('The distributor and developer of this app are in no way affiliated ' +
                            'with the video project\'s company or developer.'),
                        new FlatButton(
                          onPressed: () {
                            launchURL("https://bostrot.pro/");
                          },
                          child: new Text('\nMade with ♥ by Bostrot'),
                        ),
                        new Text(
                          "and following open source libraries:",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 8.0),
                        ),
                        new FlatButton(
                          onPressed: () {
                            launchURL("https://github.com/flutter/flutter");
                          },
                          child: new Text('\nflutter'),
                        ),
                        new FlatButton(
                          onPressed: () {
                            launchURL("https://fontawesome.com/");
                          },
                          child: new Text('\nfont_awesome_flutter'),
                        ),
                        new FlatButton(
                          onPressed: () {
                            launchURL("https://github.com/flutterchina/dio");
                          },
                          child: new Text('\ndio'),
                        ),
                        new FlatButton(
                          onPressed: () {
                            launchURL("https://github.com/rinukkusu/simple_moment");
                          },
                          child: new Text('\nsimple_moment'),
                        ),
                        new FlatButton(
                          onPressed: () {
                            launchURL("https://github.com/flutter/plugins/tree/master/packages/video_player");
                          },
                          child: new Text('\nvideo_player'),
                        ),
                        new FlatButton(
                          onPressed: () {
                            launchURL("https://github.com/brianegan/chewie");
                          },
                          child: new Text('\nchewie'),
                        ),
                        new FlatButton(
                          onPressed: () {
                            launchURL("https://github.com/flutter/plugins/tree/master/packages/url_launcher");
                          },
                          child: new Text('\nurl_launcher'),
                        ),
                        new FlatButton(
                          onPressed: () {
                            launchURL("https://github.com/flutter/plugins/tree/master/packages/shared_preferences");
                          },
                          child: new Text('\nshared_preferences'),
                        ),
                        new FlatButton(
                          onPressed: () {
                            launchURL("https://pub.dartlang.org/packages/screen");
                          },
                          child: new Text('\nscreen'),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        new Divider(),
        new ListTile(
          leading: const Icon(FontAwesomeIcons.comment),
          title: const Text("Feedback"),
          onTap: () {
            final snackBar = new SnackBar(
              content: new Text('This feature is planned!'),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          },
        ),
        new Divider(),
        new ListTile(
          leading: const Icon(FontAwesomeIcons.userSecret),
          title: const Text("Privacy Policy"),
          onTap: () {
            launchURL("https://www.iubenda.com/privacy-policy/8143066");
          },
        ),
        new Divider(),
        new ListTile(
          title: const Text("My Links"),
        ),
        new Divider(),
        new ListTile(
          leading: const Icon(FontAwesomeIcons.rss),
          title: const Text("My Blog"),
          onTap: () {
            launchURL("https://bostrot.pro/");
          },
        ),
        new Divider(),
        new ListTile(
          leading: const Icon(FontAwesomeIcons.twitter),
          title: const Text("My Twitter"),
          onTap: () {
            launchURL("https://twitter.com/Bostrot_");
          },
        ),
        new Divider(),
        new ListTile(
          leading: const Icon(FontAwesomeIcons.newspaper),
          title: const Text("My Newsletter"),
          onTap: () {
            launchURL("http://eepurl.com/do_FIr");
          },
        ),
      ],
    );
  }
}
