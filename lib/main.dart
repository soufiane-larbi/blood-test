import 'package:analyse/screens/analysis.dart';
import 'package:analyse/screens/history.dart';
import 'package:analyse/screens/patients.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedMenu = 0;
  int? _patientId;
  List<Widget>? _views;

  Widget mainMenu({title, index, image}) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMenu = index;
        });
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: _selectedMenu == index ? Colors.blue : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              child: Image.asset(
                image,
                color: _selectedMenu == index ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: _selectedMenu == index ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _views = [
      Patients(
        onTap: (id) {
          setState(() {
            _patientId = id;
            _selectedMenu = 3;
          });
        },
      ),
      const Analysis(),
      History(
        key: UniqueKey(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belle Vue',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey[100],
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    mainMenu(title: "Patients", index: 0, image: "assets/Patients.png"),
                    const SizedBox(
                      height: 8,
                    ),
                    mainMenu(title: "Analyses", index: 1, image: "assets/Analysis.png"),
                    const SizedBox(height: 8),
                    mainMenu(title: "Historique", index: 2, image: "assets/Tests.png"),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(8),
                color: Colors.grey[100],
                child: _selectedMenu < 3
                    ? _views![_selectedMenu]
                    : History(
                        key: UniqueKey(),
                        patientId: _patientId,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
