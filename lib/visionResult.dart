import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// モデルの適用結果を映すウィジェット
// Scaffoldを持つページが作成される
class ResultPage extends StatelessWidget {
  // cameraPreview.dartから受け取る値
  final String imagePath; // 撮影された画像のパス
  const ResultPage({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Result')),
      body: Column(
        children: [
          Expanded(
            child: Image.file(File(imagePath)),
          ),
          Expanded(
            child: VisionResult(path: imagePath),
          ),
        ],
      ),
    );
  }
}

// 結果表示部分のウィジェット
class VisionResult extends StatefulWidget {
  // 親ウィジェットから受け取る値
  final String path; // 画像パス
  VisionResult({this.path});

  @override
  _VisionResultState createState() {
    return _VisionResultState();
  }
}

class _VisionResultState extends State<VisionResult> {
  @override
  Widget build(BuildContext context) {
    // 非同期でウィジェットを返す.　完了：結果のListView, 待機: テキスト
    return FutureBuilder(
      future: predictImage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return Text(snapshot.data[index].text +
                  '：' +
                  '${snapshot.data[index].confidence}');
            },
          );
        } else {
          return Text("読み込み中？");
        }
      },
    );
  }

  // ML kitのモデルを適用するメソッド
  Future<List<ImageLabel>> predictImage() async {
    var file = File(widget.path);
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(file);
    print(widget.path);
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler(
      ImageLabelerOptions(confidenceThreshold: 0.50),
    );

    // 結果のFutureを取得: 非同期
    final List<ImageLabel> labels = await labeler.processImage(visionImage);
    print(labels);
    return labels;
  }
}
