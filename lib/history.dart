import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:imagelink/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class History extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HistoryState();
  }
}

class _HistoryState extends State<History> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> nothing = [
    SizedBox(height: 100),
    Row(
      children: [
        Expanded(
            child: Text(
          'Doesn\'t look like anything to me',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25),
        )),
      ],
    ),
    SizedBox(height: 40),
    Icon(FontAwesomeIcons.question, size: 150)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return ListTile(
                title: historyWidgets(index),
                onLongPress: () => historyPreview(index, context),
              );
            }));
  }
}
