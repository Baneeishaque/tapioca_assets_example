import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tapioca/tapioca.dart';
import 'package:path/path.dart';

import 'video_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Tapioca Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text('Tapioca Example'),
          ),
          body: Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      child: Text("Load video from assets & Edit it"),
                      onPressed: () async {
                        print("clicked!");
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          final imageBitmap = (await rootBundle
                                  .load("assets/tapioca_drink.png"))
                              .buffer
                              .asUint8List();
                          final tapiocaBalls = [
                            TapiocaBall.filter(Filters.pink),
                            TapiocaBall.imageOverlay(imageBitmap, 300, 300),
                            TapiocaBall.textOverlay(
                                "text", 100, 10, 100, Color(0xffffc0cb)),
                          ];
                          var tempDir = await getTemporaryDirectory();
                          final path = '${tempDir.path}/result.mp4';

                          Directory directory =
                              await getApplicationDocumentsDirectory();
                          var dbPath = join(directory.path, "sample_video.mp4");
                          ByteData data =
                              await rootBundle.load("assets/sample_video.mp4");
                          List<int> bytes = data.buffer.asUint8List(
                              data.offsetInBytes, data.lengthInBytes);
                          await File(dbPath).writeAsBytes(bytes);

                          final cup = Cup(Content(dbPath), tapiocaBalls);
                          cup.suckUp(path).then((_) {
                            print("finish processing");
                            final currentState = navigatorKey.currentState;
                            if (currentState != null) {
                              currentState.push(
                                MaterialPageRoute(
                                    builder: (context) => VideoScreen(path)),
                              );
                            }
                            setState(() {
                              isLoading = false;
                            });
                          });
                        } on PlatformException {
                          print("error!!!!");
                        }
                      }))),
    );
  }
}
