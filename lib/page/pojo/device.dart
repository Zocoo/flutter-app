class Device {
  String id;

  String sn;

  String type;

  String remark;

  int lastHbAt;

  String userId;

  Device.fromJson(Map<String, dynamic> json) {
    this.id = json['id'].toString();
    this.userId = json['userId'];
    this.type = json['type'];
    this.remark = json['remark'];
    this.sn = json['sn'];
    this.lastHbAt = json['lastHbAt'];
  }
}
