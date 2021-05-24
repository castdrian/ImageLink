import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future uploadFile(File file) async {
  final prefs = await SharedPreferences.getInstance();
  final requrl = prefs.getString('requrl')!;
  final args = prefs.getString('args')!;
  final type = prefs.getInt('argtype');
  final filename = prefs.getString('fileform')!;

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
    prefs.setBool('refresh', true);
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
    final prefs = await SharedPreferences.getInstance();
    final resprop = prefs.getString('resprop')!;
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

dynamic historyWidgets(int index, SharedPreferences prefs) {
  final list = jsonDecode(prefs.getString('history') as String);

  final widget = Flexible(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            list[index],
            style: TextStyle(fontSize: 14),
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ),
        TextButton(
            child: Text('Copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: list[index]));
              Fluttertoast.showToast(msg: 'URL copied!');
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              primary: Colors.white,
            )),
      ]));
  return widget;
}

void historyPreview(int index, BuildContext context, SharedPreferences prefs) {
  final ext = ['.jpg', '.png', '.gif', '.webp'];
  final list = jsonDecode(prefs.getString('history') as String);

  if (ext.any(list[index].endsWith)) {
    Widget okButton = TextButton(
      child: Text('Thanks.'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text('File:'),
      content: Flexible(child: Image.network(list[index])),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  } else {
    Fluttertoast.showToast(msg: 'Preview is only available for images!');
  }
}

Future updateHistoryData(String input) async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString('history');

  if (data == null) {
    final list = [];
    list.add(input);
    final serialized = jsonEncode(list);
    prefs.setString('history', serialized);
  } else {
    final List deserialized = jsonDecode(data);

    if (deserialized.length >= 20) {
      deserialized.removeAt(19);
      deserialized.insert(0, input);

      final encoded = jsonEncode(deserialized);
      prefs.setString('history', encoded);
    } else {
      deserialized.insert(0, input);

      final encoded = jsonEncode(deserialized);
      prefs.setString('history', encoded);
    }
  }
}

int historyAmount(SharedPreferences prefs) {
  return jsonDecode(prefs.getString('history') as String).length;
}
