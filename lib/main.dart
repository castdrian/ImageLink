import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'home.dart';
import 'settings.dart';
import 'history.dart';
import 'info.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'ImageLink',
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          scaffoldBackgroundColor: Colors.black,
          bottomNavigationBarTheme:
              BottomNavigationBarThemeData(backgroundColor: Colors.black)),
      home: NavBar(),
    );
  }
}

class NavBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NavBarState();
  }
}

List<SharedMediaFile> _sharedFiles;

getShared() {
  return _sharedFiles;
}

class _NavBarState extends State<NavBar> {
  StreamSubscription _intentDataStreamSubscription;

  int _currentIndex = 0;
  final List<Widget> _children = [Home(), Settings(), History(), Info()];

  @override
  void initState() {
    super.initState();

    void printWarning(String text) {
      print('\x1B[33m$text\x1B[0m');
    }

    StreamSubscription<FGBGType> subscription;
    subscription = FGBGEvents.stream.listen((event) {
      if (event == FGBGType.foreground) {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NavBar()),
      ).then((value) => setState(() {}));
      }
      print(event); // FGBGType.foreground or FGBGType.background
    });

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NavBar()),
      ).then((value) => setState(() {}));
    }, onError: (err) {});

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    });

    @override
    // ignore: unused_element
    void dispose() {
      _intentDataStreamSubscription.cancel();
      subscription.cancel();
      super.dispose();
    }

    ScreenshotCallback screenshotCallback = ScreenshotCallback();
    screenshotCallback.addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      final screenshots = prefs.getBool('screenshots');
      if (screenshots == false) return;
      printWarning('DETECTED SCREENSHOT');
      Fluttertoast.showToast(
          msg: 'Detected screenshot!',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('ImageLink™'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline), 
            label: 'Info')
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
