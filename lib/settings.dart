import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(children: <Widget>[
          SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Request URL:',
            ),
          ),
          SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              labelText: 'JSON Body (multipart/form-data):'
            ),
            maxLines: 10,
          ),
          SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selected SXCU:',
            ),
            readOnly: true,
            maxLines: null,
          ),
          SizedBox(height: 14),
          Container(
          width: double.infinity,
          height: 70.0,
          child: OutlinedButton.icon(
              label: Text('Import SXCU', style: TextStyle(fontSize: 25)),
              icon: Icon(Icons.upload_file, size: 30),
              onPressed: () {
              },
            ),
          ),
          SizedBox(height: 24),
          Container(
          width: double.infinity,
          height: 70.0,
          child: OutlinedButton.icon(
            label: Text('Save settings', style: TextStyle(fontSize: 25)),
            icon: Icon(Icons.save, size: 30),
            onPressed: () {
            },
          ),
        ),
      ])
    );
  }
}
