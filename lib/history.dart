import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'main.dart' as main;
import 'util.dart';

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
    final list = GetStorage().read('history')?.cast<String>().toList();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: list?.length == 0
            ? Text('')
            : Column(children: [
              main.appData.isPlatinum ? Container() : Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: main.historyAd.size.width.toDouble(),
                  height: main.historyAd.size.height.toDouble(),
                  child: AdWidget(ad: main.historyAd),
              ) 
              ),
              Expanded(child: ListView.builder(
                itemCount: list?.length ?? 0,
                itemBuilder: (context, index) {
                  return
                    ListTile(
                    title: historyWidgets(index, list, context),
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: list[index]));
                      Fluttertoast.showToast(msg: 'URL copied!');
                    },
                  );
                }))
            ],));
  }
}
