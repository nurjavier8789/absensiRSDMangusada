import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../conn/api.dart';

String nama = "-";
String jabat = "-";

String masuk = "-";
String keluar = "-";
String ket = "-";

getNama() async {
  final prefs = await SharedPreferences.getInstance();

  nama = prefs.get("user").toString();
  jabat = prefs.get("tempat_tugas").toString();
}

getLastAbsen() async {
  api Api = new api();
  final prefs = await SharedPreferences.getInstance();

  final String uri = Api.lastAbsenApi + "?kode=${prefs.get("pin")}";

  var resultAbsen = await http.get(Uri.parse(uri));

  if (resultAbsen.statusCode == HttpStatus.ok) {
    List<dynamic> lastabsen = jsonDecode(resultAbsen.body);

    if (lastabsen[0]['jam_masuk'] == null) {
      prefs.setString("masuk", "-");
    } else {
      prefs.setString("masuk", lastabsen[0]['jam_masuk']);
    }

    if (lastabsen[0]['jam_pulang'] == null) {
      prefs.setString("plg", "-");
    } else {
      prefs.setString("plg", lastabsen[0]['jam_pulang']);
    }

    prefs.setString("ket", lastabsen[0]['ket']);
  }

  masuk = prefs.get("masuk").toString();
  keluar = prefs.get("plg").toString();
  ket = prefs.get("ket").toString();
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  Color loginButton = Color.fromRGBO(111, 197, 96, 1.0);
  Timer? _timer;

  refreshPage() {
    _timer = new Timer(Duration(milliseconds: 500), () {
      setState(() {});
    });
  }

  @override
  void initState() {
    setState(() {
      getNama();
      getLastAbsen();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    refreshPage();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(116),
        child: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nama,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,),
                softWrap: true,
                maxLines: 3,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                jabat,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          toolbarHeight: 100,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: _buildTabContent(_currentIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            _logoutToLogin();
          }
        },
        selectedItemColor: Colors.red,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.today),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_arrow_right),
            label: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return Column(
          children: [
            SizedBox(
              height: 16,
            ),
            _timeBox(),
            SizedBox(
              height: 16,
            ),
            _information(context),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/absen');
              },
              child: Text("Absen"),
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(loginButton),
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
            )
          ],
        );
      default:
        return Container();
    }
  }

  Future<void> _logoutToLogin() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove("pin");
    prefs.remove("user");
    prefs.remove("hakakses");
    prefs.remove("masuk");
    prefs.remove("plg");
    prefs.remove("ket");

    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _timeBox() {
    DateTime now = DateTime.now();
    String bulan = DateFormat('MMMM').format(now);
    String tanggal = "${now.day} ${bulan} ${now.year}";
    String hari = DateFormat('EEEE').format(now);
    String jam =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return Container(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: CupertinoColors.white),
          width: 310,
          height: 100,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    jam,
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 25),
                    ),
                    Text(
                      hari,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      tanggal,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _information(BuildContext context) {
    DateTime now = DateTime.now();
    String bulan = DateFormat('MMMM').format(now);
    String tanggal = "${now.day} ${bulan} ${now.year}";

    Color infoBackgrounColor = Color.fromRGBO(152, 136, 136, 1.0);
    Color reloadBackgroundColors = Color.fromRGBO(193, 191, 192, 1.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: infoBackgrounColor,
      ),
      width: 310,
      height: 235,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: Text(
                tanggal,
                style: TextStyle(
                    fontSize: 18,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Divider(
            color: CupertinoColors.white,
            thickness: 1,
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Absensi Masuk : ",
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  masuk,
                  style: TextStyle(color: CupertinoColors.white),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Absensi Keluar : ",
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  keluar,
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Keterangan : ",
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  ket,
                  style: TextStyle(color: CupertinoColors.white),
                )
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  getNama();
                  getLastAbsen();
                });

                setState(() {});
              },
              child: Text("RELOAD"),
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(reloadBackgroundColors),
                foregroundColor: MaterialStatePropertyAll(CupertinoColors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
