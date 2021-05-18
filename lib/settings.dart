import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  final sxc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(children: <Widget>[
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Request URL (example.com/upload.php):',
            ),
          ),
          SizedBox(height: 14),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Res img url prop (\$json:url\$):',
            ),
          ),
          SizedBox(height: 14),
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                labelText: 'JSON Arguments (multipart/form-data):'),
            maxLines: 7,
          ),
          SizedBox(height: 24),
          TextField(
            controller: sxc,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selected SXCU:',
            ),
            readOnly: true,
            maxLines: null,
          ),
          SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 70.0,
            child: OutlinedButton.icon(
              label: Text('Import SXCU', style: TextStyle(fontSize: 25)),
              icon: Icon(Icons.upload_file, size: 30),
              onPressed: () async {
                final media =
                    await FilePicker.platform.pickFiles(type: FileType.any);
                if (media == null) return;
                final file = File(media.files.first.path);
                final extension = p.extension(file.path);

                if (extension != '.sxcu' || extension != '.json') {
                  // set up the button
                  Widget okButton = TextButton(
                    child: Text("I accept this error."),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  );

                  // set up the AlertDialog
                  AlertDialog alert = AlertDialog(
                    title: Text("Invalid file"),
                    content: Text("Please select an .sxcu or .json file!"),
                    actions: [
                      okButton,
                    ],
                  );

                  // show the dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
                  return;
                }
                setState(() {
                  sxc.text = file.path;
                });

                Fluttertoast.showToast(
                    msg: "Successfully imported SXCU!",
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
              onPressed: () {
                Fluttertoast.showToast(
                    msg: "Settings saved successfully!",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              },
            ),
          ),
        ]));
  }
}
