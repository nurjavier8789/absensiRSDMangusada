import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';

class absensi {
  absensi({required this.lat, required this.lng});

  final String lat;
  final String lng;

  int kode = 0;
  String pesan = "";

  absenMasuk() async {
    final prefs = await SharedPreferences.getInstance();
    api Api = new api();

    final String uri = Api.absenApi;

    var headers = {'Content-Type': 'application/json'};
    final bodi = jsonEncode({
      "kode": prefs.getString("pin"),
      "ket": prefs.getString("statusAbs"),
      "foto": null,
      "lat": lat,
      "lng": lng
    });

    var result = await http.put(Uri.parse(uri), headers: headers, body: bodi);
    Map<String, dynamic> absenResult = jsonDecode(result.body);

    kode = absenResult["kode"];
    pesan = absenResult["pesan"];

    print(result.body);
  }
}
