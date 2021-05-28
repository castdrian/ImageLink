import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart' as main;

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
                    onPressed: () {
                      Fluttertoast.showToast(msg: 'Coming soon my dear friend!');
                    },
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
                    onPressed: () {
                      Fluttertoast.showToast(msg: 'Coming soon my dear friend!');
                    },
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
                    onPressed: () {
                      Fluttertoast.showToast(msg: 'Coming soon my dear friend!');
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      primary: Colors.white,
                    )),
                ])
              ),
              TextButton(
                    child: Text('Restore purchase'),
                    onPressed: () {
                      Fluttertoast.showToast(msg: 'Coming soon my dear friend!');
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      primary: Colors.white,
                    )),
            ],)
          ),
        SizedBox(height: 10),
        Container(
          constraints: new BoxConstraints(
              minHeight: 50.0,
              maxHeight: 50.0,
            ),
          width: double.infinity,
          height: 50.0,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              onPrimary: Colors.white,
              primary: Color(0xFF5865F2)),
            label: Text('Discord', style: TextStyle(fontSize: 25)),
            icon: Icon(FontAwesomeIcons.discord, size: 30),
            onPressed: () {
              launch('https://discord.gg/MSDcP79cch');
            },
          ),
        ),
        SizedBox(height: 10),
        Container(
          constraints: new BoxConstraints(
              minHeight: 50.0,
              maxHeight: 50.0,
            ),
          width: double.infinity,
          height: 50.0,
          child: ElevatedButton.icon(
            label: Text('Twitter', style: TextStyle(fontSize: 25)),
            icon: Icon(FontAwesomeIcons.twitter, size: 30),
            onPressed: () {
              launch('https://twitter.com/castdrian');
            },
          ),
        ),
        SizedBox(height: 10),
        Container(
          constraints: new BoxConstraints(
              minHeight: 50.0,
              maxHeight: 50.0,
            ),
          width: double.infinity,
          height: 50.0,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(onPrimary: Colors.white, primary: Color(0xFFEB459E)),
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
        SizedBox(height: 10),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: main.infoAd.size.width.toDouble(),
            height: main.infoAd.size.height.toDouble(),
            child: AdWidget(ad: main.infoAd),
        ) 
        ),
      ])
    );
  }
}
