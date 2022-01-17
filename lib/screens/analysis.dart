import 'package:analyse/ui_elements/add_analysis_norm.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert' as convert;

class Analysis extends StatefulWidget {
  const Analysis({Key? key}) : super(key: key);

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> with AutomaticKeepAliveClientMixin {
  final ScrollController _catgoriesController = ScrollController();
  final ScrollController _analysisController = ScrollController();
  List<ScrollController> normsController = [];
  final _selectedAnalysisNorms = [];
  final _categoriesList = [], _analysisList = [];
  int _selectedCategory = 0, _selectedAnalysis = 0;
  bool _add = false, _edit = false;

  Widget analysisCategories() {
    if (_categoriesList.isEmpty) {
      return Container();
    } else {
      return ListView.builder(
        controller: _catgoriesController,
        itemCount: _categoriesList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              InkWell(
                onTap: () async {
                  setState(() {
                    _selectedCategory = index;
                    _selectedAnalysis = 0;
                    _analysisList.clear();
                    normsController.clear();
                  });
                  if (_categoriesList.isNotEmpty) {
                    var databaseFactory = databaseFactoryFfi;
                    var db = await databaseFactory.openDatabase("data/database.sqlite3");
                    var result = await db.rawQuery("SELECT * FROM TEST WHERE category LIKE \"%${_categoriesList[_selectedCategory]['name']}%\"");
                    _analysisList.addAll(result);
                    _selectedAnalysisNorms.clear();
                    try {
                      for (var element in _analysisList) {
                        _selectedAnalysisNorms.add(convert.jsonDecode(element['norm']));
                      }
                      // ignore: empty_catches
                    } on Exception {}
                    await db.close();
                  }
                  setState(() {});
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _selectedCategory == index ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _categoriesList[index]['name'].toString().toUpperCase(),
                    style: TextStyle(
                      color: _selectedCategory == index ? Colors.white : Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        },
      );
    }
  }

  Widget analysisList() {
    if (_analysisList.isEmpty) {
      return Container();
    } else {
      return ListView.builder(
        controller: _analysisController,
        itemCount: _analysisList.length,
        itemBuilder: (context, index) {
          normsController.add(ScrollController());
          return Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedAnalysis = index;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _selectedAnalysis == index ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          _analysisList[index]['name'],
                          style: TextStyle(
                            color: _selectedAnalysis == index ? Colors.white : Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          alignment: Alignment.center,
                          height: 45,
                          child: Scrollbar(
                            controller: normsController[index],
                            isAlwaysShown: true,
                            child: ListView.builder(
                                controller: normsController[index],
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: _selectedAnalysisNorms[index].length,
                                itemBuilder: (context, i) {
                                  String dash = _selectedAnalysisNorms[index][i]?['normMax'] == '' || _selectedAnalysisNorms[index][i]?['normMin'] == '' ? '' : '- ';
                                  return Center(
                                    child: Text(
                                      "${_selectedAnalysisNorms.isEmpty ? '' : _selectedAnalysisNorms[index][i]?['norm'] ?? ''} "
                                              "${_selectedAnalysisNorms.isEmpty ? '' : _selectedAnalysisNorms[index][i]?['normMin'] ?? ''} " +
                                          dash +
                                          "${_selectedAnalysisNorms.isEmpty ? '' : _selectedAnalysisNorms[index][i]?['normMax'] ?? ''} "
                                              "${i == _selectedAnalysisNorms[index].length - 1 ? '' : '|'} ",
                                      style: TextStyle(
                                        color: _selectedAnalysis == index ? Colors.white : Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        },
      );
    }
  }

  initDBLists() async {
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase("data/database.sqlite3");
    var result = await db.query('testCategory');
    _categoriesList.addAll(result);
    if (_categoriesList.isNotEmpty) {
      var result2 = await db.rawQuery("SELECT * FROM TEST WHERE category LIKE \"%${_categoriesList[_selectedCategory]['name']}%\"");
      _analysisList.addAll(result2);
      try {
        _selectedAnalysisNorms.clear();
        for (var element in _analysisList) {
          _selectedAnalysisNorms.add(convert.jsonDecode(element['norm']));
        }
        // ignore: empty_catches
      } on Exception {}
    }
    setState(() {});
    await db.close();
  }

  @override
  void initState() {
    super.initState();
    initDBLists();
    // _multiNormsController['norm'] = [];
    // _multiNormsController['normMin'] = [];
    // _multiNormsController['normMax'] = [];
    // _multiNormsController['unit'] = [];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: const Text("Catégorie",
                          style: TextStyle(
                            fontSize: 18,
                          )),
                    ),
                    Expanded(child: analysisCategories()),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 4,
                            child: Text("Analyse",
                                style: TextStyle(
                                  fontSize: 18,
                                )),
                          ),
                          Expanded(
                            flex: 5,
                            child: Center(
                              child: Text("Norme",
                                  style: TextStyle(
                                    fontSize: 18,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: analysisList()),
                  ],
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            width: 60,
            height: 130,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _edit = !_edit;
                    });
                  },
                  child: const Icon(Icons.edit, size: 40, color: Colors.white),
                ),
                const SizedBox(
                  height: 16,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      setState(() {
                        _add = !_add;
                      });
                    });
                  },
                  child: const Icon(
                    Icons.add_box_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_add)
          AddAnalysisNorm(
            categories: _categoriesList,
            onTap: () {
              setState(() {
                _add = false;
                _analysisList.clear();
                _categoriesList.clear();
              });
              initDBLists();
            },
          ),
        if (_edit)
          AddAnalysisNorm(
            categories: _categoriesList,
            edit: true,
            editList: _selectedAnalysisNorms[_selectedAnalysis],
            analysis: _analysisList[_selectedAnalysis],
            onTap: () {
              setState(() {
                _edit = false;
                _analysisList.clear();
                _categoriesList.clear();
              });
              initDBLists();
            },
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
