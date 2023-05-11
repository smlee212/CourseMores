// import 'login_page.dart' as login;
import 'package:coursemores/auth/login_page.dart';
import 'package:coursemores/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import '../auth/sign_up.dart' as signup;
import 'package:animated_button_bar/animated_button_bar.dart';
import '../course_search/search.dart' as search;
import '../course_search/course_list.dart' as course;
import 'package:get/get.dart';
import '../main.dart' as main;
import '../controller/getx_controller.dart';
import 'profile_edit.dart' as profie_edit;
import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:convert';
import '../auth/auth_dio.dart';
import '../course_search/course_detail.dart' as detail;
import 'package:cached_network_image/cached_network_image.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

final myPageController = Get.put(MyPageInfo());

class _MyPageState extends State<MyPage> {
  List<Map<String, Object>> courseList = myPageController.myCourse;
  List<Map<String, Object>> reviewList = myPageController.myReview;
  var status = myPageController.status;
  @override
  void initState() {
    super.initState();
    fetchData(tokenController.accessToken);
    updateUserInfo();
    print('mypage data 가져오기');
    print(courseList);
  }

  Future<void> updateUserInfo() async {
    final dio = await authDio();
    final response = await dio.get('profile/5');
    print('update UserInfo!!');
    print(response);
    userInfoController.saveImageUrl(response.data['userInfo']['profileImage']);
  }

  Future<void> fetchData(aToken) async {
    final dio = await authDio();

    final response = await dio.get(
      'course/my/5',
    );
    print(response);
    List<dynamic> data = response.data['myCourseList'];
    print(data);
    // final list = (data as List<dynamic>).cast<Map<String, Object>>().toList();
    // courseList = list;
    // setState(() {
    //   courseList = data.map((item) => Map<String, Object>.from(item)).toList();
    // });
    myPageController.saveMyCourse(
        data.map((item) => Map<String, Object>.from(item)).toList());
    setState(() {
      courseList = myPageController.myCourse;
    });
    print(courseList);
    print(courseList.length);

    final response2 = await dio.get('comment/5',
        options: Options(
          headers: {'Authorization': 'Bearer $aToken'},
        ));
    print(response2);
    List<dynamic> data2 = response2.data['myCommentList'];
    // print(data);
    myPageController.saveMyReview(
        data2.map((item) => Map<String, Object>.from(item)).toList());
    setState(() {
      reviewList = myPageController.myReview;
    });
    print(reviewList);
  }

  buttonBar() {
    return SizedBox(
      width: 220,
      height: 60,
      child: AnimatedButtonBar(
          radius: 8.0,
          padding: EdgeInsets.all(8),
          backgroundColor: Colors.blueGrey.shade50,
          foregroundColor: Colors.blue,
          invertedSelection: true,
          children: [
            ButtonBarEntry(
                child: Text(
                  '내 코스',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  myPageController.statusToCourse();
                  setState(() {
                    status = myPageController.status;
                  });
                  print(status);
                }),
            ButtonBarEntry(
                child: Text(
                  '내 리뷰',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  myPageController.statusToReview();
                  setState(() {
                    status = myPageController.status;
                  });
                  print(status);
                }),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                profileBox(),
                // OutlinedButton(
                //     onPressed: () {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => const login.LoginPage()));
                //     },
                //     child: Text('로그인페이지')),
                buttonBar(),
                if (status == 'course')
                  (Text(
                    '내가 작성한 코스 : ${courseList.length} 개',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  )),
                if (status == 'review')
                  (Text(
                    '내가 작성한 리뷰 : ${reviewList.length} 개',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  )),
                if (status == 'course')
                  (Flexible(
                    child: MyCourse(),
                  )),
                if (status == 'review')
                  (Flexible(
                    child: MyCourse(),
                  ))
                // Container(
                //   margin: const EdgeInsets.only(
                //       left: 10, right: 10, top: 10, bottom: 5),
                //   padding: const EdgeInsets.all(10),
                //   decoration: const BoxDecoration(
                //       boxShadow: [
                //         BoxShadow(
                //             // color: Colors.white24,
                //             color: Color.fromARGB(255, 211, 211, 211),
                //             blurRadius: 10.0,
                //             spreadRadius: 1.0,
                //             offset: Offset(3, 3)),
                //       ],
                //       color: Color.fromARGB(255, 255, 255, 255),
                //       borderRadius: BorderRadius.all(Radius.circular(10))),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Expanded(
                //           child: SizedBox(
                //               width: 350,
                //               child: Row(
                //                 children: const [
                //                   search.ThumbnailImage(),
                //                   SizedBox(
                //                     width: 10,
                //                   ),
                //                   Expanded(
                //                     child: search.CourseSearchList(
                //                       // courseList: courseList,
                //                       index: 1,
                //                     ),
                //                   ),
                //                 ],
                //               )))
                //     ],
                //   ),
                // ),
              ])),
    ));
  }
}

