import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Info extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InfoState();
  }
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(children: <Widget>[
        SizedBox(height: 14),
        Container(
          margin: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(border: Border.all(color: Colors.blue.shade900), borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Image.asset('assets/icon/platinum.png', width: 50, height: 50),
                Text('ImageLink Platinum™', style: TextStyle(fontSize: 20))
              ]),
              SizedBox(height: 5),
              Card(
                color: Colors.blue.shade900,
                child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Platinum Monthly™', style: TextStyle(fontSize: 20)),
                    TextButton(
                    child: Text('1.99 €'),
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      primary: Colors.white,
                    )),
                ])
              ),
              Card(
                color: Colors.blue.shade900,
                child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Platinum Annually™', style: TextStyle(fontSize: 20)),
                    TextButton(
                    child: Text('12.99 €'),
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      primary: Colors.white,
                    )),
                ])
              ),
              Card(
                color: Colors.blue.shade900,
                child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Platinum Lifetime™', style: TextStyle(fontSize: 20)),
                    TextButton(
                    child: Text('29.99 €'),
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      primary: Colors.white,
                    )),
                ])
              ),
            ],)
          ),
        SizedBox(height: 14),
        Container(
          constraints: new BoxConstraints(
              minHeight: 70.0,
              maxHeight: 70.0,
            ),
          width: double.infinity,
          height: 70.0,
          child: ElevatedButton.icon(
            label: Text('Discord', style: TextStyle(fontSize: 25)),
            icon: Icon(FontAwesomeIcons.discord, size: 30),
            onPressed: () {
              launch('https://discord.gg/MSDcP79cch');
            },
          ),
        ),
        SizedBox(height: 14),
        Container(
          constraints: new BoxConstraints(
              minHeight: 70.0,
              maxHeight: 70.0,
            ),
          width: double.infinity,
          height: 70.0,
          child: ElevatedButton.icon(
            label: Text('Twitter', style: TextStyle(fontSize: 25)),
            icon: Icon(FontAwesomeIcons.twitter, size: 30),
            onPressed: () {
              launch('https://twitter.com/castdrian');
            },
          ),
        ),
        SizedBox(height: 14),
        Container(
          constraints: new BoxConstraints(
              minHeight: 70.0,
              maxHeight: 70.0,
            ),
          width: double.infinity,
          height: 70.0,
          child: ElevatedButton.icon(
            label: Text('Credits', style: TextStyle(fontSize: 25)),
            icon: Icon(FontAwesomeIcons.creditCard, size: 30),
            onPressed: () {
              Widget okButton = TextButton(
                    child: Text('I respect these people.'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  );

                  AlertDialog alert = AlertDialog(
                    title: Text('Credits:'),
                    content: Text('- Adrian Castro\n- Sören Stabenow'),
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
            },
          ),
        ),
      ])
    );
  }
}
