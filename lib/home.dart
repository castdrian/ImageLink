import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chewie/chewie.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
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
    buttons = uploadColumn(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Phoenix.rebirth(context);
          return Future.value(false);
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: <Widget>[
              main.appData.isPlatinum
                  ? Container()
                  : Align(
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: buttons,
        ));
  }

  Future pickGalleryMedia(BuildContext context, FileType type) async {
    final media = await FilePicker.platform.pickFiles(type: type);
    if (media == null) {
      setState(() {
        buttons = uploadColumn(context);
      });
      return;
    }
    final file = File(media.files.first.path!);
    if (isVideoFile(file.path) == true) isVideo = true;

    if (file.existsSync() == false) {
      setState(() {
        buttons = uploadColumn(context);
      });
      return;
    } else {
      setState(() {
        fileMedia = file;
        buttons = uploadColumn(context);
      });

      if (isVideo == true) {
        await initializePlayer();
      }
    }
  }

  void clearFile(BuildContext context) {
    setState(() {
      fileMedia = null;
      buttons = uploadColumn(context);
    });
  }

  Column uploadColumn(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      FloatingActionButton.extended(
        onPressed: () async {
          if (fileMedia == null) {
            Fluttertoast.showToast(msg: 'You must select a file first!');
            return;
          }

          Fluttertoast.showToast(msg: 'Uploading file...');

          final upload = await uploadFile(fileMedia!);
          await postUpload(upload);
          setState(() {});
        },
        label: const Text('Upload'),
        icon: const Icon(Icons.upload),
        backgroundColor: fileMedia == null ? Colors.grey : Colors.blue,
      ),
      SizedBox(height: 10),
      FloatingActionButton.extended(
        onPressed: () {
          if (isVideo == true) isVideo = false;

          final requrl = GetStorage().read('requrl');

          if (requrl == null) {
            Fluttertoast.showToast(msg: 'You must specify settings first!');
            main.pageController.animateToPage(1,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
            return;
          }

          GetStorage().write('refresh', 0);
          setState(() {
            fileMedia = null;
            buttons = selectRow(context);
          });
        },
        label: const Text('Select file'),
        icon: const Icon(Icons.upload_file),
        backgroundColor: Colors.blue,
      ),
    ]);
  }

  Row selectRow(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      FloatingActionButton.extended(
        onPressed: () => pickGalleryMedia(context, FileType.video),
        label: const Text('Video'),
        icon: const Icon(Icons.video_collection),
        backgroundColor: Colors.blue,
      ),
      FloatingActionButton.extended(
        onPressed: () => pickGalleryMedia(context, FileType.image),
        label: const Text('Image'),
        icon: const Icon(Icons.image),
        backgroundColor: Colors.blue,
      ),
      FloatingActionButton.extended(
        onPressed: () => main.appData.isPlatinum
            ? pickGalleryMedia(context, FileType.any)
            : platinumDialog(context),
        label: const Text('File'),
        icon: const Icon(Icons.file_copy),
        backgroundColor: Colors.blue,
      ),
    ]);
  }
}
