import 'dart:convert';
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text;
  String text2;
  String urls;
  List<String> urlList = List();
  bool carregado = false;
  void takejson() async {
    if (text == null) {
      var data = await http.get(
          "http://itajuba.myscriptcase.com/scriptcase/devel/conf/grp/Procon/libraries/php/duvidas_detalhe.php?id=84");
      var jsonDuvidas = json.decode(data.body);
      text =
          html2md.convert(jsonDuvidas['duvidas'][0]['conteudo'], styleOptions: {
        'linkStyle': "referenced",
        "strongDelimiter": "**",
        'codeBlockStyle': '"fenced"',
        'linkReferenceStyle': "full"
      });
      setState(() {
        carregado = !carregado;
      });
    }
    RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> url = exp.allMatches(text);
    url.forEach((url) {
      urlList.add(text.substring(url.start, url.end));
    });
    print(urlList);
    var aux = text.split("[1]: http");
    text2 = aux[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("demo"),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Center(
                  child: Container(
                    color: Colors.blue,
                    width: 50,
                    height: 50,
                    child: FlatButton(onPressed: takejson, child: Container()),
                  ),
                ),
                carregado == false
                    ? Container()
                    : Container(
                        child: Column(
                          children: [
                            Text(text2),
                            ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: urlList.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  child:
                                      Text("[${index + 1}]: ${urlList[index]}"),
                                  onTap: () async {
                                    if (await canLaunch(urlList[index])) {
                                      print("aaa");
                                      await launch(urlList[index]);
                                    } else {
                                      print("bbb");
                                      throw 'Erro';
                                    }
                                  },
                                );
                              },
                            )
                          ],
                        ),
                      )
              ],
            ),
          ),
        ));
  }
}
