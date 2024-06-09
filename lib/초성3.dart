//초성 게임
//플레이 방법 초성 힌트를 보고 맞추면 정답, 틀리면 오답이고 제한시간이 되면 게임 종료
import 'dart:async'; // Timer 사용을 위해 필요
import 'dart:math'; // 랜덤 단어 선택을 위해 필요
import 'package:flutter/material.dart'; // Flutter 기본 패키지

void main() {
  runApp(MyApp());
}

// 앱의 기본 구조를 정의하는 MyApp 클래스
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WordGame(), // WordGame 위젯을 홈으로 설정
    );
  }
}

// 게임 화면을 정의하는 WordGame 클래스
class WordGame extends StatefulWidget {
  @override
  _WordGameState createState() => _WordGameState();
}

// 게임 로직과 UI를 관리하는 _WordGameState 클래스
class _WordGameState extends State<WordGame> {
  final List<String> words = [ // 단어 목록
    "사과", "포도", "과자", "학교", "시골", "우산", "바다", "가방", "공원",
    "지도", "나무", "도서", "달력", "시계", "창문", "바지", "의자", "전화",
    "사진", "밥상", "펭귄", "택시", "영화", "음악", "빵집", "식빵", "우유",
    "수건", "가위", "버스", "기차", "드론", "샤워", "사전", "식탁", "건물",
    "커피", "수박", "달걀", "김밥", "김치", "물병", "식물", "매미", "나비",
    "개미", "지갑", "손톱", "영상", "도구", "볼펜", "자석", "세수", "구두",
    "양말", "도마", "편지", "책상", "기름", "냉면", "의사", "경찰", "교실",
    "강당", "복도", "주방", "부엌", "마당", "정원", "전기", "전선", "수도",
    "전구", "미술"
  ];

  final int totalTime = 60; // 전체 게임 제한 시간 (초)
  final int scorePerWord = 10; // 맞춘 단어당 점수
  List<String> usedWords = []; // 사용된 단어 목록
  Timer? gameTimer; // 게임 타이머
  int remainingTime = 60; // 남은 시간
  List<int> scores = []; // 플레이어 점수 목록
  List<String> players = ["Player 1", "Player 2"]; // 플레이어 목록
  int currentPlayerIndex = 0; // 현재 플레이어 인덱스
  int currentWordIndex = 0; // 현재 단어 인덱스
  int currentScore = 0; // 현재 점수
  String currentWord = ""; // 현재 단어
  String hint = ""; // 힌트 (초성)

  @override
  void initState() {
    super.initState();
    startGame(); // 게임 시작
  }

  // 게임 시작 함수
  void startGame() {
    setState(() {
      remainingTime = totalTime; // 남은 시간 초기화
      scores = List.filled(players.length, 0); // 플레이어 점수 초기화
      usedWords = []; // 사용된 단어 목록 초기화
      getNextWord(); // 다음 단어 가져오기
    });

    gameTimer?.cancel(); // 이전 타이머 취소
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) { // 1초마다 타이머 실행
      setState(() {
        if (remainingTime > 0) {
          remainingTime--; // 남은 시간 감소
        } else {
          timer.cancel(); // 시간 종료 시 타이머 취소
          showGameOverDialog(); // 게임 종료 다이얼로그 표시
        }
      });
    });
  }

  // 다음 단어 가져오는 함수
  void getNextWord() {
    List<String> availableWords = List.from(words)..removeWhere((word) => usedWords.contains(word));
    if (availableWords.isNotEmpty) {
      currentWord = availableWords[Random().nextInt(availableWords.length)];
      usedWords.add(currentWord); // 사용된 단어 목록에 추가
      hint = getInitialSound(currentWord); // 초성 힌트 생성
    } else {
      showGameOverDialog(); // 더 이상 출제할 단어가 없을 경우 게임 종료 다이얼로그 표시
    }
  }

  // 단어의 초성을 추출하는 함수
  String getInitialSound(String word) {
    final List<String> choSungs = [
      'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ',
      'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
    ];

    String initialSound = "";
    for (int i = 0; i < word.length; i++) {
      int code = word.codeUnitAt(i) - 0xAC00;
      int choIndex = code ~/ 588;
      initialSound += choSungs[choIndex];
    }

    return initialSound;
  }

  // 사용자가 입력한 답을 확인하는 함수
  void checkAnswer(String answer) {
    if (answer == currentWord) {
      setState(() {
        scores[currentPlayerIndex] += scorePerWord; // 정답일 경우 플레이어 점수 증가
      });
    } else {
      setState(() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.length; // 다음 플레이어로 전환
      });
    }

    getNextWord(); // 다음 단어로 이동
  }

  // 게임 종료 다이얼로그 표시 함수
  void showGameOverDialog() {
    scores.sort((a, b) => b.compareTo(a)); // 점수를 기준으로 내림차순 정렬

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("게임 종료!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("게임이 종료되었습니다."),
              SizedBox(height: 10),
              Text("결과:"),
              SizedBox(height: 10),
              // 각 플레이어의 점수와 순위 표시
              ListView.builder(
                shrinkWrap: true,
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return Text("${index + 1}위: ${players[index]} - ${scores[index]}점");
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("다시 시작"),
              onPressed: () {
                Navigator.of(context).pop();
                startGame(); // 다시 시작 버튼 클릭 시 게임 재시작
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("초성 게임"), // 앱바 제목
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text("남은 시간: $remainingTime초", style: TextStyle(fontSize: 24)), // 남은 시간 표시
            SizedBox(height: 20),
            Text("플레이어: ${players[currentPlayerIndex]}"), // 현재 플레이어 표시
            SizedBox(height: 20),
            Text("점수: ${scores[currentPlayerIndex]}", style: TextStyle(fontSize: 24)), // 현재 플레이어 점수 표시
            SizedBox(height: 20),
            Text("단어의 초성은 '$hint'입니다.", style: TextStyle(fontSize: 24)), // 초성 힌트 표시
            TextField(
              onSubmitted: (String answer) {
                checkAnswer(answer); // 정답 확인
              },
              decoration: InputDecoration(
                labelText: "단어를 입력하세요", // 입력 필드 라벨
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel(); // 위젯 종료 시 타이머 취소
    super.dispose();
  }
}
