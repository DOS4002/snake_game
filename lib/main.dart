import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Snake Game'),
        ),
        body: SnakeGameScreen(),
      ),
    );
  }
}

class SnakeGameScreen extends StatefulWidget {
  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  final int gridSize = 20;
  final int cellSize = 20;
  List<Offset> snake = [Offset(5, 5)];
  late Offset food;

  Direction direction = Direction.right;
  bool isPlaying = false;

  // Added this constructor to initialize the 'food' field.
 void startGame() {
    snake = [Offset(5, 5)];

    // Initialize 'food' here.
    spawnFood();

    isPlaying = true;
    direction = Direction.right;

    Duration speed = Duration(milliseconds: 300);

    Timer.periodic(speed, (Timer timer) {
      if (!isPlaying) {
        timer.cancel();
        return;
      }
      moveSnake();
      if (checkCollision()) {
        gameOver();
        timer.cancel();
      }
    });
  }

  void spawnFood() {
    final random = Random();
    int x = random.nextInt(gridSize - 1);
    int y = random.nextInt(gridSize - 1);
    food = Offset(x.toDouble(), y.toDouble());
  }

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void moveSnake() {
    Offset head = snake.first;
    Offset newHead;

    switch (direction) {
      case Direction.up:
        newHead = Offset(head.dx, head.dy - 1);
        break;
      case Direction.down:
        newHead = Offset(head.dx, head.dy + 1);
        break;
      case Direction.left:
        newHead = Offset(head.dx - 1, head.dy);
        break;
      case Direction.right:
        newHead = Offset(head.dx + 1, head.dy);
        break;
    }

    setState(() {
      snake.insert(0, newHead);
      if (newHead == food) {
        spawnFood();
      } else {
        snake.removeLast();
      }
    });
  }

  bool checkCollision() {
    Offset head = snake.first;
    if (head.dx < 0 || head.dx >= gridSize || head.dy < 0 || head.dy >= gridSize) {
      return true;
    }

    for (int i = 1; i < snake.length; i++) {
      if (head == snake[i]) {
        return true;
      }
    }

    return false;
  }

  void gameOver() {
    setState(() {
      isPlaying = false;
    });
  }

  void handleDirection(Direction newDirection) {
    if (!isPlaying) return;
    if ((newDirection == Direction.left && direction != Direction.right) ||
        (newDirection == Direction.right && direction != Direction.left) ||
        (newDirection == Direction.up && direction != Direction.down) ||
        (newDirection == Direction.down && direction != Direction.up)) {
      direction = newDirection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0) {
          handleDirection(Direction.down);
        } else if (details.delta.dy < 0) {
          handleDirection(Direction.up);
        }
      },
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          handleDirection(Direction.right);
        } else if (details.delta.dx < 0) {
          handleDirection(Direction.left);
        }
      },
      child: Center(
        child: Container(
          width: gridSize * cellSize.toDouble(),
          height: gridSize * cellSize.toDouble(),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
            ),
            itemBuilder: (BuildContext context, int index) {
              int x = index % gridSize;
              int y = index ~/ gridSize;
              Offset position = Offset(x.toDouble(), y.toDouble());

              if (snake.contains(position)) {
                return SnakeCell();
              } else if (food == position) {
                return FoodCell();
              } else {
                return EmptyCell();
              }
            },
          ),
        ),
      ),
    );
  }
}

enum Direction { up, down, left, right }

class SnakeCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
    );
  }
}

class FoodCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }
}

class EmptyCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}
