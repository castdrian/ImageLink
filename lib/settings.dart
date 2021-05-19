import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  final sxc = TextEditingController();
  final rqc = TextEditingController();
  final rsc = TextEditingController();
  final agc = TextEditingController();
  final fnc = TextEditingController();
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(children: <Widget>[
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
            maxLines: 4,
          ),
          SizedBox(height: 10),
          ToggleSwitch(
            fontSize: 20,
            initialLabelIndex: idx,
            minHeight: 50,
            minWidth: double.infinity,
            cornerRadius: 20.0,
            activeBgColor: Colors.cyan,
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
          SizedBox(height: 10),
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
          SizedBox(height: 10),
          Container(
            constraints: new BoxConstraints(
              minHeight: 60.0,
              maxHeight: 60.0,
            ),
            width: double.infinity,
            height: 60.0,
            child: OutlinedButton.icon(
              label: Text('Import SXCU', style: TextStyle(fontSize: 25)),
              icon: Icon(Icons.upload_file, size: 25),
              onPressed: () async {
                await [
                  Permission.storage,
                  Permission.manageExternalStorage,
                  Permission.systemAlertWindow,
                  Permission.ignoreBatteryOptimizations,
                ].request();

                final media =
                    await FilePicker.platform.pickFiles(type: FileType.any);
                if (media == null) return;
                final file = File(media.files.first.path);
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
                    content:
                        Text('The selected file did not contain valid JSON!'),
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
                final reqregexp = RegExp(
                    r'(?=.*?multi)(?=.*?part)(?=.*?form)(?=.*?data).*',
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
                    content: Text(
                        'The SXCU request type must be multipart/form-data!'),
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
                    content: Text(
                        'The SXCU request must contain arguments or headers!'),
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

                final matchedText = resmatch.group(0);
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

                Fluttertoast.showToast(
                    msg: 'Successfully imported SXCU!',
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);

                final prefs = await SharedPreferences.getInstance();
                prefs.setString('requrl', rqc.text);
                prefs.setString('resprop', matchedText);
                prefs.setString('args', agc.text);
                prefs.setString('fileform', fnc.text);

                Fluttertoast.showToast(
                    msg: 'Settings saved successfully!',
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              },
            ),
          ),
          SizedBox(height: 5),
          Container(
            constraints: new BoxConstraints(
              minHeight: 60.0,
              maxHeight: 60.0,
            ),
            width: double.infinity,
            height: 60.0,
            child: OutlinedButton.icon(
              label: Text('Load settings', style: TextStyle(fontSize: 25)),
              icon: Icon(Icons.open_in_browser, size: 25),
              onPressed: () async {
                await [
                  Permission.storage,
                  Permission.manageExternalStorage,
                  Permission.systemAlertWindow,
                  Permission.ignoreBatteryOptimizations,
                ].request();

                final prefs = await SharedPreferences.getInstance();
                final requrl = prefs.getString('requrl');
                final resprop = prefs.getString('resprop');
                final args = prefs.getString('args');
                final type = prefs.getInt('argtype');
                final filename = prefs.getString('fileform');

                if (requrl == null) {
                  Fluttertoast.showToast(
                      msg: 'Nothing to load!',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                  return;
                }

                setState(() {
                  rqc.text = requrl;
                  rsc.text = resprop;
                  agc.text = args;
                  fnc.text = filename;
                  idx = type;
                });

                Fluttertoast.showToast(
                    msg: 'Settings successfully loaded!',
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              },
            ),
          ),
          SizedBox(height: 5),
          Container(
            constraints: new BoxConstraints(
              minHeight: 60.0,
              maxHeight: 60.0,
            ),
            width: double.infinity,
            height: 60.0,
            child: OutlinedButton.icon(
              label: Text('Save settings', style: TextStyle(fontSize: 25)),
              icon: Icon(Icons.save, size: 25),
              onPressed: () async {
                await [
                  Permission.storage,
                  Permission.manageExternalStorage,
                  Permission.systemAlertWindow,
                  Permission.ignoreBatteryOptimizations,
                ].request();

                if ([rqc.text, rsc.text, agc.text].every((v) => v == '')) {
                  Fluttertoast.showToast(
                      msg: 'Nothing to save (all fields required)!',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
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
                    content: Text(
                        'The response property did not match \$json:value\$'),
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
                    content:
                        Text('The arguments field did not contain valid JSON!'),
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

                Fluttertoast.showToast(
                    msg: 'Settings saved successfully!',
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              },
            ),
          ),
        ]));
  }
}
