import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const SnakeGamePage(),
    );
  }
}

class SnakeGamePage extends StatefulWidget {
  const SnakeGamePage({super.key});

  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage> {
  // Game Configuration
  static const int rows = 20;
  static const int columns = 20;

  // Game State
  List<int> snake = [45, 65, 85]; // Head is last, Tail is first
  int food = 100;
  // Directions: 0=up, 1=down, 2=left, 3=right
  var direction = 'down';
  bool isPlaying = false;
  Timer? gameTimer;
  int score = 0;

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    setState(() {
      isPlaying = true;
      score = 0;
      snake = [45, 65, 85];
      food = 100;
      direction = 'down';
      gameTimer = Timer.periodic(const Duration(milliseconds: 300), (
        Timer timer,
      ) {
        updateGame();
      });
    });
  }

  void updateGame() {
    setState(() {
      int head = snake.last;
      int newHead;

      switch (direction) {
        case 'up':
          newHead = head - columns;
          break;
        case 'down':
          newHead = head + columns;
          break;
        case 'left':
          newHead = head - 1;
          break;
        case 'right':
          newHead = head + 1;
          break;
        default:
          newHead = head;
      }

      if (checkCollision(newHead)) {
        // Check collision BEFORE adding
        gameOver();
        return;
      }

      snake.add(newHead);

      if (newHead == food) {
        score++;
        generateFood();
      } else {
        snake.removeAt(0);
      }
    });
  }

  bool checkCollision(int pos) {
    // Wall Collision
    if (pos < 0 || pos >= rows * columns) return true; // Top/Bottom boundary

    int head = snake.last;
    // Left/Right boundary checks
    if (direction == 'left' &&
        head % columns == 0 &&
        pos % columns != columns - 1)
      return true;
    if (direction == 'right' && (head + 1) % columns == 0 && pos % columns != 0)
      return true;

    // Self Collision
    if (snake.contains(pos)) return true;

    return false;
  }

  void generateFood() {
    int newFood;
    do {
      newFood = Random().nextInt(rows * columns);
    } while (snake.contains(newFood));
    food = newFood;
  }

  void gameOver() {
    gameTimer?.cancel();
    setState(() {
      isPlaying = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Game Over', style: TextStyle(color: Colors.white)),
          content: Text(
            'Your Score: $score',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
              child: const Text(
                'Play Again',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  void changeDirection(String newDir) {
    if ((direction == 'down' && newDir == 'up') ||
        (direction == 'up' && newDir == 'down') ||
        (direction == 'left' && newDir == 'right') ||
        (direction == 'right' && newDir == 'left')) {
      return;
    }
    direction = newDir;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isPortrait = constraints.maxHeight > constraints.maxWidth;

          if (isPortrait) {
            return Column(
              children: [
                _buildScoreBoard(),
                Expanded(flex: 3, child: _buildGameGrid()),
                Expanded(flex: 2, child: _buildControls()),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildScoreBoard(),
                      const SizedBox(height: 20),
                      _buildControls(),
                    ],
                  ),
                ),
                Expanded(flex: 3, child: _buildGameGrid()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Text(
        'Score: $score',
        style: const TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGameGrid() {
    return Center(
      child: AspectRatio(
        aspectRatio: columns / rows,
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.delta.dy > 0)
              changeDirection('down');
            else if (details.delta.dy < 0)
              changeDirection('up');
          },
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx > 0)
              changeDirection('right');
            else if (details.delta.dx < 0)
              changeDirection('left');
          },
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows * columns,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
            ),
            itemBuilder: (BuildContext context, int index) {
              if (snake.contains(index)) {
                return Container(
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      color: index == snake.last
                          ? Colors.greenAccent[400]
                          : Colors.green[800],
                    ),
                  ),
                );
              } else if (index == food) {
                return Container(
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(color: Colors.redAccent),
                  ),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(2),
                  child: Container(color: Colors.grey[900]),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    if (!isPlaying) {
      return Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: startGame,
          child: const Text(
            'START GAME',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _gamePadButton(Icons.arrow_drop_up, () => changeDirection('up')),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _gamePadButton(Icons.arrow_left, () => changeDirection('left')),
            const SizedBox(width: 50), // Spacing for D-pad feel
            _gamePadButton(Icons.arrow_right, () => changeDirection('right')),
          ],
        ),
        _gamePadButton(Icons.arrow_drop_down, () => changeDirection('down')),
      ],
    );
  }

  Widget _gamePadButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: Colors.grey[800], // Dark button color
          foregroundColor: Colors.white,
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }
}
