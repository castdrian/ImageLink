import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chewie/chewie.dart';
import 'package:get_storage/get_storage.dart';
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
  bool dialVisible = true;
  final renderOverlay = true;
  final visible = true;
  final switchLabelPosition = false;
  final extend = false;
  final rmicons = false;
  final customDialRoot = false;
  final closeManually = false;
  final useRAnimation = true;
  final isDialOpen = ValueNotifier<bool>(false);
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

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      icon: Icons.upload_file,
      activeIcon: Icons.close,
      openCloseDial: isDialOpen,
      dialRoot: customDialRoot
          ? (ctx, open, key, toggleChildren, layerLink) {
              return CompositedTransformTarget(
                link: layerLink,
                child: TextButton(
                  key: key,
                  onPressed: toggleChildren,
                  child: Text("Text Button"),
                ),
              );
            }
          : null,
      buttonSize: 56, // it's the SpeedDial size which defaults to 56 itself
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
          onTap: () => print("FIRST CHILD"),
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
}
