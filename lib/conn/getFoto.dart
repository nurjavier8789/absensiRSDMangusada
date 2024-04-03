import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'api.dart';

String urlPhoto = "";
String photoPath = "";

class getFoto {

  gettingFoto() async {
    Directory tempDir = await getTemporaryDirectory();
    final prefs = await SharedPreferences.getInstance();
    api Api = new api();

    final String uri = Api.dataFotoApi + "?kode=${prefs.get("pin")}";

    var result = await http.get(Uri.parse(uri));
    List<dynamic> fotoResult = jsonDecode(result.body);

    urlPhoto = fotoResult[0]["foto"];

    final file = File('${tempDir.path}/faceDB.jpg');
    var picture = await http.get(Uri.parse(urlPhoto));
    await file.writeAsBytes(picture.bodyBytes);

    photoPath = file.path;
  }

  getPathPhoto() {
    return photoPath;
  }
}
