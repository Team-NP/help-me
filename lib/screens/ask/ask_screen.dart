import 'package:flutter/material.dart';
import 'package:help_me/constant/colors.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:help_me/screens/ask/ask_detail.dart';
import 'package:help_me/screens/ask/ask_submit.dart';
import 'package:help_me/util/load_data_from_document.dart';

String wonCurrency(int price) {
  return "${price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      )} 원";
}

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  String askJsonUrl = "lib/mock_data/ask.json";
  String usersJsonUrl = "lib/mock_data/users.json";
  List<dynamic> _askData = [];
  List<dynamic> _usersData = [];

  @override
  void initState() {
    super.initState();
    _loadData("ask.json", isAskData: true);
    _loadData("users.json", isAskData: false);
  }

  Future<void> _loadData(String fileName, {required bool isAskData}) async {
    try {
      final data = await loadDataFromDocument(fileName);
      setState(() {
        if (isAskData) {
          _askData = data;
        } else {
          _usersData = data;
        }
      });
    } catch (e) {
      print('error: $e');
    }
  }

  // user_id로 이름을 가져오는 함수
  String? getUserName(int userId) {
    final user = _usersData.firstWhere(
      (user) => user['user_id'] == userId,
      orElse: () => null,
    );
    return user?['name'];
  }

  // user_id 기준으로 ask 갯수 확인하는 함수
  Map<int, int> countUserData(List<dynamic> data) {
    final Map<int, int> askCount = {};
    for (var item in data) {
      final userId = item['user_id'];
      if (askCount.containsKey(userId)) {
        askCount[userId] = askCount[userId]! + 1;
      } else {
        askCount[userId] = 1;
      }
    }
    return askCount;
  }

  void addAskData(newData) {
    setState(() {
      _askData.add(newData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final askCount = countUserData(_askData);

    return Scaffold(
        backgroundColor: AppColors.white,
        body: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 17),
              child: SizedBox(
                width: double.infinity,
                //height: 20,
                child: Text(
                  '재능요청',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: _askData.length,
                  itemBuilder: (context, index) {
                    final item = _askData.reversed.toList()[index];
                    final userData = _usersData.firstWhere(
                      (user) => user['user_id'] == item['user_id'],
                      orElse: () => null,
                    );
                    final userName = getUserName(item['user_id']);
                    final userId = item['user_id'] as int?;
                    final numberOfAsk =
                        (userId != null) ? (askCount[userId] ?? 0) : 0;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AskDetail(
                                item: item,
                                userData: userData,
                                numberOfAsk: numberOfAsk),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        width: 362,
                        height: 110,
                        decoration: BoxDecoration(
                            border: index == _askData.length - 1
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                        color: AppColors.lightGray, width: 1))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 2),
                              Text(userName ?? '알 수 없는 사용자',
                                  style: TextStyle(
                                      fontSize: 14, color: AppColors.darkGray)),
                              SizedBox(height: 2),
                              Text("사례금 ${wonCurrency(item['price'])}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.darkGreen,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ]),
        ),
        floatingActionButton: SizedBox(
          width: 99,
          height: 47,
          child: FloatingActionButton(
            heroTag: "2",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AskSubmit(addAskData: addAskData);
                // return GiveSubmit(submitGiveData: submitGiveData);  // 진용님 => give_submit에서 submitGiveData() 테스트시 사용하시면 됩니다
              }));
            },
            foregroundColor: AppColors.white,
            backgroundColor: AppColors.lightGreen,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Text(
              '+ 글쓰기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }
}
