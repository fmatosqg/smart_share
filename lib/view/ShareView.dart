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
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ListView(
            children: <Widget>[
              Text(dataShared + "aaa"),
              ShareableWidget(originalText: dataShared),
              ShareableWidget(originalText: dataSharedCleaned),
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
    final index = dataShared.indexOf("https://");

    return dataShared.substring(index);
  }
}

class ShareableWidget extends StatelessWidget {
  final String originalText;

  TextEditingController _controller;

  ShareableWidget({Key key, @required this.originalText}) : super(key: key) {
    _controller = TextEditingController(
      text: originalText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[100],
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: EdgeInsets.all(8),
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: TextFormField(
                maxLines: 5,
                controller: _controller,
//                decoration: InputDecoration(helperText: "Hello"),
              ),
            ),
            Column(
              children: <Widget>[
                MaterialButton(
                  child: Text("Share"),
                  color: Colors.green,
                  onPressed: () => Share.share(_controller.text),
                ),
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
