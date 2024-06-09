//화살표 게임
//플레이 방법 화면에 표시되는 화살표 방향을 맞추면 다음 문제로 넘어가고 제한 시간이 다 되면 끝남
import 'package:flutter/material.dart';
import 'dart:async'; // 타이머를 사용하기 위한 패키지
import 'dart:math'; // 무작위 숫자를 생성하기 위한 패키지

void main() {
  runApp(MyApp());
}

// 애플리케이션의 루트 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrow Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ArrowGame(),
    );
  }
}

// 게임 화면 위젯
class ArrowGame extends StatefulWidget {
  @override
  _ArrowGameState createState() => _ArrowGameState();
}

class _ArrowGameState extends State<ArrowGame> {
  String arrowDirection = 'UP'; // 현재 표시된 화살표 방향
  Timer? timer; // 타이머 객체
  int timeLeft = 30; // 남은 시간 (초)
  List<String> players = ['Player 1', 'Player 2', 'Player 3']; // 플레이어 목록
  Map<String, int> playerScores = {}; // 플레이어별 점수
  Random random = Random(); // 무작위 숫자 생성을 위한 객체

  @override
  void initState() {
    super.initState();
    // 각 플레이어의 점수를 0으로 초기화
    for (var player in players) {
      playerScores[player] = 0;
    }
    // 게임 시작
    startGame();
  }

  // 게임을 시작하는 메서드
  void startGame() {
    displayArrow();
    // 1초마다 호출되는 타이머 설정
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--; // 남은 시간 감소
        } else {
          endGame(); // 시간이 다 되면 게임 종료
        }
      });
    });
  }

  // 무작위 화살표 방향을 표시하는 메서드
  void displayArrow() {
    List<String> directions = ['UP', 'DOWN', 'LEFT', 'RIGHT'];
    int randomIndex = random.nextInt(directions.length);
    setState(() {
      arrowDirection = directions[randomIndex];
    });
  }

  // 사용자가 입력한 답을 확인하는 메서드
  void checkAnswer(String answer) {
    setState(() {
      if (answer == arrowDirection) {
        playerScores[players[0]] = (playerScores[players[0]] ?? 0) + 1;
        displayArrow(); // 정답이면 새로운 화살표 표시
      } else {
        endGame(); // 오답이면 게임 종료
      }
    });
  }

  // 게임을 종료하는 메서드
  void endGame() {
    timer?.cancel(); // 타이머 취소
    // 게임 종료 다이얼로그 표시
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text(buildScoreText()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame(); // 재시작 버튼 클릭 시 게임 재시작
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  // 게임을 재시작하는 메서드
  void resetGame() {
    setState(() {
      timeLeft = 30; // 남은 시간 초기화
      // 각 플레이어 점수 초기화
      for (var player in players) {
        playerScores[player] = 0;
      }
      startGame(); // 게임 시작
    });
  }

  // 각 플레이어의 점수를 문자열로 반환하는 메서드
  String buildScoreText() {
    // 점수를 내림차순으로 정렬
    List<MapEntry<String, int>> sortedScores = playerScores.entries.toList();
    sortedScores.sort((a, b) => b.value.compareTo(a.value));

    StringBuffer buffer = StringBuffer();
    for (var entry in sortedScores) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // 배경색 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              arrowDirection,
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
            SizedBox(height: 30),
            Wrap(
              spacing: 10,
              children: <Widget>[
                for (var direction in ['UP', 'DOWN', 'LEFT', 'RIGHT'])
                  ElevatedButton(
                    onPressed: () => checkAnswer(direction),
                    child: Text(direction),
                  ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Time left: $timeLeft seconds',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              buildScoreText(),
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

