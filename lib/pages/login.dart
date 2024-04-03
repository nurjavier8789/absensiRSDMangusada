import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:device_info_plus/device_info_plus.dart';

import '../conn/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final forming = GlobalKey<FormState>();

  TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  child: Image.asset('assets/mangusada_img.png',
                      width: 200, height: 200),
                ),
                SizedBox(height: 100),
                Text(
                  "Halaman Login",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                SizedBox(height: 50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PIN Absen:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Form(
                      key: forming,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        controller: _pinController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap Masukkan PIN Absen';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "****",
                          filled: true,
                          fillColor: CupertinoColors.systemGrey5,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            borderSide:
                                BorderSide(color: CupertinoColors.systemGrey3),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            borderSide:
                                BorderSide(color: CupertinoColors.systemGrey5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            borderSide:
                                BorderSide(color: CupertinoColors.systemRed),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          api Api = new api();

                          // Login
                          final String uri = Api.loginApi;
                          // String? deviceId = "";

                          // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                          // if (Platform.isIOS) {
                          //   IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
                          //   deviceId = iosInfo.identifierForVendor;
                          // } else if (Platform.isAndroid) {
                          //   AndroidDeviceInfo androidInfo =
                          //       await deviceInfo.androidInfo;
                          //   deviceId = androidInfo.id;
                          // } else if (Platform.isWindows) {
                          //   WindowsDeviceInfo winInfo =
                          //       await deviceInfo.windowsInfo;
                          //   deviceId = winInfo.deviceId;
                          // }

                          if (forming.currentState!.validate()) {
                            var headers = {'Content-Type': 'application/json'};
                            final bodi = jsonEncode({
                              "kode": _pinController.text
                              // "deviceid": deviceId,
                            });
                            var result = await http.post(Uri.parse(uri),
                                headers: headers, body: bodi);

                            if (result.statusCode == HttpStatus.ok) {
                              List<dynamic> user = jsonDecode(result.body);

                              if (user[0]['keterangan']
                                  .contains("Device Ini untuk Kode Karyawan")) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                            "PIN tidak cocok dengan device"),
                                        content: Text(
                                            'Mungkin device ini hanya bisa menggunakan PIN "${user[0]['kode']}"'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("OK"),
                                          )
                                        ],
                                      );
                                    });
                              } else if (user[0]['status'].contains("gagal")) {
                                print(
                                    "{{{                                          ${result.body}                                    }}}");
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("PIN Tidak Ditemukan"),
                                        content: Text(
                                            "Mohon Masukkan PIN Yang Benar"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("OK"),
                                          )
                                        ],
                                      );
                                    });
                              } else {
                                final prefs = await SharedPreferences.getInstance();

                                if (user[0]['tempat_tugas'] == null) {
                                  setState(() {
                                    prefs.setString("user", user[0]['nama_pegawai']);
                                    prefs.setString("tempat_tugas", user[0]['status_pegawai']);
                                    prefs.setString("pin", _pinController.text);
                                  });
                                } else {
                                  setState(() {
                                    prefs.setString("user", user[0]['nama_pegawai']);
                                    prefs.setString("tempat_tugas", user[0]['tempat_tugas']);
                                    prefs.setString("pin", _pinController.text);
                                  });
                                }

                                // GET data presensi
                                final String uriAbsen = Api.lastAbsenApi +
                                    "?kode=${prefs.get("pin")}";

                                var resultAbsen =
                                    await http.get(Uri.parse(uriAbsen));

                                if (resultAbsen.statusCode == HttpStatus.ok) {
                                  List<dynamic> lastabsen =
                                      jsonDecode(resultAbsen.body);

                                  setState(() {
                                    if (lastabsen.isNotEmpty) {
                                      if (lastabsen[0]['jam_masuk'] == null) {
                                        prefs.setString("masuk", "-");
                                      } else {
                                        prefs.setString(
                                            "masuk", lastabsen[0]['jam_masuk']);
                                      }

                                      if (lastabsen[0]['jam_pulang'] == null) {
                                        prefs.setString("plg", "-");
                                      } else {
                                        prefs.setString(
                                            "plg", lastabsen[0]['jam_pulang']);
                                      }

                                      prefs.setString(
                                          "ket", lastabsen[0]['ket']);
                                    } else {
                                      // Handle the case when lastabsen is empty
                                    }
                                  });

                                  await Navigator.pushReplacementNamed(
                                      context, '/home');
                                }
                              }
                            } else {
                              print(result.body);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("PIN Salah"),
                                    content: Text("Masukkan PIN Yang Benar"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      )
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                        child: Text("Login"),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.green),
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.white),
                          minimumSize: MaterialStateProperty.all(
                            Size(400, 60),
                          ),
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
