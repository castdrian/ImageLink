import 'package:flutter/material.dart';
import 'placeholder.dart';

class Home extends StatefulWidget {
 @override
 State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    PlaceholderWidget(Colors.white),
    PlaceholderWidget(Colors.deepOrange),
    PlaceholderWidget(Colors.green)
  ];
 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text('ImageLink'),
     ),
     body: _children[_currentIndex],
     bottomNavigationBar: BottomNavigationBar(
       onTap: onTabTapped, // new
       currentIndex: _currentIndex, // new
       items: [
         BottomNavigationBarItem(
           icon: new Icon(Icons.home),
           label: 'Home',
         ),
         BottomNavigationBarItem(
           icon: new Icon(Icons.settings),
           label: 'Settings',
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.monetization_on_rounded),
           label: 'Donate'
         )
       ],
     ),
   );
 }
 void onTabTapped(int index) {
   setState(() {
     _currentIndex = index;
   });
 }
}