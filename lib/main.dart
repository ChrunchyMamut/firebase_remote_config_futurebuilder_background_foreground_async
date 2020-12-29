import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // get remote config
  final remoteConfig = await RemoteConfig.instance;

  // setup default values
  final defaults = <String, dynamic>{'welcome': 'Hello World!'};
  await remoteConfig.setDefaults(defaults);

  // get last config data
  final text = remoteConfig.getString('welcome');

  // run app and use config data
  runApp(MyApp(text));
}

Future<String> _getWelcomeText() async {
  // get remote config
  final remoteConfig = await RemoteConfig.instance;

  // fetch and activate config data, data will be used in next restart
  await remoteConfig.fetch(expiration: Duration(seconds: 1));
  await remoteConfig.activateFetched();

  final welcomeText = remoteConfig.getString('welcome');
  print('Welcome text is $welcomeText');
  print('FUNCTION Async');
  return welcomeText;
}

class MyApp extends StatefulWidget {
 // const MyApp({ Key key }) : super(key: key);
  final String text;

  MyApp(this.text);

  @override
  State<StatefulWidget> createState() {
    return MyApp1(text);
  }
}

class MyApp1 extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getWelcomeText().then((value){print('INIT Async');
  });
  super.initState();
  }

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);
  if (state == AppLifecycleState.paused) {
    // went to Background
  }
  if (state == AppLifecycleState.resumed) {
    _getWelcomeText();
  }
}
  

  final _title = 'Firebase Config Demo';
  final String text;
  MyApp1(this.text);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _title,
        theme: ThemeData(
          primaryColor: Colors.red,
        ),
        home: FutureBuilder(
          future: _getWelcomeText(),
          builder: (context, snapshot) {
            var bottomText = "Config not loaded yet";
            if (snapshot.hasError)
              bottomText = "Config loading error";
            else if (snapshot.hasData) bottomText = "Config loaded";

            return Scaffold(
              appBar: AppBar(
                title: Text(_title),
              ),
              body: Center(
                child: Text(snapshot.data == null ? this.text : snapshot.data),
              ),
              bottomNavigationBar: Text(bottomText),
            );
          },
        ));
  }
}
