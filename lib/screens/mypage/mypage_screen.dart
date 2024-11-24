import 'package:flutter/material.dart';
import 'mypage_ask_list.dart';
import 'mypage_give_list.dart';
import 'data_service.dart';
import 'models.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  List<Give> giveList = []; // 데이터를 저장할 리스트
  List<Ask> askList = [];
  List<Users> usersList = [];
  List<GiveCartList> giveCartList = []; // 사용자가 담은 재능 목록
  List<Ask> userAskList = [];
  bool isLoading = true; // 로딩 상태를 관리(true : 로딩중, false : 로딩 완료)
  int userLoginId = 0; // 로그인한 사용자 ID
  int giveCount = 0; //사용자가 담은 재능 개수
  int askCount = 0; //사용자가 요청한 재능개수

  final DataService dataService = DataService();

  @override
  void initState() {
    super.initState();
    loadData(); // 데이터 로드
  }

  void decrementAskCount() {
    setState(() {
      if (askCount > 0) {
        askCount -= 1;
      }
    });
  }

  Future<void> loadData() async {
    try {
      final gives = await dataService.loadGives();
      final asks = await dataService.loadAsks();
      final users = await dataService.loadUsers();
      final giveCart =
          dataService.createGiveCartList(gives, users, userLoginId);

      setState(() {
        giveList = gives;
        askList = asks;
        usersList = users;
        giveCartList = giveCart;
        userAskList =
            askList.where((ask) => ask.userId == userLoginId).toList();

        giveCount = giveCart.length; // 재능 담기 개수 계산
        askCount = askList
            .where((ask) => ask.userId == userLoginId)
            .length; // 재능 요청 개수 계산

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('데이터 로드 에러: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      //로딩 중 보여주는 화면
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('마이페이지',
                        style: TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 366,
                      height: 90,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 1, color: Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                //userId를 이용하여 사용자의 이름 표시
                                '${dataService.getNameByUserId(usersList, userLoginId)}',
                                style: const TextStyle(
                                  color: Color(0xFF222222),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                )),
                            Row(
                              children: [
                                const Text('재능 담기',
                                    style: TextStyle(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    )),
                                Text(' $giveCount회 ',
                                    style: const TextStyle(
                                      color: Color(0xFF44D596),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    )),
                                Container(
                                    width: 1,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                        color: Color(0xFFD9D9D9))),
                                const Text(' 재능 요청',
                                    style: TextStyle(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    )),
                                Text(' $askCount회 ',
                                    style: const TextStyle(
                                      color: Color(0xFF44D596),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      '나의 거래',
                      style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MypageGiveList();
                        }));
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.list),
                          SizedBox(
                            width: 12,
                          ),
                          Text('내가 담은 재능',
                              style: TextStyle(
                                color: Color(0xFF222222),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MypageAskList(
                                  userLoginId: userLoginId // userLoginId 전달
                                  ),
                            ));
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.search),
                          SizedBox(
                            width: 12,
                          ),
                          Text('내가 요청한 재능',
                              style: TextStyle(
                                color: Color(0xFF222222),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              ));
  }
}
