import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Donate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DonateState();
  }
}

class _DonateState extends State<Donate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: <Widget>[
      SizedBox(height: 14),
        Container(
          width: double.infinity,
          height: 70.0,
          child: OutlinedButton.icon(
            label: Text('Paypal', style: TextStyle(fontSize: 25)),
            icon: Icon(FontAwesomeIcons.paypal, size: 30),
            onPressed: () {},
          ),
        ),
        SizedBox(height: 24),
        Container(
            width: double.infinity,
            height: 70.0,
            child: OutlinedButton.icon(
              label: Text('Patreon', style: TextStyle(fontSize: 25)),
              icon: Icon(FontAwesomeIcons.patreon, size: 30),
              onPressed: () {},
            ),
          ),
        SizedBox(height: 164),
        Container(
            width: double.infinity,
            height: 70.0,
            child: OutlinedButton.icon(
              label: Text('GitHub', style: TextStyle(fontSize: 25)),
              icon: Icon(FontAwesomeIcons.github, size: 30),
              onPressed: () {},
            ),
          ),
        SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 70.0,
          child: OutlinedButton.icon(
            label: Text('Discord', style: TextStyle(fontSize: 25)),
            icon: Icon(FontAwesomeIcons.discord, size: 30),
            onPressed: () {},
          ),
        ),
        SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 70.0,
          child: OutlinedButton.icon(
            label: Text('Twitter', style: TextStyle(fontSize: 25)),
            icon: Icon(FontAwesomeIcons.twitter, size: 30),
            onPressed: () {},
          ),
        ),
      ])
    );
  }
}
