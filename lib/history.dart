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
    final list = GetStorage().read('history').cast<String>().toList();
    print(list);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: list?.length == 0
            ? Text('')
            : ListView.builder(
                itemCount: list?.length ?? 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: historyWidgets(index, list!, context),
                    onLongPress: () => historyPreview(index, context, list),
                  );
                }));
  }
}
