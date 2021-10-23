import 'dart:io';

import 'package:flutter/material.dart';
import 'package:not_sepeti/kategori_islemleri.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/models/notlar.dart';
import 'package:not_sepeti/not_detay.dart';
import 'package:not_sepeti/utils/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
            .copyWith(secondary: Colors.orange),
      ),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatefulWidget {
  NotListesi({Key? key}) : super(key: key);

  @override
  State<NotListesi> createState() => _NotListesiState();
}

class _NotListesiState extends State<NotListesi> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Not Sepeti'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                      leading: Icon(Icons.category),
                      title: Text('Kategoriler'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _kategorilerSayfasinaGit(context);
                      }),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              kategoriEkleDialog(context);
            },
            tooltip: 'Kategori Ekle',
            heroTag: 'KategoriEkle',
            child: Icon(Icons.add_circle),
            mini: true,
          ),
          FloatingActionButton(
            onPressed: () => _detaySayfasinaGit(context),
            tooltip: 'Not Ekle',
            heroTag: 'NotEkle',
            child: Icon(Icons.add),
          )
        ],
      ),
      body: Notlar(),
    );
  }

  Future<dynamic> kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String? yeniKategoriAdi;
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Ekle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: [
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (yeniDeger) {
                      yeniKategoriAdi = yeniDeger;
                    },
                    decoration: InputDecoration(
                      labelText: 'Kategori Adı',
                      border: OutlineInputBorder(),
                    ),
                    validator: (girilenKategoriAdi) {
                      if (girilenKategoriAdi!.length < 3) {
                        return 'En az 3 karakter girin!';
                      }
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Vazgeç'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        databaseHelper
                            .kategoriEkle(
                          Kategori(yeniKategoriAdi!),
                        )
                            .then((kategoriID) {
                          if (kategoriID > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              // Altta Toast tarzı bir uyarı göstermek için ******************
                              const SnackBar(
                                content: Text('Kategori Eklendi!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    child: Text('Kaydet'),
                  ),
                ],
              )
            ],
          );
        });
  }

  _detaySayfasinaGit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotDetay(
          baslik: 'Yeni Not',
        ),
      ),
    ).then((value) {
      setState(() {});
    });
  }

  _kategorilerSayfasinaGit(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Kategoriler()))
        .then((value) {
      setState(() {});
    });
  }
}

class Notlar extends StatefulWidget {
  const Notlar({Key? key}) : super(key: key);

  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  late List<Not> tumNotlar;
  late DatabaseHelper databaseHelper;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumNotlar = <Not>[];
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("GIRDI");
    return FutureBuilder(
      future: databaseHelper.notListesiniGetir(),
      builder: (context, AsyncSnapshot<List<Not>> snapShot) {
        if (snapShot.connectionState == ConnectionState.done) {
          tumNotlar = snapShot.data!;
          //sleep(Duration(seconds: 3));
          return ListView.builder(
            itemBuilder: (context, index) {
              return ExpansionTile(
                leading: _oncelikIconuAta(tumNotlar[index].notOncelik),
                title: Text(tumNotlar[index].notBaslik),
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Kategori',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                tumNotlar[index].kategoriBaslik,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Oluşturulma Tarihi',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                tumNotlar[index].notTarih.isNotEmpty
                                    ? databaseHelper.dateFormat(DateTime.parse(
                                        tumNotlar[index].notTarih))
                                    : 'Belirsiz',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'İçerik: \n' + tumNotlar[index].notIcerik,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        ButtonBar(
                          children: [
                            TextButton(
                                onPressed: () {
                                  _notSil(tumNotlar[index].notID);
                                },
                                child: Text('SİL')),
                            TextButton(
                                onPressed: () {
                                  _detaySayfasinaGitGuncelle(
                                      context, tumNotlar[index]);
                                },
                                child: Text(
                                  'GÜNCELLE',
                                  style: TextStyle(color: Colors.green),
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
            itemCount: tumNotlar.length,
          );
        } else {
          return Center(
            child: Text('Yükleniyor...'),
          );
        }
      },
    );
  }

  _detaySayfasinaGitGuncelle(BuildContext context, Not not) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotDetay(
          baslik: 'Notu Düzenle',
          duzenlenecekNot: not,
        ),
      ),
    ).then((value) {
      setState(() {});
    });
  }

  _oncelikIconuAta(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text(
            'AZ',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade100,
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text(
            'ORTA',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade200,
        );
        break;
      case 2:
        return CircleAvatar(
          child: Text(
            'ACİL',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade700,
        );
        break;
    }
  }

  void _notSil(int notID) {
    databaseHelper.notSil(notID).then((silinenID) {
      if (silinenID != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          // Altta Toast tarzı bir uyarı göstermek için ******************
          const SnackBar(
            content: Text('Not Silindi!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {});
      }
    });
  }
}
