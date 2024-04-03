import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as imglib;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter_face_api/face_api.dart' as Regula;

import '../conn/getFoto.dart';


String nama = "-";
String pin = "-";
String instruk = "Scanning...";

var takenPicture;
var takenPicturePath;

int camNum = 1;
double persenCocok = -5;

bool faceUp = false;
bool faceDown = false;
bool faceCenter = false;
bool proses = false;

class AbsenFoto extends StatefulWidget {
  const AbsenFoto({super.key});

  @override
  State<AbsenFoto> createState() => _AbsenFotoState();
}

class _AbsenFotoState extends State<AbsenFoto> {
  List<CameraDescription>? cameras;
  CameraController? controller;

  var faceDetector;
  late List<Face> _faces;

  var image1 = Regula.MatchFacesImage();
  var image2 = Regula.MatchFacesImage();

  Color topBar = Color.fromRGBO(22, 149, 0, 1.0);
  Color dataBackgroundColor = Color.fromRGBO(152, 136, 136, 1.0);
  Color switchCameraButtonColor = Color.fromRGBO(3, 217, 254, 1.0);
  Color batalButton = Color.fromRGBO(234, 0, 1, 1.0);

  @override
  void initState() {
    _facesInit();
    camInit();
    getFoto().gettingFoto();
    super.initState();
  }

