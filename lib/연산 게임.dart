//연산 게임
//플레이방법 더하기, 빼기 연산 문제가 나오는데 맞추면 정답, 틀리면 오답으로 제한 시간이 되면 게임 종료
import 'package:flutter/material.dart';
import 'dart:async'; // 타이머를 사용하기 위한 패키지
import 'dart:math'; // 무작위 숫자를 생성하기 위한 패키지

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Math Game',
      home: MathGame(),
    );
  }
}

class MathGame extends StatefulWidget {
  @override
  _MathGameState createState() => _MathGameState();
}

class _MathGameState extends State<MathGame> {
  int number1 = 0; // 첫 번째 숫자
  int number2 = 0; // 두 번째 숫자
  String operator = ''; // 연산자
  int answer = 0; // 정답
  Map<String, int> scores = {}; // 플레이어 점수 맵
  List<String> players = []; // 플레이어 목록
  int currentPlayerIndex = 0; // 현재 플레이어 인덱스
  int _start = 30; // 타이머 시작 시간
  Timer? _timer; // 타이머 객체
  final TextEditingController _controller = TextEditingController(); // 정답 입력을 위한 컨트롤러

  @override
  void initState() {
    super.initState();
    initializePlayers(); // 플레이어 초기화
    generateProblem(); // 문제 생성
    startTimer(); // 타이머 시작
  }

  // 플레이어 초기화
  void initializePlayers() {
    scores = {}; // 기존 점수 초기화
    players = ['Player 1', 'Player 2', 'Player 3']; // 플레이어 목록
    for (var player in players) {
      scores[player] = 0; // 각 플레이어의 점수를 0으로 초기화
    }
  }

  // 무작위 연산 문제 생성
  void generateProblem() {
    Random rand = Random();
    number1 = rand.nextInt(100); // 0부터 99까지의 무작위 숫자
    number2 = rand.nextInt(100); // 0부터 99까지의 무작위 숫자
    if (rand.nextBool()) {
      operator = '+'; // 무작위로 더하기 연산자 선택
      answer = number1 + number2; // 정답 계산
    } else {
      operator = '-'; // 무작위로 빼기 연산자 선택
      answer = number1 - number2; // 정답 계산
    }
  }

  // 타이머 시작
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            // 게임 종료 후 결과 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(scores: scores),
              ),
            );
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  // 사용자 답 확인
  void checkAnswer() {
    var currentPlayer = players[currentPlayerIndex];
    if (int.tryParse(_controller.text) == answer) {
      setState(() {
        if (scores.containsKey(currentPlayer)) {
          scores[currentPlayer] = scores[currentPlayer]! + 1; // 정답일 경우 현재 플레이어의 점수 증가
        } else {
          scores[currentPlayer] = 1; // 새로운 플레이어의 경우 초기 점수 1로 설정
        }
      });
    } else {
      setState(() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.length; // 오답일 경우 다음 플레이어로 전환
      });
    }
    _controller.clear(); // 입력 필드 초기화
    generateProblem(); // 새로운 문제 생성
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Math Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Player ${players[currentPlayerIndex]}\'s Turn',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              '$number1 $operator $number2 = ?',
              style: TextStyle(fontSize: 32),
            ),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter your answer',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text('Submit'),
            ),
            SizedBox(height: 20),
            Text(
              'Scores:',
              style: TextStyle(fontSize: 24),
            ),
            Column(
              children: scores.entries.map((entry) {
                return Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(fontSize: 20),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Time left: $_start',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 취소
    super.dispose();
  }
}

class ResultScreen extends StatelessWidget {
  final Map<String, int> scores;

  ResultScreen({required this.scores});

  @override
  Widget build(BuildContext context) {
    // 점수를 내림차순으로 정렬
    List<MapEntry<String, int>> sortedScores = scores.entries.toList();
    sortedScores.sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text('Game Over'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Final Scores',
              style: TextStyle(fontSize: 32),
            ),
            SizedBox(height: 20),
            // 점수 순위 표시
            Column(
              children: sortedScores.map((entry) {
                return Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(fontSize: 24),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 게임을 다시 시작하기 위해 메인 화면으로 돌아감
                Navigator.pop(context);
              },
              child: Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}
