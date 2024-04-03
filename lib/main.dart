import 'package:flutter/material.dart';

import 'package:absensekolah/pages/absen.dart';
import 'package:absensekolah/pages/absen_berhasil.dart';
import 'package:absensekolah/pages/foto_absen.dart';
import 'package:absensekolah/pages/home.dart';
import 'package:absensekolah/pages/login.dart';
import 'package:absensekolah/splash/splash.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/absen': (context) => AbsenPage(),
        '/foto': (context) => AbsenFoto(),
        '/absenBerhasil': (context) => AbsenBerhasil(),
      },
    ),
  );
}