  @override
  void dispose() {
    faceDetector.close();
    controller?.stopImageStream();
    controller?.dispose();
    faceUp = false;
    faceDown = false;
    faceCenter = false;
    proses = false;
    instruk = "Scanning...";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      getNama();
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Absensi Mangusada",
        ),
        backgroundColor: topBar,
        foregroundColor: CupertinoColors.white,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 69),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 380,
                  width: 240,
                  child: showCam(),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  instruk,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: dataBackgroundColor,
                  ),
                  height: 100,
                  width: 310,
                  padding: EdgeInsets.only(top: 30, left: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          nama,
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                        Text(
                          pin,
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (camNum == 0) {
                      camNum = 1;
                      await updateController(cameras![camNum]);
                    } else if (camNum == 1) {
                      camNum = 0;
                      await updateController(cameras![camNum]);
                    }
                  },
                  child: Text("SWITCH CAMERA"),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(switchCameraButtonColor),
                    foregroundColor:
                        MaterialStatePropertyAll(CupertinoColors.white),
                    minimumSize: MaterialStateProperty.all(
                      Size(310, 60),
                    ),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (mounted) {
                      faceUp = false;
                      faceDown = false;
                      faceCenter = false;
                    }
                    Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                  },
                  child: Text("BATAL"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(batalButton),
                    foregroundColor:
                        MaterialStatePropertyAll(CupertinoColors.white),
                    minimumSize: MaterialStateProperty.all(
                      Size(310, 60),
                    ),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  camInit() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![1], ResolutionPreset.low, imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888, enableAudio: false);

      await controller!.initialize().then((_) async {
        if (!mounted) {
          return;
        }
        setState(() {});
        _detectFaces();
      });
    } else {
      print("NO any camera found");
    }
  }

  showCam() {
    if (controller == null) {
      return Center(child: Text("Loading Camera..."),);
    } else if (!controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator(),);
    } else {
      return Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: CameraPreview(controller!),
          ),
          Container(
            color: proses ? Color.fromRGBO(0, 0, 0, 0.50) : Color.fromRGBO(0, 0, 0, 0),
            // decoration: BoxDecoration(),
            alignment: Alignment.center,
            child: proses ? CircularProgressIndicator() : null,
          ),
        ],
      );
    }
  }

  _facesInit() async {
    final FaceDetectorOptions options = await FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast
    );
    
    faceDetector = FaceDetector(options: options);
  }

  updateController(CameraDescription description) {
    controller?.dispose().then((value) async {
      setState(() {});
      controller = CameraController(description, ResolutionPreset.low, imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888, enableAudio: false);
      controller?.initialize().then((_) {
        faceUp = false;
        faceDown = false;
        faceCenter = false;
        proses = false;
        instruk = "Scanning...";
        setState(() {});
        _detectFaces();
      });
    });
  }

  _detectFaces() async {
    controller!.startImageStream((image) async {
      final inputImage = InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: InputImageRotation.rotation270deg,
            format: Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888,
            bytesPerRow: image.planes[0].bytesPerRow
        ),
      );
      _faces = await faceDetector.processImage(inputImage);

      setState(() {
        if (_faces.isEmpty) {
          instruk = "Wajah tidak terdeteksi";
        } else {
          instruk = "Scanning...";
          if (faceUp == false) {
            instruk = "Hadap ke atas";
            _faces.single.headEulerAngleX! >= 20 ? faceUp = true : faceUp = false ;
          } else if (faceDown == false) {
            instruk = "Hadap ke bawah";
            _faces.single.headEulerAngleX! <= -20 ? faceDown = true : faceDown = false ;
          } else if (faceCenter == false) {
            instruk = "Lihat ke depan";
            (_faces.single.headEulerAngleY! >= -10 && _faces.single.headEulerAngleY! <= 10) && (_faces.single.headEulerAngleX! >= -10 && _faces.single.headEulerAngleX! <= 10)
                ? faceCenter = true : faceCenter = false ;
          } else {
            instruk = "Mohon Tunggu...\nTahan Posisi Anda";
            Future.delayed(Duration(seconds: 5));
            recordFace();
          }
        }
      });
    });
  }

  recordFace() async {
    final prefs = await SharedPreferences.getInstance();
    double angkaKesam = 0;

    if (faceUp == true && faceDown == true && faceCenter == true) {
      setState(() {
        proses = true;
        instruk = "Mohon Tunggu...\nTahan Posisi Anda\nWajah anda sedang direkam";
      });


      takenPicture = await controller?.takePicture();
      takenPicturePath = takenPicture.path;
      prefs.setString("imgPath", takenPicturePath);

      await controller?.stopImageStream();
      await controller?.pausePreview();

      imglib.Image? FileImage1 = imglib.decodeImage(File(takenPicturePath).readAsBytesSync());
      imglib.Image? FileImage2 = imglib.decodeImage(File(getFoto().getPathPhoto()).readAsBytesSync());

      List<int> image1Bytes = imglib.encodeJpg(FileImage1!);
      List<int> image2Bytes = imglib.encodeJpg(FileImage2!);

      image1.bitmap = base64Encode(image1Bytes);
      image1.imageType = Regula.ImageType.PRINTED;

      image2.bitmap = base64Encode(image2Bytes);
      image2.imageType = Regula.ImageType.PRINTED;

      if (image1.bitmap == null ||
          image1.bitmap == "" ||
          image2.bitmap == null ||
          image2.bitmap == "") return;

      var request = await Regula.MatchFacesRequest();
      request.images = [image1, image2];
      await Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) async {
        var response = await Regula.MatchFacesResponse.fromJson(json.decode(value));

        setState(() {
          angkaKesam = double.parse(jsonEncode(response?.results.first?.similarity)) * 100;
          persenCocok = angkaKesam;
        });
      });
      print('=====================>>>>       $persenCocok       <<<<=======================');

      if (persenCocok >= 95) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Wajah anda cocok dengan yang ada di server!"),
            showCloseIcon: true,
          )
        );

        setState(() {
          proses = false;
          faceUp = false;
          faceDown = false;
          faceCenter = false;
        });
        Navigator.pushReplacementNamed(context, "/absenBerhasil");
      } else if (persenCocok < 95) {
        proses = false;
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Wajah anda tidak cocok!"),
                content: Text('Wajah anda tidak cocok dengan yang ada di server!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        faceUp = false;
                        faceDown = false;
                        faceCenter = false;
                      });
                      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                    },
                    child: Text("Kembali"),
                  )
                ],
              );
            }
          );
        }
    } else {
      return;
    }
  }

  getNama() async {
    final prefs = await SharedPreferences.getInstance();

    nama = prefs.get("user").toString();
    pin = prefs.get("pin").toString();
  }
}
