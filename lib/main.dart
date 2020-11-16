import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// 使用可能カメラのリスト
List<CameraDescription> cameras;

// 色情報
final myMainColor = Colors.green;
final myAccentColor = Colors.deepPurpleAccent;
final avocadoSeedColor = Colors.brown;
final avocadoFleshColor = Colors.yellow;

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
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.more_horiz_outlined),
            onPressed: () {},
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {},
            ),
          ],
        ),
        body: CameraWidget(),
      ),
      theme: ThemeData(
        primaryColor: myMainColor,
        accentColor: myAccentColor,
      ),
    );
  }
}

// プレビューと撮影ボタンを持つウィジェット
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
          color: myMainColor,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            // Rowでボタンを中央に寄せて配置
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RaisedButton(
                  child: const Text(''),
                  color: avocadoSeedColor,
                  shape: const CircleBorder(
                    side: BorderSide(
                      color: Colors.amber,
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
