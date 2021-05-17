import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

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
      Expanded(
          child: fileMedia == null
              ? Icon(Icons.photo, size: 120)
              : Image.file(fileMedia)),
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
          onPressed: () async {
            if (fileMedia == null) {
              Fluttertoast.showToast(
                  msg: "Please select an image!",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
              return;
            }
            Fluttertoast.showToast(
                msg: "Uploading Image...",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);

            final upload = await uploadFile(fileMedia);

            if (upload == null) {
              Fluttertoast.showToast(
                  msg: "Failed to upload image!",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
              return;
            } else {
              print(upload);
              final url = 'https://depressed-lemonade.me/${upload['filename']}';
              Clipboard.setData(ClipboardData(text: url));
              Fluttertoast.showToast(
                  msg: "Successfully uploaded image!",
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
    final media = await ImagePicker().getImage(source: ImageSource.gallery);
    if (media == null) return;
    final file = File(media.path);

    if (file == null) {
      return;
    } else {
      setState(() {
        fileMedia = file;
      });
    }
  }

  Future uploadFile(File file) async {
    final req = http.MultipartRequest(
        'POST', Uri.parse('https://depressed-lemonade.me/sharexen.php'));

    req.files.add(await http.MultipartFile.fromPath('image', file.path));

    req.fields['endpoint'] = 'upload';
    req.fields['token'] = '';

    final response = await req.send();
    print(response.statusCode);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseString = await response.stream.bytesToString();
      final body = jsonDecode(responseString);
      return body;
    } else {
      return null;
    }
  }
}
