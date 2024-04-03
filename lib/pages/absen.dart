import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

String nama = "-";
String pin = "-";

getNama() async {
  final prefs = await SharedPreferences.getInstance();

  nama = prefs.get("user").toString();
  pin = prefs.get("pin").toString();
}

class AbsenPage extends StatefulWidget {
  const AbsenPage({super.key});

  @override
  State<AbsenPage> createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  showNama() async {
    getNama();

    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  Color topBar = Color.fromRGBO(22, 149, 0, 1.0);
  Color dataBackgroundColor = Color.fromRGBO(152, 136, 136, 1.0);

  String selectedValue = 'HDR';

  @override
  void initState() {
    showNama();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Absensi Mangusada",
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  getNama();
                });
              },
              icon: Icon(CupertinoIcons.refresh_thick),
            )
          ],
        ),
        backgroundColor: topBar,
        foregroundColor: CupertinoColors.white,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 16),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: dataBackgroundColor,
                  ),
                  height: 75,
                  width: 310,
                  padding: EdgeInsets.all(16),
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
                Text("""Pilih Keterangan Absensi Kemudian Klik 
                        Lanjut Absen"""),
                SizedBox(
                  height: 50,
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  width: 310,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      CupertinoColors.systemGrey4,
                      CupertinoColors.systemGrey4,
                      CupertinoColors.systemGrey4,
                      CupertinoColors.systemGrey4,
                      CupertinoColors.systemGrey5
                    ]),
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    elevation: 16,
                    underline: Container(),
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                        print(selectedValue);
                      });
                    },
                    items: <String>['HDR', 'TLD'].map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            width: 250,
                            height: 100,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(value),
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("statusAbs", selectedValue);

                    await Navigator.pushReplacementNamed(context, '/foto');

                  },
                  child: Text("LANJUT ABSEN"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(topBar),
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
            ),
          ),
        ),
      ),
    );
  }
}
