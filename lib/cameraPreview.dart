import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:avocado_camera/visionResult.dart';

// カメラプレビューと撮影ボタンを持つウィジェット
// メイン画面のbodyに代入される
class CameraWidget extends StatefulWidget {
  // mainから受け取る値
  final List<CameraDescription> cameras; // カメラリスト
  final Map<String, dynamic> myColors; // 基本色: ボタンの色等に使用
  CameraWidget({this.cameras, this.myColors});

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
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
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
    // カメラプレビューと撮影ボタンをColumnで配置
    return Column(
      children: [
        Expanded(
          // 非同期でウィジェットを返す. 完了: カメラプレビュー, 待機: プログレス
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
        // ボタン部分.
        Container(
          color: widget.myColors['mainColor'],
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            // Rowでボタンを中央に寄せて配置
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RaisedButton(
                  child: Text(''),
                  color: widget.myColors['avocadoSeedColor'],
                  shape: CircleBorder(
                    side: BorderSide(
                      color: widget.myColors['avocadoFleshColor'],
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
                          builder: (context) => ResultPage(imagePath: path),
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
