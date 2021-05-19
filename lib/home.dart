import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  File fileMedia;
  bool isVideo = false;
  dynamic vid;
  final txt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(children: <Widget>[
          SizedBox(height: 50),
          Flexible(child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
              children: [ fileMedia == null
                  ? Icon(Icons.photo, size: 150)
                  : isVideo == true
                      ? Icon(Icons.video_library, size: 150)
                      : Image.file(fileMedia)])),
          SizedBox(height: 50),
          TextField(
            controller: txt,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selected file:',
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
            readOnly: true,
          ),
          SizedBox(height: 14),
          Container(
            constraints: new BoxConstraints(
              minHeight: 70.0,
              maxHeight: 70.0,
            ),
            width: double.infinity,
            height: 70.0,
            child: OutlinedButton.icon(
              label: Text('Select file', style: TextStyle(fontSize: 30)),
              icon: Icon(Icons.image, size: 30),
              onPressed: () async {
                if (isVideo == true) isVideo = false;

                await [
                  Permission.storage,
                  Permission.manageExternalStorage,
                  Permission.systemAlertWindow,
                  Permission.ignoreBatteryOptimizations,
                ].request();

                final prefs = await SharedPreferences.getInstance();
                final requrl = prefs.getString('requrl');

                if (requrl == null) {
                  Fluttertoast.showToast(
                      msg: 'You must specify settings first!',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                  return;
                }

                pickGalleryMedia(context);
              },
            ),
          ),
          SizedBox(height: 14),
          Container(
            constraints: new BoxConstraints(
              minHeight: 70.0,
              maxHeight: 70.0,
            ),
            width: double.infinity,
            height: 70.0,
            child: OutlinedButton.icon(
              label: Text('Upload', style: TextStyle(fontSize: 30)),
              icon: Icon(Icons.upload_file, size: 30),
              onPressed: () async {
                if (fileMedia == null) {
                  Fluttertoast.showToast(
                      msg: 'Please select a file!',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                  return;
                }
                Fluttertoast.showToast(
                    msg: 'Uploading file...',
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);

                final upload = await uploadFile(fileMedia);

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
                  final resprop = prefs.getString('resprop');
                  final regexp = RegExp(r'\$json:([a-zA-Z]+)\$');
                  final match = regexp.firstMatch(resprop);
                  final matched = match.group(1);
                  final rawurl = upload[matched] as String;

                  if (rawurl == null) {
                    Fluttertoast.showToast(
                        msg: 'Uploaded, but failed to parse response URL!',
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 2,
                        fontSize: 16.0);
                    return;
                  }

                  final url =
                      rawurl.replaceAll(RegExp(r'/^http:\/\//i'), 'https://');

                  Clipboard.setData(ClipboardData(text: url));

                  Fluttertoast.showToast(
                      msg: 'File sucessfully uploaded!',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                }
              },
            ),
          ),
        ]));
  }

  Future pickGalleryMedia(BuildContext context) async {
    final media = await FilePicker.platform.pickFiles(type: FileType.media);
    if (media == null) return;
    final file = File(media.files.first.path);
    if (isVideoFile(file.path) == true) isVideo = true;

    if (file == null) {
      return;
    } else {
      setState(() {
        fileMedia = file;
        txt.text = p.basename(file.path);
      });
    }
  }
}

Future uploadFile(File file) async {
  final prefs = await SharedPreferences.getInstance();
  final requrl = prefs.getString('requrl');
  final args = prefs.getString('args');
  final type = prefs.getInt('argtype');
  final filename = prefs.getString('fileform');

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
    return body;
  } else {
    return response.statusCode;
  }
}

bool isVideoFile(String path) {
  String mimeType = lookupMimeType(path);
  return mimeType != null && mimeType.startsWith('video');
}
