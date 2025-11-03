import 'package:flutter/material.dart';
import 'models/minesweeper_game.dart';
import 'widgets/mine_board.dart';

void main() => runApp(const MinesweeperApp());

class MinesweeperApp extends StatefulWidget {
  const MinesweeperApp({super.key});

  @override
  State<MinesweeperApp> createState() => _MinesweeperAppState();
}

class _MinesweeperAppState extends State<MinesweeperApp> {
  late MinesweeperGame game;

  @override
  void initState() {
    super.initState();
    game = MinesweeperGame(10, 10, 15);
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Minesweeper",
      home: Scaffold(
        appBar: AppBar(title: const Text("Minesweeper")),
        body: Center(child: MineBoard(game: game, onUpdate: _refresh)),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            game.reset();
            _refresh();
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
