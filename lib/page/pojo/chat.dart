class Chat {
  String id;

  String userId;

  String friendId;

  String content;

  int type;

  int createAt;

  int readAt;

  String userName;

  String userHeadUrl;

  String myName;

  String myHeadUrl;

  Chat(){

  }

  Chat.fromJson(Map<String, dynamic> json) {
    userId = json['userId'].toString();
    friendId = json['friendId'].toString();
    content = json['content'];
    type = json['type'];
    id = json['id'].toString();
    createAt = json['createAt'];
    userName = json['userName'];
    userHeadUrl = json['userHeadUrl'];
    myName = json['myName'];
    myHeadUrl = json['myHeadUrl'];
  }
}
