class Kategori {
  late int kategoriID;
  late String kategoriBaslik;

  Kategori(
      this.kategoriBaslik); // Kategori eklerken kullan, çünkü id db tarafından otomatik oluşturuluyor.

  Kategori.withID(this.kategoriID,
      this.kategoriBaslik); // Kategorileri db'den okurken kullan.

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['kategoriBaslik'] = kategoriBaslik;
    return map;
  }

  Kategori.fromMap(Map<String, dynamic> map) {
    this.kategoriID = map['kategoriID'];
    this.kategoriBaslik = map['kategoriBaslik'];
  }

  @override
  String toString() {
    return 'Kategori{kategoriID: $kategoriID, kategoriBaslik: $kategoriBaslik}';
  }
}
