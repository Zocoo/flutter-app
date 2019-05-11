class User {
  String name;

  String age;

  String address;

  String headUrl;

  String id;

  String phone;

  String autograph;

  String backImg;

  User(String name, String age, String address) {
    this.name = name;
    this.address = address;
    this.age = age;
  }

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    age = json['age'];
    address = json['address'];
    headUrl = json['headUrl'];
    id = json['id'].toString();
    phone = json['phone'];
    autograph = json['autograph'];
    backImg = json['backImg'];
  }
}
