import 'package:finesweeper/cell.dart';

import 'minesweeper.dart';

enum GameStatus { playing, won, lost }

/// Handles gameplay logic and game state
class MinesweeperGame {
  final int rows, cols, mineCount;
  late Minesweeper ms;
  late List<List<Cell>> cells;
  GameStatus status = GameStatus.playing;

  MinesweeperGame(this.rows, this.cols, this.mineCount) {
    _initialize();
  }

  void _initialize() {
    ms = Minesweeper(rows, cols, mineCount);
    cells = List.generate(rows, (r) {
      return List.generate(cols, (c) {
        bool hasMine = ms.grid[r][c] == 1;
        final cell = Cell(r, c, hasMine);
        cell.neighborMines =
            ms.countMines(r - 1, c - 1, r + 1, c + 1) - (hasMine ? 1 : 0);
        return cell;
      });
    });
    status = GameStatus.playing;
  }

  void reset() => _initialize();

  void reveal(Cell cell) {
    if (cell.revealed || cell.flagged || status != GameStatus.playing) return;

    cell.revealed = true;

    if (cell.hasMine) {
      _revealAllMines();
      status = GameStatus.lost;
      return;
    }

    if (cell.neighborMines == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          final nr = cell.row + dr, nc = cell.col + dc;
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
            reveal(cells[nr][nc]);
          }
        }
      }
    }

    if (_checkWin()) status = GameStatus.won;
  }

  bool _checkWin() {
    for (final row in cells) {
      for (final cell in row) {
        if (!cell.hasMine && !cell.revealed) return false;
      }
    }
    return true;
  }

  void _revealAllMines() {
    for (final row in cells) {
      for (final cell in row) {
        if (cell.hasMine) cell.revealed = true;
      }
    }
  }
}
