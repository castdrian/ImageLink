import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart' as main;

PurchaserInfo? _purchaserInfo;

class Info extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InfoState();
  }
}

class _InfoState extends State<Info> {
  @override
  void initState() {
    super.initState();
    fetchData();

    if (_purchaserInfo!.entitlements.all.isNotEmpty &&
        _purchaserInfo?.entitlements.all['Platinum']?.isActive != null) {
      main.appData.isPlatinum =
          _purchaserInfo?.entitlements.all['Platinum']?.isActive ?? false;
    } else {
      main.appData.isPlatinum = false;
    }
  }

  Future<void> fetchData() async {
    PurchaserInfo? purchaserInfo;
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _purchaserInfo = purchaserInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(children: <Widget>[
            SizedBox(height: 14),
            main.appData.isPlatinum
                ? Container(
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.shade900),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset('assets/icon/platinum.png',
                                  width: 50, height: 50),
                              Text('ImageLink Platinum™',
                                  style: TextStyle(fontSize: 20))
                            ]),
                        SizedBox(height: 5),
                        Card(
                            color: Colors.blue.shade900,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('You are a Platinum™ user!',
                                      style: TextStyle(fontSize: 20)),
                                ])),
                      ],
                    ))
                : Container(
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.shade900),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset('assets/icon/platinum.png',
                                  width: 50, height: 50),
                              Text('ImageLink Platinum™',
                                  style: TextStyle(fontSize: 20))
                            ]),
                        SizedBox(height: 5),
                        Card(
                            color: Colors.blue.shade900,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('Platinum Monthly™',
                                      style: TextStyle(fontSize: 20)),
                                  TextButton(
                                      child: Text('1.99 €'),
                                      onPressed: () async {
                                        try {
                                          final offerings =
                                              await Purchases.getOfferings();
                                          if (offerings.current != null &&
                                              offerings.current?.monthly !=
                                                  null) {
                                            final product =
                                                offerings.current?.monthly;
                                            PurchaserInfo purchaserInfo =
                                                await Purchases.purchasePackage(
                                                    product as Package);
                                            if (purchaserInfo.entitlements
                                                .all['Platinum']!.isActive) {
                                              Phoenix.rebirth(context);
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: 'An error occured.');
                                          }
                                        } on PlatformException catch (e) {
                                          print(e);
                                          Fluttertoast.showToast(
                                              msg: 'An error occured.');
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.green[800],
                                        primary: Colors.white,
                                      )),
                                ])),
                        Card(
                            color: Colors.blue.shade900,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('Platinum Annually™',
                                      style: TextStyle(fontSize: 20)),
                                  TextButton(
                                      child: Text('12.99 €'),
                                      onPressed: () async {
                                        try {
                                          final offerings =
                                              await Purchases.getOfferings();
                                          if (offerings.current != null &&
                                              offerings.current?.annual != null) {
                                            final product =
                                                offerings.current?.annual;
                                            PurchaserInfo purchaserInfo =
                                                await Purchases.purchasePackage(
                                                    product as Package);
                                            if (purchaserInfo.entitlements
                                                .all['Platinum']!.isActive) {
                                              Phoenix.rebirth(context);
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: 'An error occured.');
                                          }
                                        } on PlatformException catch (e) {
                                          print(e);
                                          Fluttertoast.showToast(
                                              msg: 'An error occured.');
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.green[800],
                                        primary: Colors.white,
                                      )),
                                ])),
                        Card(
                            color: Colors.blue.shade900,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('Platinum Lifetime™',
                                      style: TextStyle(fontSize: 20)),
                                  TextButton(
                                      child: Text('29.99 €'),
                                      onPressed: () async {
                                        try {
                                          final offerings =
                                              await Purchases.getOfferings();
                                          if (offerings.current != null &&
                                              offerings.current?.lifetime !=
                                                  null) {
                                            final product =
                                                offerings.current?.lifetime;
                                            PurchaserInfo purchaserInfo =
                                                await Purchases.purchasePackage(
                                                    product as Package);
                                            if (purchaserInfo.entitlements
                                                .all['Platinum']!.isActive) {
                                              Phoenix.rebirth(context);
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: 'An error occured.');
                                          }
                                        } on PlatformException catch (e) {
                                          print(e);
                                          Fluttertoast.showToast(
                                              msg: 'An error occured.');
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.green[800],
                                        primary: Colors.white,
                                      )),
                                ])),
                        TextButton(
                            child: Text('Restore purchase'),
                            onPressed: () async {
                              try {
                                Fluttertoast.showToast(
                                    msg: 'Restoring purchase...');
                                print('now trying to restore');
                                PurchaserInfo restoredInfo =
                                    await Purchases.restoreTransactions();
                                print('restore completed');
                                print(restoredInfo.toString());

                                main.appData.isPlatinum = restoredInfo
                                        .entitlements.all['Platinum']?.isActive ??
                                    false;

                                print(
                                    'is user platinum? ${main.appData.isPlatinum}');

                                if (main.appData.isPlatinum) {
                                  Fluttertoast.showToast(
                                      msg: 'Purchase restored!');
                                  Phoenix.rebirth(context);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Purchase restore failed!');
                                }
                              } on PlatformException catch (e) {
                                print('----xx-----');
                                var errorCode =
                                    PurchasesErrorHelper.getErrorCode(e);
                                if (errorCode ==
                                    PurchasesErrorCode.purchaseCancelledError) {
                                  print("User cancelled");
                                } else if (errorCode ==
                                    PurchasesErrorCode.purchaseNotAllowedError) {
                                  print("User not allowed to purchase");
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              primary: Colors.white,
                            )),
                      ],
                    )),
            Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: main.infoAd.size.width.toDouble(),
                  height: main.infoAd.size.height.toDouble(),
                  child: AdWidget(ad: main.infoAd),
                )),
          ]),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: buttonColumn(context)
        );
  }

  Column buttonColumn(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, 
    children: [
      FloatingActionButton.extended(
        onPressed: () {
          launch('https://discord.gg/MSDcP79cch');
        },
        label: const Text('Discord guild'),
        icon: const Icon(FontAwesomeIcons.discord),
        backgroundColor: Color(0xFF5865F2),
      ),
      SizedBox(height: 5),
      FloatingActionButton.extended(
        onPressed: () {
          launch('https://twitter.com/castdrian');
        },
        label: const Text('Twitter account'),
        icon: const Icon(FontAwesomeIcons.twitter),
        backgroundColor: Colors.blue,
      ),
      SizedBox(height: 5),
      FloatingActionButton.extended(
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
        label: const Text('Development credits'),
        icon: const Icon(FontAwesomeIcons.creditCard),
        backgroundColor: Color(0xFFEB459E),
      ),
    ]);
  }
}
