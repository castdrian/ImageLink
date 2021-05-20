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
import 'package:url_launcher/url_launcher.dart';
import 'main.dart' as main;
import 'package:package_info/package_info.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  File fileMedia;
  bool isVideo = false;
  final txt = TextEditingController();
  final List shared = main.getShared();

  Future<void> shareIntent() async {
    if (shared == null || shared.isEmpty) return;

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

    setState(() {
      fileMedia = File(shared.first.path);
    });

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

      final url = rawurl.replaceAll(RegExp(r'/^http:\/\//i'), 'https://');

      Clipboard.setData(ClipboardData(text: url));

      Fluttertoast.showToast(
          msg: 'File sucessfully uploaded!',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
  }

  @override
  void initState() {
    super.initState();
    shareIntent();

    // Request Permissions after loading the Home Screen
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await loadAsync(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(children: <Widget>[
          SizedBox(height: 50),
          Flexible(
              child: new OverflowBox(
              minWidth: 0.0, 
              minHeight: 0.0, 
              maxWidth: double.infinity, 
               child: fileMedia == null
                    ? Icon(Icons.photo, size: 150)
                    : isVideo == true
                        ? Icon(Icons.video_library, size: 150)
                        : Image.file(fileMedia)
        )),
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
            child: ElevatedButton.icon(
              label: Text('Select file', style: TextStyle(fontSize: 30)),
              icon: Icon(Icons.image, size: 30),
              onPressed: () async {
                if (isVideo == true) isVideo = false;

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
            child: ElevatedButton.icon(
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

  /// Executes async methods on loading completion.
  Future loadAsync(BuildContext context) async {
    Map<Permission, PermissionStatus> perms = await [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.ignoreBatteryOptimizations,
    ].request();

    // Check for new releases
    await checkLatestRelease(context);
  }

  /// Opens the gallery with a File Picker.
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

/// Checks for the latest version and opens a reminder if the current version is outdated.
Future checkLatestRelease(BuildContext context) async {
  // Grab the latest release from the GitHub API
  http.MultipartRequest req = http.MultipartRequest('GET', Uri.parse('https://api.github.com/repos/adrifcastr/ImageLink/releases/latest'));
  http.StreamedResponse response = await req.send();

  String version = '';

  if (response.statusCode == 404) {
    req = http.MultipartRequest('GET', Uri.parse('https://api.github.com/repos/adrifcastr/ImageLink/releases'));
    response = await req.send();

    if (response.statusCode == 404) {
      return print('No releases to check.');
    }

    version = jsonDecode(await response.stream.bytesToString())[0]['tag_name'];
  } else {
    version = jsonDecode(await response.stream.bytesToString())['tag_name'];
  }

  // Compare versions
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  final prefs = await SharedPreferences.getInstance();

  if (version != packageInfo.version && (prefs.getBool('updateAck') == null || !prefs.getBool('updateAck'))) {
    print('Version outdated. Current version: ' + packageInfo.version + ' | Latest version: ' + version);

    Widget okButton = TextButton(
      child: Text('Acknowledged.'),
      onPressed: () async {
        await prefs.setBool('updateAck', true);
        Navigator.of(context).pop();
      },
    );

    Widget githubButton = TextButton(
      child: Text('Update'),
      onPressed: () async {
        await prefs.setBool('updateAck', true);
        launch('https://github.com/adrifcastr/ImageLink/releases');
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text('Outdated Version!'),
      content: Text('Please update to the latest version available on GitHub.'),
      actions: [
        githubButton,
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
}

/// Sends a request with a file to the server specified in Settings.
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

/// Checks if the file is a Video
bool isVideoFile(String path) {
  String mimeType = lookupMimeType(path);
  return mimeType != null && mimeType.startsWith('video');
}
