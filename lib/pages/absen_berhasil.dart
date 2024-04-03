import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';

import '../conn/absenPUT.dart';

class AbsenBerhasil extends StatefulWidget {
  const AbsenBerhasil({super.key});

  @override
  State<AbsenBerhasil> createState() => _AbsenBerhasilState();
}

class _AbsenBerhasilState extends State<AbsenBerhasil> {
  bool servicestatus = false;
  bool haspermission = false;
  bool itsNull = true;
  late LocationPermission permission;
  late Position position;
  int jarak = 0;
  String long = "", lat = "", jarakFix = "", satuan = "";
  StreamSubscription<Position>? positionStream;

  Color topBar = Color.fromRGBO(22, 149, 0, 1.0);
  Color dataBackgroundColor = Color.fromRGBO(152, 136, 136, 1.0);
  Color refreshGPSButton = Color.fromRGBO(3, 217, 254, 1.0);
  Color batalButton = Color.fromRGBO(234, 0, 1, 1.0);

  @override
  void initState() {
    checkGps();
    super.initState();
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Upss..."),
                content: Text("Sepertinya aplikasi ini tidak ada akses ke GPS"),
                actions: [
                  TextButton(
                    onPressed: () async {
                      permission = await Geolocator.requestPermission();
                      Navigator.of(context).pop();
                    },
                    child: Text("Coba lagi"),
                  )
                ],
              );
            },
          );
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Upss..."),
                content: Text(
                    "Sepertinya aplikasi ini tidak ada akses ke GPS\nMungkin bisa cek pengaturan kemudian izinkan lokasi"),
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
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {});

        getLocation();
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Upss..."),
            content: Text(
                "Sepertinya GPS anda tidak aktif, silahkan aktifkan dan tekan OK"),
            actions: [
              TextButton(
                onPressed: () {
                  checkGps();
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              )
            ],
          );
        },
      );
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {});
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude);
    print(position.latitude);

    long = position.longitude.toString();
    lat = position.latitude.toString();
    jarak = Geolocator.distanceBetween(-8.578809847784864, 115.18276105113863,
            double.parse(lat), double.parse(long))
        .toInt();

    if (jarak.toInt() > 1000) {
      satuan = "KM";
      jarakFix = (jarak.toInt() / 1000).toString();
    } else {
      satuan = "M";
      jarakFix = jarak.toString();
    }

    setState(() {});

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
    );

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      print(position.longitude);
      print(position.latitude);
      print(jarakFix);

      long = position.longitude.toString();
      lat = position.latitude.toString();
      jarak = Geolocator.distanceBetween(-8.578809847784864, 115.18276105113863,
              double.parse(lat), double.parse(long))
          .toInt();

      if (jarak.toInt() > 1000) {
        satuan = "KM";
        jarakFix = (jarak.toInt() / 1000).toString();
      } else {
        satuan = "M";
        jarakFix = jarak.toString();
      }

      setState(() {
        itsNull = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle butonActivBatal = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(batalButton),
      foregroundColor: MaterialStatePropertyAll(CupertinoColors.white),
      minimumSize: MaterialStateProperty.all(
        Size(310, 60),
      ),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    ButtonStyle butonActiv = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(topBar),
      foregroundColor: MaterialStatePropertyAll(CupertinoColors.white),
      minimumSize: MaterialStateProperty.all(
        Size(310, 60),
      ),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    ButtonStyle butonInactiv = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(CupertinoColors.inactiveGray),
      foregroundColor: MaterialStatePropertyAll(CupertinoColors.systemGrey5),
      minimumSize: MaterialStateProperty.all(
        Size(310, 60),
      ),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Absensi Mangusada",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        backgroundColor: topBar,
        foregroundColor: CupertinoColors.white,
        leadingWidth: 101,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              "ONLINE",
              style: TextStyle(color: CupertinoColors.activeGreen),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.white,
                  border: Border.all(color: CupertinoColors.black, width: 2.0)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$jarakFix $satuan",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Lat.${lat.characters.take(7)}\nLng.${long.characters.take(7)}",
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 64,
            ),
            ElevatedButton(
                onPressed: itsNull
                    ? null
                    : () async {
                  absensi absen = absensi(lat: lat, lng: long);

                  await absen.absenMasuk();

                  if (absen.kode == 503) {
                    if (absen.pesan.contains("Jadwal absen tidak ditemukan")) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Tidak bisa melakukan presensi"),
                              content: Text(absen.pesan),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("OK"),
                                )
                              ],
                            );
                          }
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Tidak bisa melakukan presensi"),
                            content: Text("Sepertinya anda terlalu jauh dari kantor. Cobalah untuk mendekat sekitar 350 meter dari kantor dan coba lagi."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              )
                            ],
                          );
                        }
                      );
                    }
                  } else if (absen.kode == 502) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Tidak bisa melakukan presensi"),
                            content: Text("${absen.pesan}"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                                },
                                child: Text("OK"),
                              )
                            ],
                          );
                        });
                  } else if (absen.kode == 202) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Presensi berhasil!"),
                            content: Text("${absen.pesan}"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                                },
                                child: Text("OK"),
                              )
                            ],
                          );
                        });
                  } else if (absen.kode == 200) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Presensi berhasil!"),
                            content: Text("${absen.pesan}"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                                },
                                child: Text("OK"),
                              )
                            ],
                          );
                        });
                  } else {
                    if (mounted) {
                      positionStream?.cancel();
                      itsNull = true;
                    }
                    Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                  }
                },
                child: Text("ABSEN"),
                style: itsNull ? butonInactiv : butonActiv),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                checkGps();
              },
              child: Text("REFRESH GPS"),
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(refreshGPSButton),
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
              onPressed: itsNull
                  ? null
                  : () {
                Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
              },
              child: Text("KEMBALI KE BERANDA"),
              style: itsNull ? butonInactiv : butonActivBatal
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (mounted) {
      positionStream?.cancel();
    }
      itsNull = true;
    super.dispose();
  }
}
