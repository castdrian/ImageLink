import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imagelink/util.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'ad_helper.dart';
import 'main.dart' as main;

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings>
    with AutomaticKeepAliveClientMixin<Settings> {
  @override
  bool get wantKeepAlive => true;

  final sxc = TextEditingController();
  final sdc = TextEditingController();
  final rqc = TextEditingController();
  final rsc = TextEditingController();
  final agc = TextEditingController();
  final fnc = TextEditingController();
  final txc = TextEditingController();
  List<TextEditingController> keycontrollers = [];
  List<TextEditingController> valuecontrollers = [];
  int? idx = 0;
  bool status = false;
  bool autoexit = false;
  bool body = false;
  String? dir;
  String dropdownValue = 'Custom (SXCU)';
  InterstitialAd? _interstitialAd;
  InterstitialAd? _sinterstitialAd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) async => await loadAsync(context));
    
        InterstitialAd.load(
        adUnitId: AdHelper.importInters,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Keep a reference to the ad so you can show it later.
            this._interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
      ));

      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('%ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
        },
        onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
      );

      InterstitialAd.load(
      adUnitId: AdHelper.saveInters,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          // Keep a reference to the ad so you can show it later.
          this._sinterstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
    ));

    _sinterstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
        print('%ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
      onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
    );
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TabBar(tabs: [
                  Tab(icon: Icon(Icons.upload_file)),
                  Tab(icon: Image.asset('assets/icon/icon.png', scale: 20)),
                ]),
              ],
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Column(children: <Widget>[
                SizedBox(height: 5),
                TextField(
                  controller: rqc,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Request URL (example.com/upload):',
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: rsc,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Response property (\$json:parameter\$):',
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: fnc,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'FileFormName:',
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text('Request body:',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center)),
                    Expanded(
                        child: FlutterSwitch(
                            width: 70.0,
                            height: 30.0,
                            valueFontSize: 20.0,
                            toggleSize: 30.0,
                            value: body,
                            borderRadius: 30.0,
                            padding: 4.0,
                            showOnOff: false,
                            onToggle: (val) {
                              setState(() {
                                body = val;
                                GetStorage().write('body', val == true ? 1 : 0);
                              });
                            })),
                  ],
                ),
                SizedBox(height: 5),
                GetStorage().read('body') == 1
                    ? TextField(
                        controller: agc,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                            labelText: 'JSON (multipart/form-data):'),
                        maxLines: 3,
                      )
                    : Container(),
                SizedBox(height: 5),
                GetStorage().read('body') == 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: TextField(
                            controller: txc,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Type:',
                              isDense: true,
                              contentPadding: EdgeInsets.all(8),
                            ),
                            readOnly: true,
                          )),
                          Expanded(
                              child: FlutterSwitch(
                                  width: 70.0,
                                  height: 30.0,
                                  valueFontSize: 20.0,
                                  toggleSize: 30.0,
                                  value: idx == 1 ? true : false,
                                  borderRadius: 30.0,
                                  padding: 4.0,
                                  showOnOff: false,
                                  onToggle: (val) async {
                                    setState(() {
                                      idx = val == true ? 1 : 0;
                                      txc.text =
                                          val == true ? 'Headers' : 'Arguments';
                                    });
                                  })),
                        ],
                      )
                    : Container(),
                SizedBox(height: 5),
                TextField(
                  controller: sxc,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Selected SXCU:',
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 5),
                main.appData.isPlatinum
                    ? Container()
                    : Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: main.tabOneAd.size.width.toDouble(),
                          height: main.tabOneAd.size.height.toDouble(),
                          child: AdWidget(ad: main.tabOneAd),
                        ),
                      ),
              ]),
              Column(children: <Widget>[
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text('Intercept screenshots:',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center)),
                    Expanded(
                        child: FlutterSwitch(
                            width: 70.0,
                            height: 30.0,
                            valueFontSize: 20.0,
                            toggleSize: 30.0,
                            value: status,
                            borderRadius: 30.0,
                            padding: 4.0,
                            showOnOff: false,
                            onToggle: (val) async {
                              setState(() {
                                status = val;
                                GetStorage().write(
                                    'screenshots', status == true ? 1 : 0);
                                GetStorage().write('refresh', 0);
                              });

                              if (status == true) {
                                final requrl = GetStorage().read('requrl');

                                if (requrl == null) {
                                  Fluttertoast.showToast(
                                      msg: 'Nothing to load!');
                                  return;
                                }

                                final path = await FilePicker.platform
                                    .getDirectoryPath();

                                if (path == null) {
                                  GetStorage().write('screenshots', 0);
                                  setState(() {
                                    status = false;
                                  });
                                  return;
                                } else if (path == '/') {
                                  GetStorage().write('screenshots', 0);
                                  setState(() {
                                    status = false;
                                  });

                                  Widget okButton = TextButton(
                                    child: Text('My mistake.'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  );

                                  AlertDialog alert = AlertDialog(
                                    title: Text('Protected directoy:'),
                                    content: Text(
                                        'You chose a directory that is protected by Android.\nImageLink cannot read protected directories.'),
                                    actions: [
                                      okButton,
                                    ],
                                  );

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    },
                                  );
                                  return;
                                }
                                dir = path;

                                setState(() {
                                  sdc.text = dir!;
                                  GetStorage().write('screendir', dir!);
                                });

                                startForegroundService();
                                Fluttertoast.showToast(
                                    msg: 'Enabled screenshot intercepting!');
                              } else {
                                setState(() {
                                  sdc.text = '';
                                  GetStorage().write('screendir', '');
                                });
                                await FlutterForegroundPlugin
                                    .stopForegroundService();
                                Fluttertoast.showToast(
                                    msg: 'Disabled screenshot intercepting!');
                              }
                            })),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  controller: sdc,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Screenshot directory:',
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text('Upload destination:',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center)),
                    Expanded(
                        child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                          value: dropdownValue,
                          iconSize: 24,
                          elevation: 16,
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 15),
                          underline: Container(
                            height: 2,
                            color: Colors.blue,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              if (main.appData.isPlatinum) {
                                if (newValue == 'Custom (SXCU)') {
                                  dropdownValue = newValue!;
                                  GetStorage().write('destination', 0);
                                } else if (newValue == 'Imgur')
                                  dropdownValue = newValue!;
                                GetStorage().write('destination', 1);
                              } else {
                                platinumDialog(context);
                              }
                            });
                          },
                          items: <String>[
                            'Custom (SXCU)',
                            'Imgur',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()),
                    )))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text('Post-upload auto-exit:',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center)),
                    Expanded(
                        child: FlutterSwitch(
                            width: 70.0,
                            height: 30.0,
                            valueFontSize: 20.0,
                            toggleSize: 30.0,
                            value: autoexit,
                            borderRadius: 30.0,
                            padding: 4.0,
                            showOnOff: false,
                            onToggle: (val) async {
                              setState(() {
                                autoexit = val;
                                GetStorage()
                                    .write('autoexit', val == true ? 1 : 0);
                              });
                            })),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton.extended(
                      onPressed: () => main.appData.isPlatinum
                          ? Fluttertoast.showToast(msg: 'Coming soon!')
                          : platinumDialog(context),
                      label: const Text('Drive import'),
                      icon: const Icon(Icons.add_to_drive),
                      backgroundColor: Colors.blue,
                    ),
                    FloatingActionButton.extended(
                      onPressed: () => main.appData.isPlatinum
                          ? Fluttertoast.showToast(msg: 'Coming soon!')
                          : platinumDialog(context),
                      label: const Text('Drive export'),
                      icon: const Icon(FontAwesomeIcons.googleDrive),
                      backgroundColor: Colors.blue,
                    ),
                  ],
                ),
                SizedBox(height: 5),
                main.appData.isPlatinum
                    ? Container()
                    : Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: main.tabTwoAd.size.width.toDouble(),
                          height: main.tabTwoAd.size.height.toDouble(),
                          child: AdWidget(ad: main.tabTwoAd),
                        ),
                      ),
              ])
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton.extended(
                onPressed: () => importSXCU(context),
                label: const Text('Import SXCU'),
                icon: const Icon(Icons.upload_file),
                backgroundColor: Colors.blue,
              ),
              FloatingActionButton.extended(
                onPressed: () => saveSettings(context),
                label: const Text('Save settings'),
                icon: const Icon(Icons.save),
                backgroundColor: Colors.blue,
              ),
            ],
          )),
    );
  }

  Future loadAsync(BuildContext context) async {
    final requrl = GetStorage().read('requrl');
    final resprop = GetStorage().read('resprop');
    final args = GetStorage().read('args');
    final type = GetStorage().read('argtype');
    final filename = GetStorage().read('fileform');
    final screenshots = GetStorage().read('screenshots');
    final screendir = GetStorage().read('screendir');
    final exit = GetStorage().read('autoexit');
    final argbody = GetStorage().read('body');
    final dest = GetStorage().read('destination');

    if (requrl == null) {
      Fluttertoast.showToast(msg: 'Nothing to load!');
      return;
    }

    setState(() {
      rqc.text = requrl;
      rsc.text = resprop!;
      agc.text = args!;
      fnc.text = filename!;
      idx = type;
      status = screenshots == 0 ? false : true;
      sdc.text = screendir == null ? "" : screendir;
      autoexit = exit == 0 ? false : true;
      body = argbody == 0 ? false : true;
      txc.text = idx == 1 ? 'Headers' : 'Arguments';
      if (dest != null) dest == 0 ? dropdownValue = 'Custom (SXCU)' : dropdownValue = 'Imgur';
      else GetStorage().write('destination', 0);
    });

    Fluttertoast.showToast(msg: 'Settings successfully loaded!');

    if (screenshots == true) {
      startForegroundService();

      Fluttertoast.showToast(msg: 'Enabled screenshot intercepting!');
    } else {
      await FlutterForegroundPlugin.stopForegroundService();
      Fluttertoast.showToast(msg: 'Disabled screenshot intercepting!');
    }
  }

  Future importSXCU(BuildContext context) async {
    await Permission.storage.request();

    final media = await FilePicker.platform.pickFiles(type: FileType.any);
    if (media == null) return;
    final file = File(media.files.first.path!);
    final extension = p.extension(file.path);

    if (extension != '.sxcu') {
      Widget okButton = TextButton(
        child: Text('I accept this error.'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text('Invalid file'),
        content: Text('Please select an .sxcu file!'),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return;
    }

    dynamic sxcu;
    final content = await file.readAsString();
    sxcu = jsonDecode(content);
    print(sxcu);
    final regexp = RegExp(
        r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');
    final match = regexp.firstMatch(sxcu['RequestURL']);

    if (match == null) {
      Widget okButton = TextButton(
        child: Text('I accept this error.'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text('Invalid request URL'),
        content: Text('The request URL needs to be a valid URL!'),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return;
    }

    final reqtype = sxcu['Body'];
    final reqregexp = RegExp(r'(?=.*?multi)(?=.*?part)(?=.*?form)(?=.*?data).*',
        caseSensitive: false);
    final reqmatch = reqregexp.firstMatch(reqtype);

    if (reqmatch == null) {
      Widget okButton = TextButton(
        child: Text('I accept this error.'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text('Invalid request type'),
        content: Text('The SXCU request type must be multipart/form-data!'),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return;
    }

    final url = sxcu['URL'];
    final resregexp = RegExp(r'\$json:([a-zA-Z]+)\$');
    final resmatch = resregexp.firstMatch(url);
    if (resmatch == null) {
      Widget okButton = TextButton(
        child: Text('I accept this error.'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text('Invalid response parameter'),
        content: Text(
            'The response URL must contain a \$json:parameter\$ argument!'),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return;
    }

    final formname = sxcu['FileFormName'];

    if (formname == null) {
      Widget okButton = TextButton(
        child: Text('I accept this error.'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text('Invalid file form name'),
        content: Text('The SXCU request must a file form name!'),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return;
    }

    final matchedText = resmatch.group(0)!;

    setState(() {
      sxc.text = p.basename(file.path);
      rqc.text = sxcu['RequestURL'];
      rsc.text = matchedText;
      fnc.text = sxcu['FileFormName'];

      if (sxcu['Headers'] == null) {
        agc.text = jsonEncode(sxcu['Arguments']);
        idx = 0;
        body = true;
        GetStorage().write('argtype', 0);
      } else if (sxcu['Arguments'] == null) {
        agc.text = jsonEncode(sxcu['Headers']);
        idx = 1;
        body = true;
        GetStorage().write('argtype', 1);
      } else if (sxcu['Arguments'] == null && sxcu['Headers'] == null) {
        body = false;
        GetStorage().write('argtype', 2);
      }
    });

    Fluttertoast.showToast(msg: 'Successfully imported SXCU!');

    GetStorage().write('requrl', rqc.text);
    GetStorage().write('resprop', matchedText);
    GetStorage().write('args', agc.text);
    GetStorage().write('fileform', fnc.text);

    Fluttertoast.showToast(msg: 'Settings saved successfully!');
    if (!main.appData.isPlatinum) _interstitialAd?.show();
  }

  Future saveSettings(BuildContext context) async {
    await Permission.storage.request();

    if ([rqc.text, rsc.text].every((v) => v == '')) {
      Fluttertoast.showToast(msg: 'Nothing to save (all fields required)!');
      if (!main.appData.isPlatinum) _sinterstitialAd?.show();
      return;
    }

    final regexp = RegExp(
        r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');
    final match = regexp.firstMatch(rqc.text);

    if (match == null) {
      Widget okButton = TextButton(
        child: Text('I accept this error.'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text('Invalid request URL'),
        content: Text('The request URL needs to be a valid URL!'),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return;
    }

    final resregexp = RegExp(r'\$json:([a-zA-Z]+)\$');
    final resmatch = resregexp.firstMatch(rsc.text);

    if (resmatch == null) {
      Widget okButton = TextButton(
        child: Text('I accept this error.'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text('Invalid response property'),
        content: Text('The response property did not match \$json:value\$'),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return;
    }

    GetStorage().write('requrl', rqc.text);
    GetStorage().write('resprop', rsc.text);
    GetStorage().write('args', agc.text);
    GetStorage().write('fileform', fnc.text);
    GetStorage().write('destination', dropdownValue == 'Custom (SXCU)' ? 0 : 1);

    Fluttertoast.showToast(msg: 'Settings saved successfully!');
    if (!main.appData.isPlatinum) _sinterstitialAd?.show();
  }
}
