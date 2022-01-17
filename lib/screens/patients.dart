import 'package:analyse/ui_elements/add_analysis_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Patients extends StatefulWidget {
  final Function? onTap;
  const Patients({Key? key, this.onTap}) : super(key: key);

  @override
  _PatientsState createState() => _PatientsState();
}

class _PatientsState extends State<Patients> with AutomaticKeepAliveClientMixin {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prenameController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthcontroller = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _gender = "Non Précisé";
  final _patientList = [];
  int _selectedPatient = 0, _operation = 1;
  bool _edit = false, _onEnd = false, _addAnalysis = false;
  bool _dayError = false, _monthError = false, _yearError = false;

  Widget patientList() {
    if (_patientList.isEmpty) {
      return Container();
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _patientList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                _selectedPatient = index;
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _selectedPatient == index ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: _selectedPatient == index ? 0 : 0.7,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          _patientList[index]['name'],
                          style: TextStyle(
                            fontSize: _selectedPatient == index ? 18 : 14,
                            fontWeight: _selectedPatient == index ? FontWeight.w600 : FontWeight.normal,
                            color: _selectedPatient == index ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          _patientList[index]['prename'],
                          style: TextStyle(
                            fontSize: _selectedPatient == index ? 18 : 14,
                            fontWeight: _selectedPatient == index ? FontWeight.w600 : FontWeight.normal,
                            color: _selectedPatient == index ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _patientList[index]['sex'],
                          style: TextStyle(
                            fontSize: _selectedPatient == index ? 18 : 14,
                            fontWeight: _selectedPatient == index ? FontWeight.w600 : FontWeight.normal,
                            color: _selectedPatient == index ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _patientList[index]['birth'],
                          style: TextStyle(
                            fontSize: _selectedPatient == index ? 18 : 14,
                            fontWeight: _selectedPatient == index ? FontWeight.w600 : FontWeight.normal,
                            color: _selectedPatient == index ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          _patientList[index]['age'].toString(),
                          style: TextStyle(
                            fontSize: _selectedPatient == index ? 18 : 14,
                            fontWeight: _selectedPatient == index ? FontWeight.w600 : FontWeight.normal,
                            color: _selectedPatient == index ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          _patientList[index]['phone'],
                          style: TextStyle(
                            fontSize: _selectedPatient == index ? 18 : 14,
                            fontWeight: _selectedPatient == index ? FontWeight.w600 : FontWeight.normal,
                            color: _selectedPatient == index ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 55,
                        child: Visibility(
                          visible: _selectedPatient == index,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  widget.onTap!(_patientList[index]['id']);
                                },
                                child: const Icon(Icons.view_list_rounded, size: 25),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _addAnalysis = !_addAnalysis;
                                  });
                                },
                                child: const Icon(Icons.note_add_outlined, size: 25),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    height: _selectedPatient == index ? 0 : 0.7,
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
  }

  Widget patientSearch() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: _textEditingController,
            onChanged: (str) async {
              await search(str: str);
            },
            decoration: const InputDecoration(border: InputBorder.none, hintText: "Chercher"),
          ),
        ),
        InkWell(
          onTap: () async {
            await search(str: _textEditingController.text);
          },
          child: const Icon(
            Icons.search,
            size: 35,
          ),
        ),
      ],
    );
  }

  Widget get editPatient {
    return Visibility(
      visible: _edit,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                child: TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: 'Nom',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Prénom"),
              const Spacer(),
              Container(
                alignment: Alignment.center,
                height: 30,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _prenameController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: 'Prénom',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Text("Sexe"),
              const Spacer(),
              Container(
                height: 30,
                width: 250,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _gender,
                  icon: const Icon(Icons.arrow_downward),
                  underline: Container(
                    height: 0,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _gender = newValue!;
                    });
                  },
                  items: <String>['Non Précisé', 'Homme', 'Femme', 'Nouveau née'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("Née"),
              const Spacer(),
              SizedBox(
                width: 250,
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 30,
                      width: 50,
                      decoration: BoxDecoration(
                        color: _dayError ? Colors.red[100]!.withOpacity(0.7) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _dayController,
                        onChanged: (str) {
                          try {
                            if (int.parse(str) > 31 || int.parse(str) < 1) {
                              setState(() {
                                _dayError = true;
                              });
                            } else {
                              setState(() {
                                _dayError = false;
                              });
                            }
                          } catch (_) {
                            setState(() {
                              _dayError = true;
                            });
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'(^\d*?\d*)')),
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: 'JJ',
                        ),
                      ),
                    ),
                    const Text("/"),
                    Container(
                      alignment: Alignment.center,
                      height: 30,
                      width: 50,
                      decoration: BoxDecoration(
                        color: _monthError ? Colors.red[100]!.withOpacity(0.7) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _monthcontroller,
                        onChanged: (str) {
                          try {
                            if (int.parse(str) > 12 || int.parse(str) < 1) {
                              setState(() {
                                _monthError = true;
                              });
                            } else {
                              setState(() {
                                _monthError = false;
                              });
                            }
                          } catch (_) {
                            setState(() {
                              _monthError = true;
                            });
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'(^\d*?\d*)')),
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: 'MM',
                        ),
                      ),
                    ),
                    const Text("/"),
                    Container(
                      alignment: Alignment.center,
                      height: 30,
                      width: 100,
                      decoration: BoxDecoration(
                        color: _yearError ? Colors.red[100]!.withOpacity(0.7) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _yearController,
                        onChanged: (str) {
                          DateTime now = DateTime.now();
                          try {
                            if (int.parse(str) > now.year || int.parse(str) < 1900) {
                              setState(() {
                                _yearError = true;
                              });
                            } else {
                              setState(() {
                                _yearError = false;
                              });
                            }
                          } catch (_) {
                            setState(() {
                              _yearError = true;
                            });
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'(^\d*?\d*)')),
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: 'AAAA',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Téléphone"),
              const Spacer(),
              Container(
                alignment: Alignment.center,
                height: 30,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _phoneController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'(^\d*?\d*)')),
                    LengthLimitingTextInputFormatter(14),
                  ],
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 350,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _edit = !_edit;
                      _dayError = false;
                      _monthError = false;
                      _yearError = false;
                    });
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
                    await patientQuery(operation: _operation).then((succeed) {
                      if (!succeed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orange,
                            content: Text(
                              "S'il vous plaît remplir"
                              "${_nameController.text == '' ? ' Nom' : ''}"
                              "${_prenameController.text == '' ? ' Prénom ' : ''}"
                              "${_yearController.text == '' ? ' An' : ''}"
                              "${_monthcontroller.text == '' ? ' Mois' : ''}"
                              "${_dayController.text == '' ? ' Jour' : ''}"
                              ".",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                    });
                  },
                  child: Text(
                    _operation == 0 ? "Mettre à jour" : "Ajouter",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> patientQuery({operation = 1}) async {
    if (_nameController.text == "") return false;
    if (_prenameController.text == "") return false;
    if (_dayController.text == "") return false;
    if (_monthcontroller.text == "") return false;
    if (_yearController.text == "") return false;
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase("data/database.sqlite3");
    if (operation == 1) {
      var patient = await db.rawQuery('''
        SELECT * FROM patient 
WHERE prename like "%${_prenameController.text}%" AND name like "%${_nameController.text}%" AND birth = "${_dayController.text + "/" + _monthcontroller.text + "/" + _yearController.text}" 
OR prename like "%${_prenameController.text}%" AND name like "%${_nameController.text}%" AND birth = "${_dayController.text + "/" + _monthcontroller.text + "/" + _yearController.text}"
        ''');
      if (patient.isEmpty) {
        String day = _dayController.text.length > 1 ? _dayController.text : '0' + _dayController.text;
        String month = _monthcontroller.text.length > 1 ? _monthcontroller.text : '0' + _monthcontroller.text;
        await db.insert("patient", <String, Object?>{
          'name': _nameController.text,
          'prename': _prenameController.text,
          'sex': _gender,
          'birth': day + '/' + month + '/' + _yearController.text,
          'age': getAge(),
          'phone': _phoneController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "${_prenameController.text + ' ' + _nameController.text} a été ajouté avec succès",
              textAlign: TextAlign.center,
            ),
          ),
        );
        setState(() {
          _addAnalysis = !_addAnalysis;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              "${_prenameController.text + ' ' + _nameController.text} existe déjà",
              textAlign: TextAlign.center,
            ),
          ),
        );
        var result = await db.rawQuery('SELECT* FROM patient ORDER by id DESC');
        _patientList.clear();
        setState(() {
          _patientList.addAll(result);
          _edit = !_edit;
          _selectedPatient = 0;
        });
        await db.close();
      }
    } else {
      await db.update(
        "patient",
        <String, Object?>{
          'name': _nameController.text,
          'prename': _prenameController.text,
          'sex': _gender,
          'birth': _dayController.text + '/' + _monthcontroller.text + '/' + _yearController.text,
          'age': getAge(),
          'phone': _phoneController.text,
        },
        where: 'id = ?',
        whereArgs: [_patientList[_selectedPatient]['id']],
      );
    }
    var result = await db.rawQuery('SELECT* FROM patient ORDER by id DESC');
    _patientList.clear();
    setState(() {
      _patientList.addAll(result);
      _edit = !_edit;
      _selectedPatient = 0;
    });
    await db.close();
    return true;
  }

  int getAge() {
    DateTime now = DateTime.now();
    try {
      return now.year - int.parse(_yearController.text);
    } catch (e) {
      return 0;
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Avertissement'),
          content: const Text("Si vous supprimez ce Patient, son historique d'analyse sera également supprimé.\n"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                sqfliteFfiInit();
                var databaseFactory = databaseFactoryFfi;
                var db = await databaseFactory.openDatabase("data/database.sqlite3");
                int delete = await db.delete(
                  'patient',
                  where: 'id=?',
                  whereArgs: [_patientList[_selectedPatient]['id']],
                );
                if (delete > 0) {
                  var result = await db.rawQuery('SELECT* FROM patient ORDER by id DESC');
                  setState(() {
                    _patientList.clear();
                    _selectedPatient = 0;
                    _patientList.addAll(result);
                  });
                }
                await db.close();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  clearData() {
    setState(() {
      _gender = "Non Précisé";
      _nameController.text = '';
      _prenameController.text = '';
      _phoneController.text = '';
      _dayController.text = '';
      _monthcontroller.text = '';
      _yearController.text = '';
    });
  }

  prefillData() {
    _nameController.text = _patientList[_selectedPatient]['name'];
    _prenameController.text = _patientList[_selectedPatient]['prename'];
    _phoneController.text = _patientList[_selectedPatient]['phone'];

    try {
      _gender = _patientList[_selectedPatient]['sex'];
    } catch (_) {
      _gender = 'Non Précisé';
    }
    try {
      _dayController.text = _patientList[_selectedPatient]['birth'].substring(0, 2);
      _monthcontroller.text = _patientList[_selectedPatient]['birth'].substring(3, 5);
      _yearController.text = _patientList[_selectedPatient]['birth'].substring(6);
    } catch (e) {
      _dayController.text = '';
      _monthcontroller.text = '';
      _yearController.text = '';
    }
    setState(() {});
  }

  search({str}) async {
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase("data/database.sqlite3");
    var result = await db.rawQuery(
      "SELECT * FROM patient "
      "WHERE instr(lower(name ||' '|| prename) || ' '|| birth, lower(\"$str\")) "
      "OR  instr(lower(prename ||' '|| name)  || ' '|| birth, lower(\"$str\"))",
    );
    setState(() {
      _patientList.clear();
      _patientList.addAll(result);
      _selectedPatient = 0;
    });
  }

  initDBLists() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase("data/database.sqlite3");
    var result = await db.rawQuery('SELECT* FROM patient ORDER by id DESC');
    setState(() {
      _patientList.addAll(result);
    });
    await db.close();
  }

  @override
  void initState() {
    super.initState();
    initDBLists();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: patientSearch())),
                const SizedBox(
                  width: 16,
                ),
                Container(
                  height: 60,
                  width: 180,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _operation = 1;
                            _edit = !_edit;
                            clearData();
                          });
                        },
                        child: const Icon(
                          Icons.add_circle_outline,
                          size: 40,
                          color: Color(0xff14cc38),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      InkWell(
                        onTap: () {
                          if (_patientList.isNotEmpty) {
                            setState(() {
                              _operation = 0;
                              _edit = !_edit;
                              prefillData();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.orange,
                                content: Text(
                                  "Veuillez d'abord sélectionner un patient pour le modifier",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Icon(Icons.edit, size: 40, color: Colors.blue),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      InkWell(
                        onTap: () {
                          if (_patientList.isNotEmpty) {
                            _showMyDialog();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.orange,
                                content: Text(
                                  "Veuillez d'abord sélectionner le patient à supprimer",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.delete,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
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
                        flex: 4,
                        child: Text('Nom'),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('Prénom'),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Sexe'),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Née'),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Age'),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('Téléphone'),
                      ),
                      SizedBox(width: 55, child: Text('Analyse')),
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
                child: patientList(),
              ),
            ),
          ],
        ),
        if (_addAnalysis)
          AddAnalysis(
            id: _patientList[_selectedPatient]['id'],
            name: _patientList[_selectedPatient]['name'],
            prename: _patientList[_selectedPatient]['prename'],
            age: _patientList[_selectedPatient]['age'].toString(),
            changeState: () {
              setState(() {
                _addAnalysis = false;
              });
            },
          ),
        Container(
          alignment: Alignment.center,
          height: _edit ? double.infinity : 0,
          width: _edit ? double.infinity : 0,
          color: Colors.grey.shade100.withOpacity(0.7),
          child: AnimatedContainer(
            onEnd: () {
              setState(() {
                _onEnd = !_onEnd;
              });
            },
            padding: const EdgeInsets.all(15),
            width: _edit ? 350 : 0,
            height: _edit ? 300 : 0,
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: _onEnd ? editPatient : Container(),
          ),
        ),
      ],
    );
  }
}
