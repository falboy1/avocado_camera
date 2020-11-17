import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

const data = [
  'abc',
  'def',
  'ghi',
];

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

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

class VisionResult extends StatefulWidget {
  final String path; // mainから撮影時に取得
  VisionResult({this.path});

  @override
  _VisionResultState createState() {
    return _VisionResultState();
  }
}

class _VisionResultState extends State<VisionResult> {
  @override
  Widget build(BuildContext context) {
    // ビルダーでリストwidgetを返す
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
