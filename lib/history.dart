import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            ],
          )
        ]));
  }
}
