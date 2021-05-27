import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chewie/chewie.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'main.dart' as main;
import 'util.dart';

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
  dynamic buttons;
  final List? shared = main.getShared();
  late ScrollController scrollController;
  final renderOverlay = true;
  final visible = true;
  final switchLabelPosition = false;
  final extend = false;
  final rmicons = false;
  final closeManually = false;
  final useRAnimation = true;
  final speedDialDirection = SpeedDialDirection.Left;
  final selectedfABLocation = FloatingActionButtonLocation.endDocked;

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

    final requrl = GetStorage().read('requrl');

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

    buttons = buildSpeedDial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: main.homeAd.size.width.toDouble(),
                height: main.homeAd.size.height.toDouble(),
                child: AdWidget(ad: main.homeAd),
              ),
            ),
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
      floatingActionButton: buttons,
    );
  }

  Future pickGalleryMedia(BuildContext context, FileType type) async {
    final media = await FilePicker.platform.pickFiles(type: type);
    if (media == null) {
      setState(() {
        buttons = buildSpeedDial();
      });
      return;
    }
    final file = File(media.files.first.path!);
    if (isVideoFile(file.path) == true) isVideo = true;

    if (file.existsSync() == false) {
      setState(() {
        buttons = buildSpeedDial();
      });
      return;
    } else {
      setState(() {
        fileMedia = file;
        buttons = buildSpeedDial();
      });

      if (isVideo == true) {
        await initializePlayer();
      }
    }
  }

  void clearFile(BuildContext context) {
    setState(() {
      fileMedia = null;
      buttons = buildSpeedDial();
    });
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      icon: Icons.upload_file,
      activeIcon: Icons.close,
      buttonSize: 56,
      childrenButtonSize: 56.0,
      visible: visible,
      direction: speedDialDirection,
      switchLabelPosition: switchLabelPosition,
      closeManually: closeManually,
      renderOverlay: renderOverlay,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      useRotationAnimation: useRAnimation,
      elevation: 8.0,
      shape: CircleBorder(),
      childMargin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      children: [
        SpeedDialChild(
          child: !rmicons ? Icon(Icons.upload_file) : null,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'Select file',
          onTap: () => setState(() {
            fileMedia = null;
            buttons = buildSelectDial();
          }),
        ),
        SpeedDialChild(
          child: !rmicons ? Icon(Icons.upload) : null,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'Upload',
          onTap: () => print('SECOND CHILD'),
        )
      ],
    );
  }

  SpeedDial buildSelectDial() {
    return SpeedDial(
      icon: Icons.upload_file,
      activeIcon: Icons.close,
      buttonSize: 56,
      childrenButtonSize: 56.0,
      visible: visible,
      direction: speedDialDirection,
      switchLabelPosition: switchLabelPosition,
      closeManually: closeManually,
      renderOverlay: renderOverlay,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      useRotationAnimation: useRAnimation,
      elevation: 8.0,
      shape: CircleBorder(),
      onClose: () => setState(() {
        fileMedia = null;
        buttons = buildSpeedDial();
      }),
      childMargin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      children: [
        SpeedDialChild(
          child: !rmicons ? Icon(Icons.image) : null,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'Image',
          onTap: () => print("FIRST CHILD"),
        ),
        SpeedDialChild(
          child: !rmicons ? Icon(Icons.video_collection) : null,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'Video',
          onTap: () => print("FIRST CHILD"),
        ),
        SpeedDialChild(
          child: !rmicons ? Icon(Icons.file_copy) : null,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'File',
          onTap: () => print('SECOND CHILD'),
        )
      ],
    );
  }
}
