import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert' as convert;

var _norms = {};
var _analysis = [];
var _extraPage = [];
TextStyle smallText = const TextStyle(fontSize: 9);
TextStyle headerText = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.bold,
  decoration: TextDecoration.underline,
);
TextStyle boldText = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.bold,
);
Future<String> generate({
  required analysis,
  required name,
  required prename,
  required age,
  required date,
}) async {
  try {
    await _normsInit();
    final logo = MemoryImage(
      File('assets/logo.png').readAsBytesSync(),
    );
    final pdf = Document();
    List<Widget> widgets = [];
    for (int index = 0; index < analysis.length; index++) {
      bool singlePage = false, pass = true;
      for (var t in analysis[index]['tests']) {
        if (!t['result'].contains('[{')) {
          pass = false;
        }
      }
      if (!pass) {
        widgets.add(
          analysisCategory(index: index, analysis: analysis),
        );
      }
      for (int i = 0; i < analysis[index]['tests'].length; i++) {
        if (!analysis[index]['tests'][i]['result'].contains('[{')) {
          widgets.add(
            analysisResult(index: index, analysis: analysis, i: i),
          );
        }
        if (analysis[index]['tests'][i]['result'].contains('[{') && analysis[index]['tests'][i]['result'].toString().split('{').length < 8) {
          widgets.add(
            await fnsWidget(
              doc: pdf,
              analysis: analysis,
              index: index,
              i: i,
              name: name,
              prename: prename,
              age: age,
              date: date,
              logo: logo,
              singlePage: true,
            ),
          );
        }
        if (analysis[index]['tests'][i]['result'].contains('[{') && analysis[index]['tests'][i]['result'].contains('}]') && !singlePage) {
          if (analysis[index]['tests'][i]['result'].toString().split('{').length >= 8) {
            _extraPage.add([index, i]);
          }
        }
      }
    }
    if (widgets.isNotEmpty) {
      pdf.addPage(
        MultiPage(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          maxPages: 50,
          pageFormat: PdfPageFormat.a4,
          header: (context) => header(logo: logo, name: name, prename: prename, age: age, date: date),
          footer: (_) => footer(),
          build: (Context context) => <Widget>[
            Wrap(
              children: List<Widget>.generate(widgets.length, (index) => widgets[index]),
            ),
          ],
        ),
      );
    }
    if (_extraPage.isNotEmpty) {
      for (int i = 0; i < _extraPage.length; i++) {
        await fnsWidget(
          doc: pdf,
          analysis: analysis,
          index: _extraPage[i][0],
          i: _extraPage[i][1],
          name: name,
          prename: prename,
          age: age,
          date: date,
          logo: logo,
        );
      }
    }
    final file = File('example.pdf');
    await file.writeAsBytes(await pdf.save());
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  } catch (e) {
    return e.toString();
  }
  return 'true';
}

Future<void> _normsInit() async {
  _norms.clear();
  _analysis.clear();
  _extraPage.clear();
  var databaseFactory = databaseFactoryFfi;
  var db = await databaseFactory.openDatabase("data/database.sqlite3");
  _analysis.addAll(await db.query('test'));
  for (var r in _analysis) {
    if (r['isEntry'] == 1) {
      _norms[r['name']] = Text('');
    } else {
      _norms[r['name']] = normWidget(norm: convert.jsonDecode(r['norm']));
    }
  }
  await db.close();
}

Column normWidget({norm}) {
  List<Widget> listText = [];
  for (int i = 0; i < norm.length; i++) {
    String dash = norm[i]['normMin'] != '' && norm[i]['normMax'] != '' ? ' - ' : '';
    listText.add(
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            "${norm[i]['norm']}${norm[i]['norm'] == '' ? '' : ' : '}${norm[i]['normMin']}$dash${norm[i]['normMax']}",
            style: smallText,
          )),
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: listText,
  );
}

