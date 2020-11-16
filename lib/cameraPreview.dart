import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

class CameraWidget extends StatefulWidget {
  @override
  _CameraWidgetState createState() {
    return _CameraWidgetState();
  }
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController _controller; // CameraController：Flutterのcamera扱うクラス
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // カメラリストからカメラと画質を指定して初期化 (番号と画質の指定)
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // stateの解放
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // プレビューのwidgetかプログレスバーのwidgetが返る
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
