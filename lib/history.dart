import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
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
    final List<String> list = GetStorage().read('history') ?? [];
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: historyWidgets(
                    index, list),
                onLongPress: () => historyPreview(
                    index, context, list),
              );
            }));
  }
}
