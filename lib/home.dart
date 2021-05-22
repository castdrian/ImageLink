import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart' as main;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  final _flutterVideoCompress = FlutterVideoCompress();
  File videopreview;
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

    File preview;

    if (isVideo == true) {
        final file = await _flutterVideoCompress.convertVideoToGif(
        shared.first.path,
        startTime: 0, // default(0)
        duration: 3, // default(-1)
        // endTime: -1 // default(-1)
        );
        preview = file;
    }

    setState(() {
      fileMedia = File(shared.first.path);
      if (preview != null) videopreview = preview;
    });

    Fluttertoast.showToast(
        msg: 'Uploading file...',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 2,
        fontSize: 16.0);

    final upload = await main.uploadFile(fileMedia);
    await main.postUpload(upload);
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
                          ? Image.file(videopreview)
                          : Image.file(fileMedia))),
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

                prefs.setBool('refresh', false);
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

                final upload = await main.uploadFile(fileMedia);
                await main.postUpload(upload);
              },
            ),
          ),
        ]));
  }

  Future loadAsync(BuildContext context) async {
    await [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.ignoreBatteryOptimizations,
    ].request();
  }

  Future pickGalleryMedia(BuildContext context) async {
    final media = await FilePicker.platform.pickFiles(type: FileType.media);
    if (media == null) return;
    final file = File(media.files.first.path);
    if (isVideoFile(file.path) == true) isVideo = true;

    if (file == null) {
      return;
    } else {

      File preview;

      if (isVideo == true) {
          final vfile = await _flutterVideoCompress.convertVideoToGif(
          file.path,
          startTime: 0, // default(0)
          duration: 3, // default(-1)
          // endTime: -1 // default(-1)
          );
          preview = vfile;
      }

      setState(() {
        fileMedia = file;
        txt.text = p.basename(file.path);
        if (preview != null) videopreview = preview;
      });
    }
  }
}

bool isVideoFile(String path) {
  String mimeType = lookupMimeType(path);
  return mimeType != null && mimeType.startsWith('video');
}
