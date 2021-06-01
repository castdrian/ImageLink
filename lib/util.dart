import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'main.dart' as main;

Future uploadFile(File file) async {
  final requrl = GetStorage().read('requrl')!;
  final args = GetStorage().read('args')!;
  final type = GetStorage().read('argtype');
  final filename = GetStorage().read('fileform')!;

  final fields = jsonDecode(args);
  final req = http.MultipartRequest('POST', Uri.parse(requrl));

  String mimeType = lookupMimeType(file.path) as String;
  String mimee = mimeType.split('/')[0];
  String mtype = mimeType.split('/')[1];

  req.files.add(await http.MultipartFile.fromPath(filename, file.path, contentType: MediaType(mimee, mtype)));

  if (type == 0) {
    fields.forEach((k, v) {
      req.fields[k] = v;
    });
  } else if (type == 1) {
    final headers = new Map<String, String>.from(fields);
    req.headers.addAll(headers);
  }

  final response = await req.send();
  print(response.statusCode);

  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseString = await response.stream.bytesToString();
    final body = jsonDecode(responseString);
    GetStorage().write('refresh', 1);
    return body;
  } else {
    return response.statusCode;
  }
}

Future postUpload(dynamic upload) async {
  if (upload is int) {
    Fluttertoast.showToast(msg: 'Failed to upload file! HTTP Code $upload');
    return;
  } else {
    print(upload);
    final resprop = GetStorage().read('resprop')!;
    final regexp = RegExp(r'\$json:([a-zA-Z]+)\$');
    final match = regexp.firstMatch(resprop)!;
    final matched = match.group(1);
    final rawurl = upload[matched] as String?;

    if (rawurl == null) {
      Fluttertoast.showToast(
          msg: 'Uploaded, but failed to parse response URL!');
      return;
    }

    final url = rawurl.replaceAll(RegExp(r'/^http:\/\//i'), 'https://');

    Clipboard.setData(ClipboardData(text: url));
    Fluttertoast.showToast(msg: 'File sucessfully uploaded!');
    await updateHistoryData(url);
    if (GetStorage().read('autoexit') == 1)
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}

bool isVideoFile(String path) {
  String? mimeType = lookupMimeType(path);
  return mimeType != null && mimeType.startsWith('video');
}

void platinumDialog(BuildContext context) {
  Widget yesButton = TextButton(
    child: Text('Gimme!'),
    onPressed: () {
      Navigator.of(context).pop();
      main.pageController.animateToPage(3, duration: Duration(milliseconds: 300), curve: Curves.ease);
    },
  );

  Widget noButton = TextButton(
    child: Text('Naw, thanks.'),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text('ImageLink Platinum™'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
            'Looks like you found an ImageLink Platinum™ feature!\nSubscribe today to get the most out of ImageLink!'),
        SizedBox(height: 24),
        Image.asset('assets/icon/platinum.png', width: 150, height: 150)
      ],
    ),
    actions: [
      noButton,
      yesButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void startForegroundService() async {
  await FlutterForegroundPlugin.setServiceMethodInterval(seconds: 5);
  await FlutterForegroundPlugin.setServiceMethod(globalForegroundService);
  await FlutterForegroundPlugin.startForegroundService(
    holdWakeLock: false,
    onStarted: () {
      print('Foreground on Started');
    },
    onStopped: () {
      print('Foreground on Stopped');
    },
    title: 'ImageLink',
    content: 'ImageLink screenshot detection',
    iconName: 'icon',
  );
}

void globalForegroundService() {
  debugPrint('current datetime is ${DateTime.now()}');
}

dynamic historyWidgets(int index, List<String> list, BuildContext context) {
  final ext = ['.jpg', '.png', '.gif', '.webp'];
  final widget = Container(
  child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  mainAxisSize: MainAxisSize.max,
  children: [
    Container(child: Image.network(list[index],
      loadingBuilder: (context, child, loadingProgress) =>
          (loadingProgress == null) ? child : CircularProgressIndicator(),
      errorBuilder: (context, error, stackTrace) =>  ext.any(list[index].endsWith) == true
        ? Icon(Icons.broken_image_outlined)
        : Icon(Icons.video_library),
    ), width: 70,
    ), 
      Text(
        list[index],
        style: TextStyle(fontSize: 14),
        softWrap: false,
        overflow: TextOverflow.fade,
      )
    ]));
  return widget;
}

Future updateHistoryData(String input) async {
  final data = GetStorage().read('history')?.cast<String>().toList();
  if (data == null || data.isEmpty) {
    final list = <String>[];
    list.add(input);
    GetStorage().write('history', list);
  } else {
    if (data.length >= 20) {
      data.removeAt(19);
      data.insert(0, input);
      GetStorage().write('history', data);
    } else {
      data.insert(0, input);
      GetStorage().write('history', data);
    }
  }
}
