class Msg {
  String id;

  String content;

  String picUrls;

  int createAt;

  String userName;

  String userHeadUrl;

  int loveNumber;

  int commentNumber;

  String autograph;

  List<String> pics;

  String userId;

  Msg.fromJson(Map<String, dynamic> json) {
    this.userId = json['userId'].toString();
    this.id = json['id'].toString();
    this.content = json['content'];
    this.picUrls = json['picUrls'];
    this.userName = json['userName'];
    this.userHeadUrl = json['userHeadUrl'];
    this.createAt = json['createAt'];
    this.loveNumber = json['loveNumber'];
    this.commentNumber = json['commentNumber'];
    if(this.loveNumber == null){
      this.loveNumber = 0;
    }
    if(this.commentNumber == null){
      this.commentNumber = 0;
    }
    String s = json['userAutograph'];
    if (s != null && s.length > 15) {
      s = s.substring(0, 14);
    }
    if (s == null) {
      s = "未签名";
    }
    this.autograph = s;
    if (null != this.picUrls) {
      this.pics = this.picUrls.split(",");
    }
  }
}
