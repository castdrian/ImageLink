import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  File fileMedia;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: <Widget>[
          SizedBox(height: 180),
          Expanded(child: fileMedia == null ? Icon(Icons.photo, size: 120) : Image.file(fileMedia)),
          SizedBox(height: 140),
          Container(
            width: double.infinity,
            height: 70.0,
            child: OutlinedButton.icon(
              label: Text('Select Image', style: TextStyle(fontSize: 30)),
              icon: Icon(Icons.image, size: 30),
              onPressed: () => pickGalleryMedia(context),
            ),
          ),
          SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 70.0,
            child: OutlinedButton.icon(
              label: Text('Upload', style: TextStyle(fontSize: 30)),
              icon: Icon(Icons.upload_file, size: 30),
              onPressed: () {},
            ),
          ),
    ]));
  }

  Future pickGalleryMedia(BuildContext context) async {
    final media = await ImagePicker().getImage(source: ImageSource.gallery);
    final file = File(media.path);

    if (file == null) {
      return;
    } else {
      setState(() {
        fileMedia = file;
      });
    }
  }
}
