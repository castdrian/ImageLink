import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'main.dart' as main;
import 'util.dart';
import 'package:floating_action_row/floating_action_row.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  Chewie? player;
  File? fileMedia;
  bool isVideo = false;
  final List? shared = main.getShared();
  FloatingActionRow? buttons;

  Future<void> initializePlayer() async {
    final videoPlayerController = VideoPlayerController.file(fileMedia!);

    await videoPlayerController.initialize();

    final chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
    );

    final playerWidget = Chewie(
      controller: chewieController,
    );
    setState(() {
      player = playerWidget;
    });
  }

  Future<void> shareIntent() async {
    if (shared == null || shared!.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final requrl = prefs.getString('requrl');

    if (requrl == null) {
      Fluttertoast.showToast(msg: 'You must specify settings first!');
      return;
    }
    setState(() {
      fileMedia = File(shared!.first.path);
    });

    if (isVideo == true) {
      await initializePlayer();
    }

    Fluttertoast.showToast(msg: 'Uploading file...');

    final upload = await uploadFile(fileMedia!);
    await postUpload(upload);
  }

  @override
  void initState() {
    super.initState();
    shareIntent();

    buttons = buildMainButtons(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          SizedBox(height: 50),
          Flexible(
              child: new OverflowBox(
                  minWidth: 0.0,
                  minHeight: 0.0,
                  maxWidth: double.infinity,
                  child: fileMedia == null
                      ? Icon(Icons.photo, size: 150)
                      : isVideo == true
                          ? player
                          : Image.file(fileMedia!))),
          SizedBox(height: 100),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buttons,
    );
  }


  Future pickGalleryMedia(BuildContext context, FileType type) async {
    final media = await FilePicker.platform.pickFiles(type: type);
    if (media == null) {
      setState(() {
        buttons = buildMainButtons(context);
      });
      return;
    }
    final file = File(media.files.first.path!);
    if (isVideoFile(file.path) == true) isVideo = true;

    if (file.existsSync() == false) {
      setState(() {
        buttons = buildMainButtons(context);
      });
      return;
    } else {
      setState(() {
        fileMedia = file;
        buttons = buildMainButtons(context);
      });

      if (isVideo == true) {
        await initializePlayer();
      }
    }
  }

  FloatingActionRow buildMainButtons(BuildContext context) {
    return FloatingActionRow(
      color: Colors.blueAccent,
      children: <Widget>[
        FloatingActionRowButton(
          icon: Icon(Icons.image),
          onTap: () async {
            if (isVideo == true) isVideo = false;

            final prefs = await SharedPreferences.getInstance();
            final requrl = prefs.getString('requrl');

            if (requrl == null) {
              Fluttertoast.showToast(msg: 'You must specify settings first!');
              return;
            }

            prefs.setBool('refresh', false);
            setState(() {
              buttons = buildFileButtons(context);
            });
          },
        ),
        FloatingActionRowDivider(
          color: Colors.white,
        ),
        FloatingActionRowButton(
          icon: Icon(Icons.upload_rounded),
          color: fileMedia == null ? Colors.grey : Colors.transparent,
          onTap: () async {
            if (fileMedia == null) return;

            Fluttertoast.showToast(msg: 'Uploading file...');

            final upload = await uploadFile(fileMedia!);
            await postUpload(upload);
          },
        ),
        FloatingActionRowButton(
          icon: Icon(Icons.clear),
          color: fileMedia == null ? Colors.grey : Colors.red,
          onTap: () {
            if (fileMedia == null) return;
            clearFile(context);
          },
        ),
      ],
    );
  }

  FloatingActionRow buildFileButtons(BuildContext context) {
    return FloatingActionRow(
      color: Colors.blueAccent,
      children: <Widget>[
        FloatingActionRowButton(
          icon: Icon(Icons.image),
          onTap: () {
            pickGalleryMedia(context, FileType.image);
          },
        ),
        FloatingActionRowDivider(
          color: Colors.white,
        ),
        FloatingActionRowButton(
          icon: Icon(Icons.videocam),
          onTap: () {
            pickGalleryMedia(context, FileType.video);
          },
        ),
        FloatingActionRowDivider(
          color: Colors.white,
        ),
        FloatingActionRowButton(
          icon: Icon(Icons.insert_drive_file_outlined),
          onTap: () {
            pickGalleryMedia(context, FileType.any);
          },
        ),
      ],
    );
  }

  void clearFile(BuildContext context) {
    setState(() {
      fileMedia = null;
      buttons = buildMainButtons(context);
    });
  }
}

bool isVideoFile(String path) {
  String? mimeType = lookupMimeType(path);
  return mimeType != null && mimeType.startsWith('video');
}