fnsWidget({doc, analysis, index, i, logo, name, prename, age, date, singlePage = false}) async {
  var fnsResult = convert.jsonDecode(analysis[index]['tests'][i]['result']);
  var fnsNorm = [];
  var databaseFactory = databaseFactoryFfi;
  var db = await databaseFactory.openDatabase("data/database.sqlite3");
  var result = await db.rawQuery(
    "SELECT * FROM test where name = \"${analysis[index]['tests'][i]['test']}\"",
  );
  fnsNorm.addAll(convert.jsonDecode(result[0]['norm'].toString()));

  List<Widget> rows = [];
  if (!singlePage) {
    rows.add(header(logo: logo, name: name, prename: prename, age: age, date: date));
  }
  rows.add(
    Divider(),
  );
  rows.add(
    Container(
      height: 50,
      alignment: Alignment.center,
      child: Text(
        analysis[index]['tests'][i]['test'],
        style: const TextStyle(fontSize: 15),
      ),
    ),
  );
  rows.add(
    Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              'Examens',
              style: headerText,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Résultats',
              style: headerText,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Unité',
              style: headerText,
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              'Normes',
              style: headerText,
            ),
          ),
        ],
      ),
    ),
  );
  for (int i = 0; i < fnsNorm.length; i++) {
    String dash = fnsNorm[i]['normMin'].toString() != '' && fnsNorm[i]['normMax'].toString() != '' ? ' - ' : '';
    rows.add(
      Container(
        height: 15,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: Text(
                fnsNorm[i]['norm'].toString(),
                style: fnsNorm[i]['norm'] == 'WGB' ||
                        fnsNorm[i]['norm'] == 'HGB' ||
                        fnsNorm[i]['norm'] == 'HCT' ||
                        fnsNorm[i]['norm'] == 'PLT' ||
                        fnsNorm[i]['norm'].contains('Lign') ||
                        fnsNorm[i]['norm'] == 'Albumine' ||
                        fnsNorm[i]['norm'] == 'Protéines' ||
                        fnsNorm[i]['norm'] == 'Recherche du BK Culture' ||
                        fnsNorm[i]['norm'] == 'Bactériologie' ||
                        fnsNorm[i]['norm'] == 'Cytologie' ||
                        fnsNorm[i]['norm'] == 'Lymphocytes' ||
                        fnsNorm[i]['norm'] == 'Culture' ||
                        fnsNorm[i]['norm'] == 'BK Culture' ||
                        fnsNorm[i]['norm'] == 'Antibiogramme Entérobactéries' ||
                        fnsNorm[i]['norm'] == 'Examen direct' ||
                        fnsNorm[i]['norm'] == 'Chlamydiae et Mycoplasmes'
                    ? boldText
                    : smallText,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                fnsResult[i]['result'].toString(),
                style: fnsNorm[i]['norm'] == 'WGB' ||
                        fnsNorm[i]['norm'] == 'HGB' ||
                        fnsNorm[i]['norm'] == 'HCT' ||
                        fnsNorm[i]['norm'] == 'PLT' ||
                        fnsNorm[i]['norm'].contains('Lign') ||
                        fnsNorm[i]['norm'] == 'Albumine' ||
                        fnsNorm[i]['norm'] == 'Protéines' ||
                        fnsNorm[i]['norm'] == 'Recherche du BK Culture' ||
                        fnsNorm[i]['norm'] == 'Bactériologie' ||
                        fnsNorm[i]['norm'] == 'Cytologie' ||
                        fnsNorm[i]['norm'] == 'Lymphocytes' ||
                        fnsNorm[i]['norm'] == 'Culture' ||
                        fnsNorm[i]['norm'] == 'BK Culture' ||
                        fnsNorm[i]['norm'] == 'Antibiogramme Entérobactéries' ||
                        fnsNorm[i]['norm'] == 'Examen direct' ||
                        fnsNorm[i]['norm'] == 'Chlamydiae et Mycoplasmes'
                    ? boldText
                    : smallText,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                fnsNorm[i]['unit'].toString(),
                style: smallText,
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                fnsNorm[i]['normMin'].toString() + dash + fnsNorm[i]['normMax'].toString(),
                style: smallText,
              ),
            ),
          ],
        ),
      ),
    );
  }
  if (!singlePage) {
    rows.add(Spacer());
    rows.add(footer());
    doc.addPage(
      Page(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        build: (Context contect) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ),
    );
  }
  return Column(children: rows);
}

Widget analysisCategory({analysis, index}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Divider(thickness: 0.7),
      Center(
        child: Text(
          analysis[index]['category'].toString().toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Divider(thickness: 0.7),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Text(
                'Examens Demandés',
                style: headerText,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Résultats'.toString(),
                style: headerText,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Unité',
                style: headerText,
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                'Normes',
                style: headerText,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget analysisResult({analysis, index, i}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Text(
            analysis[index]['tests'][i]['test'],
            style: boldText,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            analysis[index]['tests'][i]['result'].contains('[{') ? 'Voir Fiche' : analysis[index]['tests'][i]['result'].toString(),
            style: smallText,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            analysis[index]['tests'][i]['result'].contains('[{') ? '' : analysis[index]['tests'][i]['unit'],
            style: smallText,
          ),
        ),
        Expanded(
          flex: 6,
          child: _norms[analysis[index]['tests'][i]['test']],
        ),
      ],
    ),
  );
}

Widget header({logo, date, name, prename, age}) {
  return Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 6),
            height: 90,
            width: 110,
            child: Image(logo, width: 110, height: 90),
          ),
          SizedBox(width: 50),
          Container(
            child: Column(
              children: [
                Text(
                  "CLINIQUE BELLE VUE ELYSA",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  "Clinique médico-chirurgicale - Cité Elysa ANNABA",
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  "Adresse : Angle route de Seraidi - Rue de l'Elysa Annaba",
                  style: const TextStyle(fontSize: 8),
                ),
                Text(
                  "TEL: 038 42 74 39 - Fax: 038 42 76 10 - Mob: 0560 39 16 62 / 0560 79 58 11",
                  style: const TextStyle(fontSize: 8),
                ),
                Text(
                  "Email: laboratoire.elysa@gmail.com Site Internet: www.cliniquebellevue-elysa.com",
                  style: const TextStyle(fontSize: 8),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
      Container(height: 1, color: PdfColors.black),
      SizedBox(height: 10),
      Container(
        child: Row(
          children: [
            Spacer(flex: 7),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(border: Border.all(width: 0.5)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text('Nom :', style: boldText)),
                          Expanded(flex: 3, child: Text(name, style: smallText)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text('Prénom :', style: boldText)),
                          Expanded(flex: 3, child: Text(prename, style: smallText)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text('Age :', style: boldText)),
                          Expanded(flex: 3, child: Text(age.toString() + ' Ans', style: smallText)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text('Prélavement du :', style: boldText)),
                          Expanded(flex: 3, child: Text(date, style: smallText)),
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
    ],
  );
}

Widget footer() {
  return Column(
    children: [
      Divider(height: 5),
      Text(
        "TEL: 038 42 74 39 - Fax: 038 42 76 10 - Mob: 0560 39 16 62 / 0560 79 58 11 Email: laboratoire.elysa@gmail.com",
        style: const TextStyle(fontSize: 9),
      ),
      SizedBox(height: 15),
    ],
  );
}
