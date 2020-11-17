import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:avocado_camera/header.dart';
import 'package:avocado_camera/displayResult.dart';

// 使用可能カメラのリスト
List<CameraDescription> cameras;

// 色情報
const myColors = {
  'mainColor': Colors.green,
  'accentColor': Colors.deepPurpleAccent,
  'avocadoSeedColor': Colors.brown,
  'avocadoFleshColor': Colors.yellow,
};

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
        body: CameraWidget(),
      ),
      theme: ThemeData(
        primaryColor: myColors['mainColor'],
        accentColor: myColors['accentColor'],
      ),
    );
  }
}

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
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<void>(
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
          ),
        ),
        Container(
          color: myColors['mainColor'],
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            // Rowでボタンを中央に寄せて配置
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RaisedButton(
                  child: Text(''),
                  color: myColors['avocadoSeedColor'],
                  shape: CircleBorder(
                    side: BorderSide(
                      color: myColors['avocadoFleshColor'],
                      width: 3,
                      style: BorderStyle.solid,
                    ),
                  ),
                  // ボタン押下時の動作：画像の撮影と保存を行う
                  onPressed: () async {
                    try {
                      // 念のため非同期処理をかける
                      await _initializeControllerFuture;
                      // 現在時刻でファイルパスを取得
                      final path = join(
                        (await getApplicationDocumentsDirectory()).path,
                        '${DateTime.now()}.png',
                      );
                      // 画像を保存
                      await _controller.takePicture(path);
                      // 画面遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DisplayPictureScreen(imagePath: path),
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
