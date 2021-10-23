class Not {
  late int notID = 0;
  late int kategoriID;
  late String kategoriBaslik;
  late String notBaslik;
  late String notIcerik;
  late String notTarih;
  late int notOncelik;

  Not(this.kategoriID, this.notBaslik, this.notIcerik, this.notTarih,
      this.notOncelik); //Verileri yazarken kullan

  Not.withID(this.notID, this.kategoriID, this.notBaslik, this.notIcerik,
      this.notTarih, this.notOncelik); // Verileri okurken kullan

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    //map['notID'] = notID;
    map['kategoriID'] = kategoriID;
    map['notBaslik'] = notBaslik;
    map['notIcerik'] = notIcerik;
    map['notTarih'] = notTarih;
    map['notOncelik'] = notOncelik;
    return map;
  }

  Not.fromMap(Map<String, dynamic> map) {
    notID = map['notID'];
    kategoriID = map['kategoriID'];
    kategoriBaslik = map['kategoriBaslik'];
    notBaslik = map['notBaslik'];
    notIcerik = map['notIcerik'];
    notTarih = map['notTarih'];
    notOncelik = map['notOncelik'];
  }

  @override
  String toString() {
    return 'Not{notID: $notID, kategoriID: $kategoriID, notBaslik: $notBaslik, notIcerik: $notIcerik, notTarih: $notTarih, notOncelik: $notOncelik}';
  }
}
