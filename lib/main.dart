import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// カメラ情報リスト
List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // 非同期処理 カメラ起動
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller; // CameraController：Flutterのcamera扱うクラス

  @override
  void initState() {
    super.initState();
    // カメラリストからカメラと画質を指定して初期化 (番号と画質の指定)
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {}); // 画面を反映させる
    });
  }

  @override
  void dispose() {
    // stateの解放
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller));
  }
}
