import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:http/http.dart' as http;
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

List<SharedMediaFile>? _sharedFiles;

getShared() {
  return _sharedFiles;
}

class _NavBarState extends State<NavBar> {
  late StreamSubscription _intentDataStreamSubscription;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    void printWarning(String text) {
      print('\x1B[33m$text\x1B[0m');
    }

    AppUpdateInfo? _updateInfo;
    // ignore: unused_local_variable
    bool _flexibleUpdateAvailable = false;
    if (kReleaseMode) {
      Future<void> checkForUpdate() async {
        InAppUpdate.checkForUpdate().then((info) {
          setState(() {
            _updateInfo = info;
          });
        }).catchError((e) {});
      }

      checkForUpdate();

      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        InAppUpdate.startFlexibleUpdate().then((_) {
          setState(() {
            _flexibleUpdateAvailable = true;
          });
        }).catchError((e) {
          print(e);
        });
      }
    }

    StreamSubscription<FGBGType> subscription;
    subscription = FGBGEvents.stream.listen((event) async {
      final prefs = await SharedPreferences.getInstance();

      if (event == FGBGType.foreground && prefs.getBool('refresh') == true) {
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
      printWarning('DETECTED SCREENSHOT');
      final prefs = await SharedPreferences.getInstance();
      final screenshots = prefs.getBool('screenshots');
      if (screenshots == false) return;
      printWarning('DETECTED SCREENSHOT');
      Fluttertoast.showToast(
          msg: 'Detected screenshot!',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);

      final screendir = prefs.getString('screendir')!;
      final dir = Directory(screendir);
      final files = dir.listSync();
      if (files.isEmpty == true) return;
      List dates = [];
      List screenshotfiles = [];

      files.forEach((f) {
        final file = File(f.path);
        dates.add(file.lastModifiedSync());
        screenshotfiles.add(file);
      });

      dates.sort((a, b) => b.compareTo(a));
      printWarning(dates[0].toString());

      final newestdate = dates[0].toString();
      final uploadfile = screenshotfiles
          .where((x) => x.lastModifiedSync().toString() == newestdate)
          .first;
      print(uploadfile is File);

      Fluttertoast.showToast(
          msg: 'Uploading screenshot...',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);

      final upload = await uploadFile(uploadfile);
      await postUpload(upload);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('ImageLink™'),
        leading: new Image.asset("assets/icon/icon.png"),
      ),
      body: IndexedStack(
        children: <Widget>[Home(), Settings(), History(), Info()],
        index: _currentIndex,
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Info')
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 2) {
        History();
      }
    });
  }
}

Future uploadFile(File file) async {
  final prefs = await SharedPreferences.getInstance();
  final requrl = prefs.getString('requrl')!;
  final args = prefs.getString('args')!;
  final type = prefs.getInt('argtype');
  final filename = prefs.getString('fileform')!;

  final fields = jsonDecode(args);
  final req = http.MultipartRequest('POST', Uri.parse(requrl));

  req.files.add(await http.MultipartFile.fromPath(filename, file.path));

  if (type == 0) {
    fields.forEach((k, v) {
      req.fields[k] = v;
    });
  } else {
    final headers = new Map<String, String>.from(fields);
    req.headers.addAll(headers);
  }

  final response = await req.send();
  print(response.statusCode);

  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseString = await response.stream.bytesToString();
    final body = jsonDecode(responseString);
    prefs.setBool('refresh', true);
    return body;
  } else {
    return response.statusCode;
  }
}

Future postUpload(dynamic upload) async {
  if (upload is int) {
    Fluttertoast.showToast(
        msg: 'Failed to upload file! HTTP Code $upload',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 2,
        fontSize: 16.0);
    return;
  } else {
    print(upload);
    final prefs = await SharedPreferences.getInstance();
    final resprop = prefs.getString('resprop')!;
    final regexp = RegExp(r'\$json:([a-zA-Z]+)\$');
    final match = regexp.firstMatch(resprop)!;
    final matched = match.group(1);
    final rawurl = upload[matched] as String?;

    if (rawurl == null) {
      Fluttertoast.showToast(
          msg: 'Uploaded, but failed to parse response URL!',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
      return;
    }

    final url = rawurl.replaceAll(RegExp(r'/^http:\/\//i'), 'https://');

    Clipboard.setData(ClipboardData(text: url));

    Fluttertoast.showToast(
        msg: 'File sucessfully uploaded!',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 2,
        fontSize: 16.0);

    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
