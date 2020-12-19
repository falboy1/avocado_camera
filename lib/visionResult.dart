import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as imgLib;

// モデルの適用結果を映すウィジェット
// Scaffoldを持つページが作成される
class ResultPage extends StatelessWidget {
  // cameraPreview.dartから受け取る値
  final String imagePath; // 撮影された画像のパス
  const ResultPage({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width; // 端末の幅
    final double deviceHeight = MediaQuery.of(context).size.height; // 端末の高さ
    return Scaffold(
      appBar: AppBar(title: Text('Result')),
      body: VisionResult(imgPath: imagePath),
    );
  }
}

// 結果表示部分のウィジェット
class VisionResult extends StatefulWidget {
  // 親ウィジェットから受け取る値
  final String imgPath; // 画像パス
  VisionResult({this.imgPath});

  @override
  _VisionResultState createState() {
    return _VisionResultState();
  }
}

class _VisionResultState extends State<VisionResult> {
  imgLib.Image _croppedImage; // クロップされた画像

  // ウィジェットの作成時に撮影された画像をクロップ
  @override
  void initState() {
    super.initState();
    // imgLib.image型に画像を変換
    imgLib.Image image =
        imgLib.decodeImage(File(widget.imgPath).readAsBytesSync());
    // 画像をセンタークロップ
    _croppedImage = cropSquare(image);
  }

  @override
  Widget build(BuildContext context) {
    // クロップされた画像と結果
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // 分類に使用された画像
        Image.memory(
          imgLib.encodeJpg(_croppedImage),
        ),
        // 非同期でウィジェットを返す.　完了：結果のListView, 待機: テキスト
        FutureBuilder(
          future: predictImage(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Text(snapshot.data[index]["label"] +
                      ':' +
                      snapshot.data[index]["confidence"].toString());
                },
              );
            } else {
              return Text("読み込み中？");
            }
          },
        ),
      ],
    );
  }

  // TfLiteモデルのロード
  Future<String> loadModel() async {
    Tflite.close();
    return Tflite.loadModel(
      model: 'assets/converted_model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  // TfLiteモデルで画像の分類
  Future<dynamic> predictImage() async {
    await loadModel();
    // クロップ済み画像を224×224のバイナリ形式に変換
    Uint8List binaryImage = imageToByteListFloat32(_croppedImage, 224, 224);
    // 分類結果を取得
    dynamic output = await Tflite.runModelOnBinary(
      binary: binaryImage,
      threshold: 0.001,
    );

    return output;
  }

  // imgLib.imageをバイナリに変換する関数: TfLite推論のために使用
  Uint8List imageToByteListFloat32(imgLib.Image image, int width, int height) {
    // リサイズと複製
    imgLib.Image resizeImage =
        imgLib.copyResize(image, width: width, height: height);
    // Float32のバイトに変換
    var convertedBytes = Float32List(1 * width * height * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < width; i++) {
      for (var j = 0; j < height; j++) {
        var pixel = resizeImage.getPixel(i, j);
        buffer[pixelIndex++] = (imgLib.getRed(pixel)) / 255; // R値正規化
        buffer[pixelIndex++] = (imgLib.getGreen(pixel)) / 255; // G値正規化
        buffer[pixelIndex++] = (imgLib.getBlue(pixel)) / 255; // B値正規化
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  // 画像を正方形にセンタークロップ
  imgLib.Image cropSquare(imgLib.Image image) {
    var cropSize = min(image.width, image.height); // 幅と高さで小さいほうをクロップサイズとする
    int offsetX = (image.width - cropSize) ~/ 2;
    int offsetY = (image.height - cropSize) ~/ 2;
    // 画像をクロップ
    imgLib.Image croppedImage =
        imgLib.copyCrop(image, offsetX, offsetY, cropSize, cropSize);

    setState(() {
      _croppedImage = croppedImage;
    });

    return croppedImage;
  }
}
