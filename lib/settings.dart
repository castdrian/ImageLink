import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(children: <Widget>[
          SizedBox(height: 10),
          TextField(
            controller: rqc,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Request URL (example.com/upload.php):',
            ),
          ),
          SizedBox(height: 14),
          TextField(
            controller: rsc,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Response img url prop (\$json:parameter\$):',
            ),
          ),
          SizedBox(height: 14),
          TextField(
            controller: agc,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                labelText: 'JSON Arguments (multipart/form-data):'),
            maxLines: 5,
          ),
          SizedBox(height: 24),
          TextField(
            controller: sxc,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selected SXCU:',
            ),
            readOnly: true,
          ),
          SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 70.0,
            child: OutlinedButton.icon(
              label: Text('Import SXCU', style: TextStyle(fontSize: 25)),
              icon: Icon(Icons.upload_file, size: 30),
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

                final reqtype = sxcu['Body'];
                print(reqtype);
                if (reqtype != 'MultipartFormData') {
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
                if (args == null) {
                  Widget okButton = TextButton(
                    child: Text('I accept this error.'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  );

                  AlertDialog alert = AlertDialog(
                    title: Text('Invalid request arguments'),
                    content:
                        Text('The SXCU request body must contain arguments!'),
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
                final regexp = RegExp(r'\$json:([a-zA-Z]+)\$');
                final match = regexp.firstMatch(url);
                if (match == null) {
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
                final matchedText = match.group(0);

                setState(() {
                  sxc.text = p.basename(file.path);
                  rqc.text = sxcu['RequestURL'];
                  rsc.text = matchedText;
                  agc.text = sxcu['Arguments'].toString();
                });

                Fluttertoast.showToast(
                    msg: 'Successfully imported SXCU!',
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);

                final prefs = await SharedPreferences.getInstance();
                prefs.setString('requrl', rqc.text);
                prefs.setString('resprop', rsc.text);
                prefs.setString('args', agc.text);

                Fluttertoast.showToast(
                    msg: 'Settings saved successfully!',
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 70.0,
            child: OutlinedButton.icon(
              label: Text('Load settings', style: TextStyle(fontSize: 25)),
              icon: Icon(Icons.open_in_browser, size: 30),
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
                });

                Fluttertoast.showToast(
                    msg: 'Settings successfully loaded!',
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 70.0,
            child: OutlinedButton.icon(
              label: Text('Save settings', style: TextStyle(fontSize: 25)),
              icon: Icon(Icons.save, size: 30),
              onPressed: () async {
                await [
                  Permission.storage,
                  Permission.manageExternalStorage,
                  Permission.systemAlertWindow,
                  Permission.ignoreBatteryOptimizations,
                ].request();

                if ([rqc.text, rsc.text, agc.text].every((v) => v != null)) {
                  Fluttertoast.showToast(
                      msg: 'Nothing to save (all fields required)!',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                prefs.setString('requrl', rqc.text);
                prefs.setString('resprop', rsc.text);
                prefs.setString('args', agc.text);

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
