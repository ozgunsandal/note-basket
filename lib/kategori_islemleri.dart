import 'package:flutter/material.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/utils/database_helper.dart';

class Kategoriler extends StatefulWidget {
  const Kategoriler({Key? key}) : super(key: key);

  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  late List<Kategori> tumKategoriler;
  late DatabaseHelper databaseHelper;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKategoriler = <Kategori>[];
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    kategoriListesiniGuncelle();

    return Scaffold(
      appBar: AppBar(
        title: Text('Kategoriler'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tumKategoriler[index].kategoriBaslik),
            trailing: InkWell(
              child: Icon(Icons.delete),
              onTap: () => _kategoriSil(tumKategoriler[index].kategoriID),
            ),
            leading: Icon(Icons.category),
            onTap: () => _kategoriGuncelle(tumKategoriler[index]),
          );
        },
        itemCount: tumKategoriler.length,
      ),
    );
  }

  void kategoriListesiniGuncelle() {
    databaseHelper.kategoriListesiniGetir().then((kategorileriIcerenList) {
      setState(() {
        tumKategoriler = kategorileriIcerenList;
      });
    });
  }

  _kategoriSil(int kategoriID) {
    if (kategoriID == 1) {
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Kategori Sil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kategoriyi sildiğinizde bununla ilgili tüm notlar da silinecektir.\nEmin misiniz?',
                ),
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Vazgeç',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        databaseHelper
                            .kategoriSil(kategoriID)
                            .then((silinenKategoriID) {
                          if (silinenKategoriID != 0) {
                            setState(() {
                              kategoriListesiniGuncelle();
                              Navigator.of(context).pop();
                            });
                          }
                        });
                      },
                      child: Text('Kategoriyi Sil'),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  _kategoriGuncelle(Kategori guncellenecekKategori) {
    kategoriGuncelleDialog(context, guncellenecekKategori);
  }

  Future<dynamic> kategoriGuncelleDialog(
      BuildContext context, Kategori guncellenecekKategori) {
    var formKey = GlobalKey<FormState>();
    String? guncellenecekKategoriAdi;
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Güncelle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: [
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: guncellenecekKategori.kategoriBaslik,
                    onSaved: (yeniDeger) {
                      guncellenecekKategoriAdi = yeniDeger;
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
                            .kategoriGuncelle(
                          Kategori.withID(guncellenecekKategori.kategoriID,
                              guncellenecekKategoriAdi!),
                        )
                            .then((kategoriID) {
                          if (kategoriID != 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              // Altta Toast tarzı bir uyarı göstermek için ******************
                              const SnackBar(
                                content: Text('Kategori Güncellendi!'),
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
}
