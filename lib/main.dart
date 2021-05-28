import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'home.dart';
import 'settings.dart';
import 'history.dart';
import 'info.dart';
import 'util.dart';
import 'ad_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await GetStorage.init();
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

final appData = AppData();

class AppData {
  static final AppData _appData = new AppData._internal();

  bool isPlatinum = false;

  factory AppData() {
    return _appData;
  }
  AppData._internal();
}

class NavBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NavBarState();
  }
}

List<SharedMediaFile>? _sharedFiles;
PageController pageController = PageController();
String? ver;
String? bnum;

getShared() {
  return _sharedFiles;
}

late BannerAd homeAd;
late BannerAd tabOneAd;
late BannerAd tabTwoAd;
late BannerAd historyAd;
late BannerAd infoAd;

class _NavBarState extends State<NavBar> {
  late StreamSubscription _intentDataStreamSubscription;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    initPlatformState();

    homeAd = BannerAd(
      adUnitId: AdHelper.homeBanner,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('Ad loaded!');
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    );

    tabOneAd = BannerAd(
      adUnitId: AdHelper.homeBanner,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('Ad loaded!');
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    );

    tabTwoAd = BannerAd(
      adUnitId: AdHelper.homeBanner,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('Ad loaded!');
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    );

    historyAd = BannerAd(
      adUnitId: AdHelper.homeBanner,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('Ad loaded!');
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    );

    infoAd = BannerAd(
      adUnitId: AdHelper.homeBanner,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('Ad loaded!');
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    );

    homeAd.load();
    tabOneAd.load();
    tabTwoAd.load();
    historyAd.load();
    infoAd.load();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      ver = packageInfo.version;
      bnum = packageInfo.buildNumber;
    });

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
      if (event == FGBGType.foreground && GetStorage().read('refresh') == 1) {
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
      final screenshots = GetStorage().read('screenshots');
      if (screenshots == 0) return;
      printWarning('DETECTED SCREENSHOT');
      Fluttertoast.showToast(msg: 'Detected screenshot!');

      final screendir = GetStorage().read('screendir');
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

      Fluttertoast.showToast(msg: 'Uploading screenshot...');

      final upload = await uploadFile(uploadfile);
      await postUpload(upload);
    });
  }

  Future<void> initPlatformState() async {
    appData.isPlatinum = false;

    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup('QHSsSMTkDVwplonOqaZNmynGdtDwtqDf');

    PurchaserInfo purchaserInfo;
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      print(purchaserInfo.toString());
      if (purchaserInfo.entitlements.all['Platinum'] != null) {
        appData.isPlatinum = purchaserInfo.entitlements.all['Platinum']!.isActive;
      } else {
        appData.isPlatinum = false;
      }
    } on PlatformException catch (e) {
      print(e);
    }

    print('#### is user platinum? ${appData.isPlatinum}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ImageLink™'),
              Text('v$ver ($bnum)', style: TextStyle(fontSize: 12))
            ]),
        leading: Image.asset('assets/icon/icon.png'),
      ),
      body: PageView(
        children: <Widget>[
          KeepAlivePage(child: Home()),
          KeepAlivePage(child: Settings()),
          KeepAlivePage(child: History()),
          KeepAlivePage(child: Info()),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: navigateToPage, // new
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

  void navigateToPage(int page) {
    pageController.animateToPage(page,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 2) {
        History();
      }
    });
  }
}

class KeepAlivePage extends StatefulWidget {
  KeepAlivePage({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    /// Dont't forget this
    super.build(context);

    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
