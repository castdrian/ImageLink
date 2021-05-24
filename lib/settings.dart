import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:imagelink/util.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'package:floating_action_row/floating_action_row.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  final sxc = TextEditingController();
  final sdc = TextEditingController();
  final rqc = TextEditingController();
  final rsc = TextEditingController();
  final agc = TextEditingController();
  final fnc = TextEditingController();
  int? idx = 0;
  bool status = false;
  String? dir;
  String dropdownValue = 'Custom (SXCU)';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) async => await loadAsync(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          SizedBox(height: 5),
          TextField(
            controller: rqc,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Request URL (example.com/upload.php):',
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: rsc,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Response property (\$json:parameter\$):',
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: fnc,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'FileFormName:',
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: agc,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                labelText: 'JSON (multipart/form-data):'),
            maxLines: 3,
          ),
          SizedBox(height: 5),
          new ToggleSwitch(
            fontSize: 20,
            initialLabelIndex: idx!,
            minHeight: 40,
            minWidth: double.infinity,
            cornerRadius: 20.0,
            activeBgColor: Colors.blue,
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            labels: ['Arguments', 'Headers'],
            onToggle: (index) async {
              setState(() {
                idx = index;
              });
            },
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text('Intercept screenshots:',
                      style: TextStyle(fontSize: 19),
                      textAlign: TextAlign.center)),
              Expanded(
                  child: FlutterSwitch(
                      width: 100.0,
                      height: 40.0,
                      valueFontSize: 20.0,
                      toggleSize: 40.0,
                      value: status,
                      borderRadius: 30.0,
                      padding: 8.0,
                      showOnOff: true,
                      onToggle: (val) async {
                        final prefs = await SharedPreferences.getInstance();

                        setState(() {
                          status = val;
                          prefs.setBool('screenshots', status);
                          prefs.setBool('refresh', true);
                        });

                        if (status == true) {
                          final requrl = prefs.getString('requrl');

                          if (requrl == null) {
                            Fluttertoast.showToast(msg: 'Nothing to load!');
                            return;
                          }

                          final path =
                              await FilePicker.platform.getDirectoryPath();

                          if (path == null) {
                            prefs.setBool('screenshots', false);
                            setState(() {
                              status = false;
                            });
                            return;
                          }
                          dir = path;

                          setState(() {
                            sdc.text = dir!;
                            prefs.setString('screendir', dir!);
                          });

                          startForegroundService();
                          Fluttertoast.showToast(
                              msg: 'Enabled screenshot intercepting!');
                        } else {
                          await FlutterForegroundPlugin.stopForegroundService();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text('Upload destination:',
                      style: TextStyle(fontSize: 19),
                      textAlign: TextAlign.center)),
              Expanded(
                  child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                    value: dropdownValue,
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.blue, fontSize: 19),
                    underline: Container(
                      height: 2,
                      color: Colors.blue,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        platinumDialog(context);
                        return;
                        // ignore: dead_code
                        dropdownValue = newValue!;
                      });
                    },
                    items: <String>[
                      'Custom (SXCU)',
                      'Imgur',
                      'oh-mama',
                      'bingpot'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()),
              )))
            ],
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buildButtons(context),
    );
  }

  Future loadAsync(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final requrl = prefs.getString('requrl');
    final resprop = prefs.getString('resprop');
    final args = prefs.getString('args');
    final type = prefs.getInt('argtype');
    final filename = prefs.getString('fileform');
    final screenshots = prefs.getBool('screenshots');
    final screendir = prefs.getString('screendir');

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
      status = screenshots ?? false;
      sdc.text = screendir == null ? "" : screendir;
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
    print(extension);
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
    try {
      final content = await file.readAsString();
      sxcu = jsonDecode(content);
      print(sxcu);
    } on FormatException catch (e) {
      print(e);
      Widget okButton = TextButton(
        child: Text('I accept this error.'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text('Invalid JSON'),
        content: Text('The selected file did not contain valid JSON!'),
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

    final args = sxcu['Arguments'];
    final headers = sxcu['Headers'];

    if (args == null && headers == null) {
      Widget okButton = TextButton(
        child: Text('I accept this error.'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text('Invalid request data'),
        content: Text('The SXCU request must contain arguments or headers!'),
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
    final idxprefs = await SharedPreferences.getInstance();

    setState(() {
      sxc.text = p.basename(file.path);
      rqc.text = sxcu['RequestURL'];
      rsc.text = matchedText;
      fnc.text = sxcu['FileFormName'];

      if (sxcu['Headers'] == null) {
        agc.text = jsonEncode(sxcu['Arguments']);
        idx = 0;
        idxprefs.setInt('argtype', 0);
      } else {
        agc.text = jsonEncode(sxcu['Headers']);
        idx = 1;
        idxprefs.setInt('argtype', 1);
      }
    });

    Fluttertoast.showToast(msg: 'Successfully imported SXCU!');

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('requrl', rqc.text);
    prefs.setString('resprop', matchedText);
    prefs.setString('args', agc.text);
    prefs.setString('fileform', fnc.text);

    Fluttertoast.showToast(msg: 'Settings saved successfully!');
  }

  Future saveSettings(BuildContext context) async {
    await Permission.storage.request();

    if ([rqc.text, rsc.text, agc.text].every((v) => v == '')) {
      Fluttertoast.showToast(msg: 'Nothing to save (all fields required)!');
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

    try {
      jsonDecode(agc.text);
    } on FormatException catch (e) {
      print(e);
      Widget okButton = TextButton(
        child: Text('I accept this error.'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text('Invalid JSON'),
        content: Text('The arguments field did not contain valid JSON!'),
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

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('requrl', rqc.text);
    prefs.setString('resprop', rsc.text);
    prefs.setString('args', agc.text);
    prefs.setString('fileform', fnc.text);

    Fluttertoast.showToast(msg: 'Settings saved successfully!');
  }

  FloatingActionRow buildButtons(BuildContext context) {
    return FloatingActionRow(
      color: Colors.blueAccent,
      children: <Widget>[
        FloatingActionRowButton(
          icon: Icon(Icons.upload_file),
          onTap: () {
            importSXCU(context);
          },
        ),
        FloatingActionRowDivider(
          color: Colors.white,
        ),
        FloatingActionRowButton(
          icon: Icon(Icons.save),
          onTap: () {
            saveSettings(context);
          },
        ),
      ],
    );
  }
}
