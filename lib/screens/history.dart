import 'package:analyse/helper/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert';

class History extends StatefulWidget {
  int? patientId;
  History({Key? key, this.patientId = -1}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final ScrollController _historyController = ScrollController();
  final ScrollController _testsController = ScrollController();
  final _history = [], _tests = [];
  int _selectedHistory = 0;
  final _multiResultAnalysis = [];

  Widget historyWidget() {
    return ListView.builder(
      controller: _historyController,
      itemCount: _history.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            setState(() {
              _selectedHistory = index;
              try {
                _tests.clear();
                if (_history.isNotEmpty) {
                  var json = jsonDecode(_history[_selectedHistory]['result']);
                  _tests.addAll(json);
                }
                // ignore: empty_catches
              } on Exception {}
            });
          },
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _selectedHistory == index ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: _selectedHistory == index ? 0 : 0.7,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Text(
                        "${_history[index]['name'] ?? ''} ${_history[index]['prename'] ?? ''}",
                        style: TextStyle(
                          fontSize: _selectedHistory == index ? 18 : 14,
                          fontWeight: _selectedHistory == index ? FontWeight.w600 : FontWeight.normal,
                          color: _selectedHistory == index ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        "${_history[index]['date'] ?? ''} ${_history[index]['time'] ?? ''}",
                        style: TextStyle(
                          fontSize: _selectedHistory == index ? 18 : 14,
                          fontWeight: _selectedHistory == index ? FontWeight.w600 : FontWeight.normal,
                          color: _selectedHistory == index ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  height: _selectedHistory == index ? 0 : 0.7,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget analysisWidget() {
    return SizedBox(
      width: 320,
      height: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        controller: _testsController,
        itemCount: _tests.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  _tests[index]['category'].toString().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 270,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _tests[index]['tests'].length ?? 0,
                  itemBuilder: (context, i) {
                    if (isEntry(_tests[index]['tests'][i]['test'])) {
                      //if (_tests[index]['tests'][i]['test'].contains('FNS')) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 15),
                            alignment: Alignment.centerLeft,
                            child: Text(_tests[index]['tests'][i]['test'] + ":"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: fnsResults(
                                fns: _tests[index]['tests'][i]['result'],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 15),
                              alignment: Alignment.centerLeft,
                              child: Text(_tests[index]['tests'][i]['test']),
                            ),
                          ),
                          Container(
                            width: 70,
                            height: 27,
                            alignment: Alignment.centerLeft,
                            child: Text("${_tests[index]['tests'][i]['result'].toString()} ${_tests[index]['tests'][i]['unit']}"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> fnsResults({fns}) {
    List<Widget> result = [];
    var json = jsonDecode(fns);
    for (int i = 0; i < json.length; i++) {
      result.add(
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 15),
                  alignment: Alignment.centerLeft,
                  child: Text(json[i]['test']),
                ),
              ),
              Container(
                width: 70,
                height: 27,
                alignment: Alignment.centerLeft,
                child: Text(
                  json[i]['result'].toString() + ' ' + json[i]['unit'].toString(),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return result;
  }

  bool isEntry(str) {
    for (var e in _multiResultAnalysis) {
      if (e['name'] == str) return true;
    }
    return false;
  }

  initDB() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase("data/database.sqlite3");
    String filter = widget.patientId != -1 ? 'WHERE patient.id=${widget.patientId}' : '';
    var result = await db.rawQuery(
      '''SELECT patient.name, patient.prename,patient.age, patientTest.result,patientTest.date, patientTest.time
        FROM patientTest
        INNER JOIN patient ON patientTest.patient_id=patient.id
        $filter
        ORDER by patientTest.id DESC''',
    );
    setState(() {
      _history.addAll(result);
      try {
        if (_history.isNotEmpty) {
          var json = jsonDecode(_history[_selectedHistory]['result']);
          _tests.addAll(json);
        }
        // ignore: empty_catches
      } on Exception {}
    });
    _multiResultAnalysis.addAll(await db.rawQuery("SELECT name from test WHERE isEntry = 1"));
    await db.close();
  }

  search(str) async {
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase("data/database.sqlite3");
    var result = await db.rawQuery('''
      SELECT patient.name , patient.prename,patientTest.result,patientTest.date, patientTest.time from patientTest 

INNER JOIN patient on patientTest.patient_id = patient.id 
WHERE instr(lower(name ||' '|| prename),lower("$str")) OR 
instr(lower(prename ||' '|| name),lower("$str"))
      ''');
    _history.clear();
    setState(() {
      _history.addAll(result);
    });
  }

  @override
  void initState() {
    super.initState();
    initDB();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            onChanged: (str) {
              search(str);
            },
            decoration: const InputDecoration(border: InputBorder.none, hintText: "Chercher"),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: const [
                              Expanded(
                                flex: 7,
                                child: Text('Patient(e)'),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text('Date'),
                              ),
                            ],
                          ),
                          const Divider(
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: 6,
                          bottom: 6,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: historyWidget(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                width: 270,
                padding: const EdgeInsets.only(
                  top: 6,
                  bottom: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 39,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Center(
                            child: Text('Résultat'),
                          ),
                          Divider(
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 320,
                        child: analysisWidget(),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                      width: 200,
                      child: TextButton(
                        onPressed: () async {
                          String result = await generate(
                            analysis: _tests,
                            name: _history[_selectedHistory]['name'],
                            prename: _history[_selectedHistory]['prename'],
                            age: _history[_selectedHistory]['age'].toString(),
                            date: "${_history[_selectedHistory]['date'] ?? ''} ${_history[_selectedHistory]['time'] ?? ''}",
                          );
                          if (result != 'true') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                result,
                                textAlign: TextAlign.center,
                              )),
                            );
                          }
                          // var x = await Printing.listPrinters();
                          // x = x;
                        },
                        child: const Text("Imprimer"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
