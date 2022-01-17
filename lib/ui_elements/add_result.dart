import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AddResult extends StatefulWidget {
  final TextEditingController _textEditingController = TextEditingController();
  final List<TextEditingController> _fnsEditingController = [];
  final List<dynamic> _fns = [];

  var analysis;
  String get text {
    return _textEditingController.text;
  }

  List<TextEditingController> get fnsText {
    return _fnsEditingController;
  }

  Map get json {
    if (analysis['isEntry'] == 1) {
      List<dynamic> fns = [];
      for (int i = 0; i < _fnsEditingController.length; i++) {
        fns.add({
          'test': _fns[i]['norm'],
          'result': _fnsEditingController[i].text,
          'unit': (convert.jsonDecode(analysis['norm']))[i]['unit'],
        });
      }
      return {
        'result': convert.jsonEncode(fns),
        'test': analysis['name'],
        'unit': '',
      };
    }
    return {
      "result": _textEditingController.text,
      "test": analysis['name'],
      "unit": (convert.jsonDecode(analysis['norm']))[0]['unit'],
    };
  }

  AddResult({Key? key, required this.analysis}) : super(key: key);

  @override
  _AddResultState createState() => _AddResultState();
}

class _AddResultState extends State<AddResult> {
  Widget addResult({fnsIndex, controller}) {
    return Row(
      children: [
        Container(
          width: 205,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            widget._fns.isEmpty ? widget.analysis['name'] : widget._fns[fnsIndex]['norm'],
            style: TextStyle(fontSize: widget._fns.isEmpty ? 16 : 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        Container(
          alignment: Alignment.center,
          height: 30,
          width: 70,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: controller.text == '' ? Colors.red[100]!.withOpacity(0.7) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: FocusTraversalGroup(
            policy: WidgetOrderTraversalPolicy(),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Résultat",
                hintStyle: TextStyle(color: Colors.grey[400]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget addFNS() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 35,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            widget.analysis['name'],
            style: const TextStyle(fontSize: 16),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget._fns.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 350,
              height: 35,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Container(
                      height: 7,
                      width: 7,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Expanded(
                    child: addResult(
                      fnsIndex: index,
                      controller: widget._fnsEditingController[index],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  initFNS() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase("data/database.sqlite3");
    var result = await db.rawQuery("SELECT * FROM test where name =\"${widget.analysis['name']}\"");
    int index = 0;
    for (int i = 0; i < result.length; i++) {
      if (widget.analysis['name'] == result[i]['name']) index = i;
    }
    setState(() => widget._fns.addAll(convert.jsonDecode(result[index]['norm'].toString())));
    for (var _ in widget._fns) {
      widget._fnsEditingController.add(TextEditingController());
    }
    await db.close();
  }

  @override
  void initState() {
    super.initState();
    if (widget.analysis['isEntry'] == 1) initFNS();
  }

  @override
  Widget build(BuildContext context) {
    return widget._fns.isEmpty ? addResult(controller: widget._textEditingController) : addFNS();
  }
}
