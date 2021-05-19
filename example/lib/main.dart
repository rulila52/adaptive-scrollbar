import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(),
        initialRoute: '/',
        routes: {'/': (BuildContext context) => MyHomePage()});
  }
}

class MyHomePage extends StatelessWidget {
  final ScrollController horizontalScroll = ScrollController();
  final ScrollController verticalScroll = ScrollController();
  final double width = 20;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScrollbar(
        controller: verticalScroll,
        width: width,
        scrollToClickDelta: 75,
        scrollToClickFirstDelay: 200,
        scrollToClickOtherDelay: 50,
        bottomDecoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            shape: BoxShape.rectangle,
            color: Colors.white),
        child: Padding(
            padding: EdgeInsets.only(right: width),
            child: AdaptiveScrollbar(
                controller: horizontalScroll,
                width: width,
                position: ScrollbarPosition.bottom,
                bottomDecoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    shape: BoxShape.rectangle,
                    color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.only(bottom: width),
                  child: SingleChildScrollView(
                      controller: horizontalScroll,
                      scrollDirection: Axis.horizontal,
                      child: Container(
                          width: 3000,
                          child: Scaffold(
                            appBar: AppBar(
                                title: Text("Example",
                                    style: TextStyle(color: Colors.black)),
                                flexibleSpace: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                      Colors.blueAccent,
                                      Color.fromRGBO(208, 206, 255, 1)
                                    ])))),
                            body: Container(
                                color: Colors.lightBlueAccent,
                                child: ListView.builder(
                                    controller: verticalScroll,
                                    itemCount: 100,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        height: 30,
                                        color: Colors.lightBlueAccent,
                                        child: Text("Line " + index.toString()),
                                      );
                                    })),
                          ))),
                ))));
  }
}
