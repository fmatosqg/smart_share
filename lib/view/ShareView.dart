import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class SampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample Shared App Handler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SampleAppPage(),
    );
  }
}

class SampleAppPage extends StatefulWidget {
  SampleAppPage({Key key}) : super(key: key);

  @override
  _SampleAppPageState createState() => _SampleAppPageState();
}

class _SampleAppPageState extends State<SampleAppPage> {
  static const platform = const MethodChannel('app.channel.shared.data');
  String dataShared = "No data";
  String dataSharedCleaned = "No data";

  @override
  void initState() {
    super.initState();
    getSharedText();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: <Widget>[
//              Text(dataShared),
              ShareableWidget(originalText: dataShared, title: "Original text"),
              ShareableWidget(
                  originalText: dataSharedCleaned, title: "Url only"),
            ],
          ),
//          ),
        ),
      )),
    );
  }

  getSharedText() async {
    var sharedData = await platform.invokeMethod("getSharedText");
    if (sharedData != null) {
      setState(() {
        dataShared = sharedData;
        dataSharedCleaned = cleanData(dataShared);
      });
    }
  }

  String cleanData(String dataShared) {
    var index = dataShared.indexOf("https://");
    if (index == -1) {
      index = dataShared.indexOf("http://");
    }

    if (index == -1) {
      return dataShared;
    } else {
      return dataShared.substring(index);
    }
  }
}

class ShareableWidget extends StatelessWidget {
  final String originalText;
  final String title;

  TextEditingController _controller;

  ShareableWidget({Key key, @required this.originalText, this.title})
      : super(key: key) {
    _controller = TextEditingController(
      text: originalText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
//      elevation: 4,
//      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        side: BorderSide(
          width: 4,
          color: Colors.green[100],
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(8),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            TextField(
              maxLengthEnforced: false,
              controller: _controller,
              maxLines: null,
              decoration: InputDecoration(
                labelText: title,
                isDense: true,
                filled: true,
                fillColor: Colors.green[50],
              ),
            ),
            Row(
              children: <Widget>[
                MaterialButton(
                  child: Text("Share"),
                  color: Colors.green,
                  onPressed: () => Share.share(_controller.text),
                ),
                Spacer(),
                MaterialButton(
                  child: Text("Browser"),
                  color: Colors.green,
                  onPressed: () async {
                    final url = _controller.text;

                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
