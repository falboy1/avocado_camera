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
  CameraWidget({this.cameras});

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
    _controller =
        CameraController(widget.cameras[0], ResolutionPreset.veryHigh);
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
    final size = MediaQuery.of(context).size.width; // 端末の幅
    // カメラプレビューと撮影ボタンをColumnで配置
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ダミーWidget: 画像を上下中央に寄せるため
        Container(
          height: 5,
        ),
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return (Transform.scale(
                scale: 1.0,
                child: AspectRatio(
                  aspectRatio: 1.0 / 1.0,
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Container(
                        width: size,
                        height: size / _controller.value.aspectRatio,
                        child: Stack(
                          children: <Widget>[
                            CameraPreview(_controller),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        // ボタン部分.
        Padding(
          padding: const EdgeInsets.all(30.0),
          // Rowでボタンを中央に寄せて配置
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FittedBox(
                child: FlatButton(
                  child: Column(
                    children: [
                      Icon(
                        Icons.menu_book,
                        color: Colors.black54,
                      ),
                      Text(
                        "recipe",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  onPressed: () {},
                ),
              ),
              SizedBox(
                width: 60.0,
                height: 60.0,
                child: RaisedButton(
                  child: Text(''),
                  color: Colors.white,
                  shape: CircleBorder(
                    side: BorderSide(
                      color: Colors.black54,
                      width: 5,
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
              ),
              FittedBox(
                child: FlatButton(
                  child: Column(
                    children: [
                      Icon(
                        Icons.collections_outlined,
                        color: Colors.black54,
                      ),
                      Text(
                        "album",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
