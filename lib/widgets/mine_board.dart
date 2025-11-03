import 'package:finesweeper/cell.dart';
import 'package:flutter/material.dart';
import '../models/minesweeper_game.dart';

class MineBoard extends StatelessWidget {
  final MinesweeperGame game;
  final VoidCallback onUpdate;

  const MineBoard({
    super.key,
    required this.game,
    required this.onUpdate,
  });

  Widget _buildCell(BuildContext context, Cell cell) {
    return GestureDetector(
      onTap: () {
        game.reveal(cell);
        onUpdate();
        _handleDialogs(context);
      },
      onLongPress: () {
        if (!cell.revealed) {
          cell.flagged = !cell.flagged;
          onUpdate();
        }
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        width: 30,
        height: 30,
        color: cell.revealed
            ? (cell.hasMine ? Colors.red[400] : Colors.grey[300])
            : Colors.grey[600],
        alignment: Alignment.center,
        child: cell.revealed
            ? (cell.hasMine
                ? const Icon(Icons.adjust, color: Colors.black, size: 20)
                : (cell.neighborMines > 0
                    ? Text(
                        cell.neighborMines.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null))
            : (cell.flagged
                ? const Icon(Icons.flag, color: Colors.yellow, size: 20)
                : null),
      ),
    );
  }

  void _handleDialogs(BuildContext context) {
    if (game.status == GameStatus.lost) {
      _showDialog(context, "Game Over", "You clicked on a mine!");
    } else if (game.status == GameStatus.won) {
      _showDialog(context, "You Win!", "Congratulations! You cleared all safe cells.");
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                game.reset();
                onUpdate();
              },
              child: const Text("Restart"),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: game.cells
          .map(
            (row) => Row(
              mainAxisSize: MainAxisSize.min,
              children: row.map((c) => _buildCell(context, c)).toList(),
            ),
          )
          .toList(),
    );
  }
}
