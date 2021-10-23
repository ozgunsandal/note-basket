import 'package:flutter/material.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/utils/database_helper.dart';

import 'models/notlar.dart';

class NotDetay extends StatefulWidget {
  String baslik;
  Not? duzenlenecekNot;

  NotDetay({Key? key, required this.baslik, this.duzenlenecekNot})
      : super(key: key);

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  late List<Kategori> tumKategoriler;
  late DatabaseHelper databaseHelper;
  int? kategoriID;
  int? secilenOncelik;
  late String notBaslik, notIcerik;
  static final _oncelik = ['Düşük', 'Orta', 'Yüksek'];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKategoriler = <Kategori>[];
    databaseHelper = DatabaseHelper();
    databaseHelper.kategorileriGetir().then((kategorileriIcerenMapListesi) {
      for (Map<String, dynamic> okunanMap in kategorileriIcerenMapListesi) {
        tumKategoriler.add(Kategori.fromMap(okunanMap));
      }
      if (widget.duzenlenecekNot != null) {
        kategoriID = widget.duzenlenecekNot!.kategoriID;
        secilenOncelik = widget.duzenlenecekNot!.notOncelik;
      } else {
        kategoriID = 1;
        secilenOncelik = 0;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.baslik),
      ),
      body: tumKategoriler.length <= 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Kategori :',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              items: kategoriItemleriOlustur(),
                              value: kategoriID,
                              onChanged: (secilenKategoriID) {
                                setState(() {
                                  kategoriID = secilenKategoriID!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.duzenlenecekNot != null
                            ? widget.duzenlenecekNot!.notBaslik
                            : '',
                        validator: (text) {
                          if (text!.length < 3) {
                            return 'En az 3 karakter olmalı!';
                          }
                        },
                        onSaved: (text) {
                          notBaslik = text!;
                        },
                        decoration: InputDecoration(
                          hintText: 'Not Başlığını Giriniz',
                          labelText: 'Başlık',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.duzenlenecekNot != null
                            ? widget.duzenlenecekNot!.notIcerik
                            : '',
                        onSaved: (text) {
                          notIcerik = text!;
                        },
                        maxLines: 4,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          hintText: 'Not İçeriğini Giriniz',
                          labelText: 'İçerik',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Öncelik :',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              items: _oncelik.map((dizidenGelenOncelikStringi) {
                                return DropdownMenuItem<int>(
                                  child: Text(
                                    dizidenGelenOncelikStringi,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  value: _oncelik
                                      .indexOf(dizidenGelenOncelikStringi),
                                );
                              }).toList(),
                              value: secilenOncelik,
                              onChanged: (secilenOncelikID) {
                                setState(() {
                                  secilenOncelik = secilenOncelikID!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Vazgeç'),
                          style: ElevatedButton.styleFrom(primary: Colors.grey),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              var suan = DateTime.now();
                              if (widget.duzenlenecekNot == null) {
                                databaseHelper
                                    .notEkle(
                                  Not(kategoriID!, notBaslik, notIcerik,
                                      suan.toString(), secilenOncelik!),
                                )
                                    .then((kaydedilenNotID) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Not Eklendi!'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  if (kaydedilenNotID != 0) {
                                    Navigator.pop(context);
                                  }
                                });
                              } else {
                                databaseHelper
                                    .notGuncelle(
                                  Not.withID(
                                      widget.duzenlenecekNot!.notID,
                                      kategoriID!,
                                      notBaslik,
                                      notIcerik,
                                      suan.toString(),
                                      secilenOncelik!),
                                )
                                    .then((guncellenenNotID) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Not Güncellendi!'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  if (guncellenenNotID != 0) {
                                    Navigator.pop(context);
                                  }
                                });
                              }
                            }
                          },
                          child: Text('Kaydet'),
                          style: ElevatedButton.styleFrom(primary: Colors.teal),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  List<DropdownMenuItem<int>> kategoriItemleriOlustur() {
    return tumKategoriler
        .map((kategori) => DropdownMenuItem<int>(
              value: kategori.kategoriID,
              child: Text(
                kategori.kategoriBaslik,
                style: TextStyle(fontSize: 20),
              ),
            ))
        .toList();
  }
}
