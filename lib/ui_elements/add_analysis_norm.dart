import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AddAnalysisNorm extends StatefulWidget {
  final categories, edit, analysis, editList;
  Function onTap;
  AddAnalysisNorm({
    Key? key,
    this.categories,
    required this.onTap,
    this.edit = false,
    this.editList,
    this.analysis,
  }) : super(key: key);

  @override
  _AddAnalysisNormState createState() => _AddAnalysisNormState();
}

class _AddAnalysisNormState extends State<AddAnalysisNorm> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final Map<String, List<TextEditingController>> _normsController = {};
  final ScrollController _multiNormsScrollController = ScrollController();
  final _multiNormList = [];
  bool _isEntry = false;

  bool categoryExist() {
    for (var cat in widget.categories) {
      if (cat['name'] == _categoryController.text) return true;
    }
    return false;
  }

  Future<bool> validate() async {
    if (_categoryController.text == '' || _nameController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: SizedBox(
            height: 20,
            child: Center(
              child: Text(
                "Category and Analysis name must be filled.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
      return false;
    }
    // if (_normsController['normMin']!.length > 1) {
    //   for (int i = 1; i < _normsController['normMin']!.length; i++) {
    //     if (_normsController['normMin']![i].text == '' && _normsController['normMax']![i].text == '') {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           backgroundColor: Colors.red,
    //           content: SizedBox(
    //             height: 20,
    //             child: Center(
    //               child: Text(
    //                 "Please fill at least one value(Min or Max).",
    //                 style: TextStyle(color: Colors.white),
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //       return false;
    //     }
    //   }
    // }
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase("data/database.sqlite3");
    var result = await db.rawQuery(
      "SELECT * FROM test WHERE name=\"${_nameController.text}\"",
    );
    if (result.isNotEmpty && !widget.edit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: SizedBox(
            height: 20,
            child: Center(
              child: Text(
                "Analysis already exist",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
      return false;
    }
    try {
      if (_normsController['norm']!.isNotEmpty) {
        for (int i = 0; i < _normsController['norm']!.length; i++) {
          _multiNormList.add({
            'norm': _normsController['norm']![i].text,
            'normMin': _normsController['normMin']![i].text,
            'normMax': _normsController['normMax']![i].text,
            'unit': _normsController['unit']![i].text,
          });
        }
      }
    } catch (_) {
      return false;
    }
    if (!categoryExist()) {
      await db.insert('testCategory', <String, Object?>{'name': _categoryController.text});
    }
    if (widget.edit) {
      await db.update(
        'test',
        <String, Object?>{
          'name': _nameController.text,
          'norm': convert.jsonEncode(_multiNormList),
          'category': _categoryController.text,
          'isEntry': _isEntry ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [widget.analysis['id']],
      );
    } else {
      await db.insert('test', <String, Object?>{
        'name': _nameController.text,
        'norm': convert.jsonEncode(_multiNormList),
        'category': _categoryController.text,
        'isEntry': _isEntry ? 1 : 0,
      });
    }
    await db.close();
    return true;
  }

  Widget get multiNorm {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(right: 1.5, top: 4),
          width: 350,
          height: 200,
          child: Scrollbar(
            isAlwaysShown: true,
            controller: _multiNormsScrollController,
            child: ListView.builder(
              shrinkWrap: true,
              controller: _multiNormsScrollController,
              itemCount: _normsController['norm']!.length - 1,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 30,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FocusTraversalGroup(
                            policy: WidgetOrderTraversalPolicy(),
                            child: TextField(
                              controller: _normsController['norm']![index + 1],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "Norme",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 30,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FocusTraversalGroup(
                            policy: WidgetOrderTraversalPolicy(),
                            child: TextField(
                              controller: _normsController['normMin']![index + 1],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "Min",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 30,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FocusTraversalGroup(
                            policy: WidgetOrderTraversalPolicy(),
                            child: TextField(
                              controller: _normsController['normMax']![index + 1],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "Max",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 30,
                          width: 53,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FocusTraversalGroup(
                            policy: WidgetOrderTraversalPolicy(),
                            child: TextField(
                              controller: _normsController['unit']![index + 1],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "Unité",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _normsController['norm']!.removeAt(index + 1);
                                _normsController['normMin']!.removeAt(index + 1);
                                _normsController['normMax']!.removeAt(index + 1);
                                _normsController['unit']!.removeAt(index + 1);
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
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _normsController['norm']!.add(TextEditingController());
              _normsController['normMin']!.add(TextEditingController());
              _normsController['normMax']!.add(TextEditingController());
              _normsController['unit']!.add(TextEditingController());
            });
          },
          child: const Text("Ajouter une autre valeur"),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _normsController['norm'] = [];
    _normsController['normMin'] = [];
    _normsController['normMax'] = [];
    _normsController['unit'] = [];
    if (widget.edit && widget.editList.isNotEmpty) {
      _nameController.text = widget.analysis['name'];
      _categoryController.text = widget.analysis['category'];
      for (int i = 0; i < widget.editList.length; i++) {
        _normsController['norm']?.add(TextEditingController(
          text: widget.editList[i]['norm'].toString(),
        ));
        _normsController['normMin']?.add(TextEditingController(
          text: widget.editList[i]['normMin'].toString(),
        ));
        _normsController['normMax']?.add(TextEditingController(
          text: widget.editList[i]['normMax'].toString(),
        ));
        _normsController['unit']?.add(TextEditingController(
          text: widget.editList[i]['unit'].toString(),
        ));
      }
      _isEntry = widget.analysis['isEntry'] == 1 ? true : false;
    } else {
      _normsController['norm']?.add(TextEditingController());
      _normsController['normMin']?.add(TextEditingController());
      _normsController['normMax']?.add(TextEditingController());
      _normsController['unit']?.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100.withOpacity(0.7),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Container(
        height: 430,
        width: 350,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Text("Catégorie"),
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    height: 30,
                    child: Stack(
                      children: [
                        Container(
                          height: 30,
                          width: 250,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FocusTraversalGroup(
                            policy: WidgetOrderTraversalPolicy(),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_downward),
                              underline: Container(
                                height: 0,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _categoryController.text = newValue!;
                                });
                              },
                              items: widget.categories.map<DropdownMenuItem<String>>((var value) {
                                return DropdownMenuItem<String>(
                                  value: value['name'],
                                  child: Text(value['name']),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 30,
                          width: 216,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FocusTraversalGroup(
                            policy: WidgetOrderTraversalPolicy(),
                            child: TextField(
                              controller: _categoryController,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 5),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Text("Nom"),
                  const Spacer(),
                  Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FocusTraversalGroup(
                      policy: WidgetOrderTraversalPolicy(),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            if (_normsController['norm']!.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    const Text("Les valeurs sont saisissables ?"),
                    const Spacer(),
                    Checkbox(
                      value: _isEntry,
                      onChanged: (value) {
                        setState(() {
                          _isEntry = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FocusTraversalGroup(
                      policy: WidgetOrderTraversalPolicy(),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _normsController['norm']![0],
                        decoration: InputDecoration(
                          hintText: "Norme",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FocusTraversalGroup(
                      policy: WidgetOrderTraversalPolicy(),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _normsController['normMin']![0],
                        decoration: InputDecoration(
                          hintText: "Min",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FocusTraversalGroup(
                      policy: WidgetOrderTraversalPolicy(),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _normsController['normMax']![0],
                        decoration: InputDecoration(
                          hintText: "Max",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FocusTraversalGroup(
                      policy: WidgetOrderTraversalPolicy(),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _normsController['unit']![0],
                        decoration: InputDecoration(
                          hintText: "Unité",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: multiNorm,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    widget.onTap();
                  },
                  child: const Text(
                    "Annuler",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    bool done = await validate();
                    if (done) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: SizedBox(
                            height: 20,
                            child: Center(
                              child: Text(
                                "Analyse ajoutée avec succès",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                      widget.onTap();
                    }
                  },
                  child: Text(
                    widget.edit ? "Mettre à jour" : "Ajouter",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
