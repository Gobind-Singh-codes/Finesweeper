import 'dart:math';
import 'package:flutter/material.dart';

/// Cell model
class Cell {
  final int row, col;
  bool revealed = false;
  bool flagged = false;
  final bool hasMine;
  int neighborMines = 0;

  Cell(this.row, this.col, this.hasMine);
}

/// Minesweeper grid with prefix sum
class Minesweeper {
  final int rows, cols;
  late List<List<int>> grid; // 1 if mine, 0 otherwise
  late List<List<int>> psum;

  Minesweeper(this.rows, this.cols, int mineCount) {
    grid = List.generate(rows, (_) => List.filled(cols, 0));
    final random = Random();
    int placed = 0;

    while (placed < mineCount) {
      int r = random.nextInt(rows);
      int c = random.nextInt(cols);
      if (grid[r][c] == 0) {
        grid[r][c] = 1;
        placed++;
      }
    }

    _buildPrefixSum();
  }

  void _buildPrefixSum() {
    psum = List.generate(rows, (_) => List.filled(cols, 0));
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        psum[r][c] =
            grid[r][c] +
            (r > 0 ? psum[r - 1][c] : 0) +
            (c > 0 ? psum[r][c - 1] : 0) -
            (r > 0 && c > 0 ? psum[r - 1][c - 1] : 0);
      }
    }
  }

  int countMines(int r1, int c1, int r2, int c2) {
    r1 = r1.clamp(0, rows - 1);
    c1 = c1.clamp(0, cols - 1);
    r2 = r2.clamp(0, rows - 1);
    c2 = c2.clamp(0, cols - 1);
    int total = psum[r2][c2];
    if (r1 > 0) total -= psum[r1 - 1][c2];
    if (c1 > 0) total -= psum[r2][c1 - 1];
    if (r1 > 0 && c1 > 0) total += psum[r1 - 1][c1 - 1];
    return total;
  }
}

/// Game logic
class MinesweeperGame {
  final int rows, cols;
  final int mineCount;
  late Minesweeper ms;
  late List<List<Cell>> cells;
  bool gameOver = false;

  MinesweeperGame(this.rows, this.cols, this.mineCount) {
    ms = Minesweeper(rows, cols, mineCount);
    cells = List.generate(
      rows,
      (r) => List.generate(cols, (c) {
        bool hasMine = ms.grid[r][c] == 1;
        Cell cell = Cell(r, c, hasMine);
        cell.neighborMines =
            ms.countMines(r - 1, c - 1, r + 1, c + 1) - (hasMine ? 1 : 0);
        return cell;
      }),
    );
  }

  /// Reveal a cell
  void reveal(Cell cell, BuildContext context, VoidCallback onUpdate) {
    if (cell.revealed || cell.flagged || gameOver) return;
    cell.revealed = true;

    if (cell.hasMine) {
      gameOver = true;
      // Reveal all mines
      for (var row in cells) {
        for (var c in row) {
          if (c.hasMine) c.revealed = true;
        }
      }
      onUpdate();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Game Over"),
          content: Text("You clicked on a mine!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                reset();
                onUpdate();
              },
              child: Text("Restart"),
            ),
          ],
        ),
      );
      return;
    }

    // Flood fill neighbors if empty
    if (cell.neighborMines == 0 && !cell.hasMine) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          int nr = cell.row + dr;
          int nc = cell.col + dc;
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
            reveal(cells[nr][nc], context, onUpdate);
          }
        }
      }
    }

    // Check win condition
    if (checkWin()) {
      gameOver = true;
      onUpdate();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("You Win!"),
          content: Text("Congratulations! You cleared all safe cells."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                reset();
                onUpdate();
              },
              child: Text("Restart"),
            ),
          ],
        ),
      );
    }
  }

  bool checkWin() {
    for (var row in cells) {
      for (var cell in row) {
        if (!cell.hasMine && !cell.revealed) return false;
      }
    }
    return true;
  }

  /// Reset game
  void reset() {
    ms = Minesweeper(rows, cols, mineCount);
    gameOver = false;
    cells = List.generate(
      rows,
      (r) => List.generate(cols, (c) {
        bool hasMine = ms.grid[r][c] == 1;
        Cell cell = Cell(r, c, hasMine);
        cell.neighborMines =
            ms.countMines(r - 1, c - 1, r + 1, c + 1) - (hasMine ? 1 : 0);
        return cell;
      }),
    );
  }
}

/// Flutter UI
class MinesweeperWidget extends StatefulWidget {
  @override
  State<MinesweeperWidget> createState() => _MinesweeperWidgetState();
}

class _MinesweeperWidgetState extends State<MinesweeperWidget> {
  late MinesweeperGame game;

  @override
  void initState() {
    super.initState();
    game = MinesweeperGame(10, 10, 15); // 10x10 with 15 mines
  }

  Widget buildCell(Cell cell) {
    return GestureDetector(
      onTap: () => setState(() {
        game.reveal(cell, context, () => setState(() {}));
      }),
      onLongPress: () => setState(() {
        if (!cell.revealed) cell.flagged = !cell.flagged;
      }),
      child: Container(
        margin: EdgeInsets.all(1),
        width: 30,
        height: 30,
        color: cell.revealed
            ? (cell.hasMine ? Colors.red[400] : Colors.grey[300])
            : Colors.grey[600],
        alignment: Alignment.center,
        child: cell.revealed
            ? (cell.hasMine
                  ? Icon(Icons.adjust, color: Colors.black, size: 20)
                  : cell.neighborMines > 0
                  ? Text(
                      cell.neighborMines.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null)
            : (cell.flagged
                  ? Icon(Icons.flag, color: Colors.yellow, size: 20)
                  : null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Minesweeper")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: game.cells
              .map(
                (row) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: row.map(buildCell).toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MinesweeperWidget()));
}