class MyCourse extends StatelessWidget {
  MyCourse({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(221, 244, 244, 244),
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(8),
        itemCount: myPageController.myCourse.length,

        // index 말고 코스id로??
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              Get.to(() => detail.CourseDetail(index: index));
            },
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
              padding: EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(255, 211, 211, 211),
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                        offset: Offset(3, 3)),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: SizedBox(
                          width: 300,
                          child: Row(children: [
                            ThumbnailImage(index: index),
                            SizedBox(width: 10),
                            Expanded(child: MyCourseList(index: index)),
                          ]))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyCourseList extends StatelessWidget {
  MyCourseList({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${myPageController.myCourse[index]['title']}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: true,
                    ),
                  ),
                  SizedBox(width: 10),
                  if (myPageController.myCourse[index]["visited"] == true)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 107, 211, 66),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.check,
                                size: 14, color: Colors.white),
                          ),
                          Text("방문",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                          SizedBox(width: 7),
                        ],
                      ),
                    )
                ],
              ),
            ),
            if (myPageController.myCourse[index]["interest"] == true)
              Icon(Icons.bookmark, size: 24),
            if (myPageController.myCourse[index]["interest"] == false)
              Icon(Icons.bookmark_outline_rounded, size: 24),
          ],
        ),
        SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.map, size: 12, color: Colors.black54),
            SizedBox(width: 3),
            Text(
              "${myPageController.myCourse[index]["sido"].toString()} ${myPageController.myCourse[index]["gugun"].toString()}",
              style: TextStyle(fontSize: 12, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: true,
            ),
            SizedBox(width: 8),
            Icon(Icons.people, size: 12, color: Colors.black54),
            SizedBox(width: 3),
            Text(
              "${myPageController.myCourse[index]['people'].toString()}명",
              style: TextStyle(fontSize: 12, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: true,
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          "${myPageController.myCourse[index]['content']}",
          style: TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: true,
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${myPageController.myCourse[index]['locationName']}",
              style: TextStyle(fontSize: 12, color: Colors.black45),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: true,
            ),
            SizedBox(width: 8),
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, size: 14),
                    SizedBox(width: 3),
                    Text(myPageController.myCourse[index]["likeCount"]
                        .toString()),
                  ],
                ),
                SizedBox(width: 8),
                Row(
                  children: [
                    Icon(Icons.comment, size: 14),
                    SizedBox(width: 3),
                    Text(myPageController.myCourse[index]["commentCount"]
                        .toString()),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ThumbnailImage extends StatelessWidget {
  const ThumbnailImage({super.key, required this.index});

  final index;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: myPageController.myCourse[index]['image'].toString(),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
        height: 80,
        width: 80,
        fit: BoxFit.cover,
      ),
      // child: Image(
      //   image: AssetImage(courseList[widget.index]['image']),
      //   // image: AssetImage('assets/img1.jpg'),
      //   height: 80,
      //   width: 80,
      //   fit: BoxFit.cover,
      // ),
    );
  }
}

final userInfoController = Get.put(UserInfo());
profileBox() {
  final profileImageUrl;
  if (userInfoController.imageUrl.value == 'default') {
    profileImageUrl =
        'https://media.istockphoto.com/id/1316947194/vector/messenger-profile-icon-on-white-isolated-background-vector-illustration.jpg?s=612x612&w=0&k=20&c=1iQ926GXQTJkopoZAdYXgU17NCDJIRUzx6bhzgLm9ps=';
  } else {
    profileImageUrl = userInfoController.imageUrl.value;
  }
  return Container(
      height: 200.0,
      decoration: boxDeco(),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                    Color(0xff4dabf7),
                    Color(0xffda77f2),
                    Color(0xfff783ac),
                  ],
                ),
                borderRadius: BorderRadius.circular(120),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 15.0),
                  child: Text(
                    userInfoController.nickname.value,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0),
                  child: Text(
                    userInfoController.age.value.toString(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  child: Text(
                    userInfoController.gender.value,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              ModalBottom(),
            ],
          )
        ],
      ));
}

boxDeco() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 3,
        offset: const Offset(0, 2), // changes position of shadow
      ),
    ],
  );
}

class ButtonBar extends StatefulWidget {
  const ButtonBar({super.key});

  @override
  State<ButtonBar> createState() => _ButtonBarState();
}

class _ButtonBarState extends State<ButtonBar> {
  String choice = 'course';
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 60,
      child: AnimatedButtonBar(
          radius: 20.0,
          padding: EdgeInsets.all(8),
          backgroundColor: Colors.blueGrey.shade100,
          foregroundColor: Colors.blue,
          innerVerticalPadding: 0,
          children: [
            ButtonBarEntry(
                child: Text('내 코스'),
                onTap: () {
                  setState(() {
                    choice = 'course';
                  });
                }),
            ButtonBarEntry(
                child: Text('내 리뷰'),
                onTap: () {
                  setState(() {
                    choice = 'review';
                  });
                }),
          ]),
    );
  }
}

final authController = Get.put(AuthController());
final loginController = Get.put(LoginStatus());
final pageController = Get.put(PageNum());

class ModalBottom extends StatelessWidget {
  const ModalBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
          onPressed: () {
            showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                      height: 150,
                      color: Colors.transparent,
                      child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      print(userInfoController.profileImage);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const profie_edit
                                                      .ProfileEdit()));
                                    },
                                    child: const Center(
                                        child: Text(
                                      '내 정보 수정',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ))),
                              ),
                              Expanded(
                                child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      loginController.changeLoginStatus();
                                      // 로그아웃 메서드 쓰기..
                                      print('logout');
                                      Get.to(main.MyApp());
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  color: Colors.grey,
                                                  width: 1))),
                                      child: const Center(
                                          // color: Colors.yellow,
                                          child: Text(
                                        '로그아웃',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.red),
                                        textAlign: TextAlign.center,
                                      )),
                                    )),
                              ),
                              Expanded(
                                child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      loginController.changeLoginStatus();
                                      // 로그아웃 메서드 쓰기..
                                      print('회원탈퇴!');
                                      Get.to(main.MyApp());
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  color: Colors.grey,
                                                  width: 1))),
                                      child: const Center(
                                          // color: Colors.yellow,
                                          child: Text(
                                        '회원탈퇴',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.red),
                                        textAlign: TextAlign.center,
                                      )),
                                    )),
                              ),
                            ]),
                      ));
                });
          },
          icon: const Icon(Icons.settings)),
    );
  }
}