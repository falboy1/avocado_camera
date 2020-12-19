import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:avocado_camera/header.dart';
import 'package:avocado_camera/cameraPreview.dart';

// 使用可能カメラのリスト
List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // 非同期処理 カメラ起動
  runApp(MyApp());
}

// アプリ全体
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: Header(),
        body: CameraWidget(
          cameras: cameras,
        ),
      ),
      theme: ThemeData(
        primaryColor: Colors.green,
        accentColor: Colors.greenAccent,
        buttonColor: Colors.black54,
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
