import 'package:analyse/helper/pdf_generator.dart';
import 'package:analyse/ui_elements/add_result.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert' as convert;

class AddAnalysis extends StatefulWidget {
  AddAnalysis({Key? key, required this.id, required this.name, required this.prename, required this.age, this.changeState}) : super(key: key);
  int id;
  String name, prename, age;
  Function? changeState;

  @override
  _AddAnalysisState createState() => _AddAnalysisState();
}

class _AddAnalysisState extends State<AddAnalysis> {
  final ScrollController _categoryController = ScrollController();
  final ScrollController _analyseController = ScrollController();
  final ScrollController _resultController = ScrollController();
  final _categoriesList = [], _analysisResult = [];
  final Map<String, List<AddResult>> _chosenAnalysis = {};
  final Map<String, TextEditingController> _result = {};
  final _analysisList = {};
  var _selectedCategory = 0;
  List<UniqueKey> _resultKeys = [];
  final TextEditingController _textEditingController = TextEditingController();

  Widget analysisList({list, selected, onTap, controller}) {
    if (list.isEmpty) return Container();
    return ListView.builder(
      controller: controller,
      itemCount: list.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            onTap(index);
          },
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected == index ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              list[index]['name'],
              style: TextStyle(
                color: selected == index ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget results() {
    List<Widget> columns = [];
    for (int index = 0; index < _chosenAnalysis.length; index++) {
      columns.add(
        _chosenAnalysis[_chosenAnalysis.keys.elementAt(index)]!.isEmpty
            ? Container()
            : Column(
                children: [
                  const Divider(),
                  Text(
                    _chosenAnalysis.keys.elementAt(index),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _chosenAnalysis[_chosenAnalysis.keys.elementAt(index)]!.length,
                      itemBuilder: (context, i) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 300,
                              child: _chosenAnalysis[_chosenAnalysis.keys.elementAt(index)]![i],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0, top: 10),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _chosenAnalysis[_chosenAnalysis.keys.elementAt(index)]!.removeAt(i);
                                  });
                                },
                                child: const Icon(
                                  Icons.remove_circle_sharp,
                                  color: Colors.red,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
      );
    }
    return Scrollbar(controller: _resultController, isAlwaysShown: true, child: SingleChildScrollView(controller: _resultController, child: Column(children: columns)));
    return ListView.builder(
      shrinkWrap: true,
      controller: _resultController,
      itemCount: _chosenAnalysis.length,
      itemBuilder: (BuildContext context, int index) {
        if (_chosenAnalysis[_chosenAnalysis.keys.elementAt(index)]!.isEmpty) {
          return Container();
        }
        return Column(
          children: [
            const Divider(),
            Text(
              _chosenAnalysis.keys.elementAt(index),
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _chosenAnalysis[_chosenAnalysis.keys.elementAt(index)]!.length,
                itemBuilder: (context, i) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 260,
                        child: _chosenAnalysis[_chosenAnalysis.keys.elementAt(index)]![i],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, top: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _chosenAnalysis[_chosenAnalysis.keys.elementAt(index)]!.removeAt(i);
                            });
                          },
                          child: const Icon(
                            Icons.remove_circle_sharp,
                            color: Colors.red,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  search(str) async {
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase("data/database.sqlite3");
    var result = await db.rawQuery(
      '''SELECT * FROM test WHERE name like "%$str%" AND category = "${_categoriesList[_selectedCategory]['name']}"''',
    );
    _analysisList[_categoriesList[_selectedCategory]['name']] = result;
    setState(() {});
    await db.close();
  }

  initDB() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase("data/database.sqlite3");
    var result = await db.query('testCategory');
    _categoriesList.addAll(result);
    if (_categoriesList.isNotEmpty) {
      for (int i = 0; i < _categoriesList.length; i++) {
        _analysisList[_categoriesList[i]['name']] = await db.rawQuery("SELECT * FROM TEST WHERE category LIKE \"%${_categoriesList[i]['name']}%\"");
        _chosenAnalysis[_categoriesList[i]['name']] = [];
      }
    }
    _categoriesList.map((e) => e.toString().toUpperCase());
    setState(() {});
    await db.close();
  }

  @override
  void initState() {
    super.initState();
    initDB();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100]!.withOpacity(0.8),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: AnimatedContainer(
        width: 820,
        height: 550,
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            widget.changeState!();
                          },
                          child: Container(
                            width: 80,
                            alignment: Alignment.center,
                            // margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Annuler",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${widget.name} ${widget.prename}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            int result = -1;
                            var json = [];
                            DateTime now = DateTime.now();
                            String day = now.day > 9 ? now.day.toString() : '0' + now.day.toString();
                            String month = now.month > 9 ? now.month.toString() : '0' + now.month.toString();
                            String hour = now.hour > 9 ? now.hour.toString() : '0' + now.hour.toString();
                            String minute = now.minute > 9 ? now.minute.toString() : '0' + now.minute.toString();
                            try {
                              var tests = [];
                              for (int i = 0; i < _chosenAnalysis.length; i++) {
                                if (_chosenAnalysis[_chosenAnalysis.keys.elementAt(i)]!.isNotEmpty) {
                                  tests = [];
                                  for (int j = 0; j < _chosenAnalysis[_chosenAnalysis.keys.elementAt(i)]!.length; j++) {
                                    tests.add(_chosenAnalysis[_chosenAnalysis.keys.elementAt(i)]![j].json);
                                  }
                                  json.add({
                                    'category': _chosenAnalysis.keys.elementAt(i),
                                    'tests': tests,
                                  });
                                }
                              }

                              sqfliteFfiInit();
                              var databaseFactory = databaseFactoryFfi;
                              var db = await databaseFactory.openDatabase("data/database.sqlite3");
                              result = await db.insert(
                                'patientTest',
                                {
                                  'patient_id': widget.id,
                                  'result': convert.jsonEncode(json),
                                  'date': day + '/' + month + '/' + now.year.toString(),
                                  'time': hour + ':' + minute,
                                },
                              );
                              await db.close();
                            } finally {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: result > 0 ? Colors.green : Colors.orange,
                                  content: Text(
                                    result > 0 ? "Analyse ajoutée avec succès" : "Erreur lors de l'ajout de l'analyse",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                              if (result > 0) {
                                _showMyDialog(
                                  context,
                                  analysis: json,
                                  name: widget.name,
                                  prename: widget.prename,
                                  age: widget.age,
                                  date: day + '/' + month + '/' + now.year.toString() + ' ' + hour + ':' + minute,
                                );
                              }
                            }
                            widget.changeState!();
                          },
                          child: Container(
                            width: 80,
                            alignment: Alignment.center,
                            // margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Ajouter",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: analysisList(
                              list: _categoriesList,
                              selected: _selectedCategory,
                              onTap: (index) {
                                setState(() {
                                  _selectedCategory = index;
                                  _textEditingController.text = '';
                                });
                                search('');
                              },
                              controller: _categoryController,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 1,
                            height: double.infinity,
                            color: Colors.grey[200],
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: TextField(
                                    controller: _textEditingController,
                                    onChanged: (str) {
                                      search(str);
                                    },
                                    decoration: const InputDecoration(border: InputBorder.none, hintText: "Chercher"),
                                  ),
                                ),
                                Expanded(
                                  child: _analysisList.isNotEmpty
                                      ? Scrollbar(
                                          controller: _analyseController,
                                          isAlwaysShown: true,
                                          child: analysisList(
                                            list: _analysisList[_categoriesList[_selectedCategory]['name']],
                                            onTap: (index) {
                                              setState(() {
                                                var key = UniqueKey();
                                                var add = AddResult(
                                                  key: key,
                                                  analysis: _analysisList[_categoriesList[_selectedCategory]['name']][index],
                                                );
                                                _chosenAnalysis[_categoriesList[_selectedCategory]['name']]!.add(add);
                                                _textEditingController.text = '';
                                              });
                                              search('');
                                              setState(() {
                                                _resultController.jumpTo(
                                                  _resultController.position.maxScrollExtent,
                                                );
                                              });
                                            },
                                            controller: _analyseController,
                                          ),
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 340,
              height: double.infinity,
              padding: const EdgeInsets.only(
                left: 5,
                right: 5,
                top: 5,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: results(),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showMyDialog(context, {analysis, name, prename, age, date}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Voulez-vous imprimer maintenant'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          TextButton(
            child: const Text('Imprimer', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              try {
                generate(
                  analysis: analysis,
                  name: name,
                  prename: prename,
                  age: age,
                  date: date,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      'Errur d\'imprition! ' + e.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } finally {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
