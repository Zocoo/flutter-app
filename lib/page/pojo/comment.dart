class Comment{
  String id;

  String userName;

  String userHeadUrl;

  String content;

  int createAt;

  int loveNumber;

  int commentNumber;

  int userId;

  Comment.fromJson(Map<String, dynamic> json) {
    this.id = json['id'].toString();
    this.userId = json['userId'];
    this.content = json['content'];
    this.userName = json['userName'];
    this.userHeadUrl = json['userHeadUrl'];
    this.createAt = json['createAt'];
    this.loveNumber = json['loveNumber'];
    this.commentNumber = json['commentNumber'];
  }
}