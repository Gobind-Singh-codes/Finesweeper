import 'dart:math';

/// Core minesweeper logic with prefix sum for fast mine counting
class Minesweeper {
  final int rows, cols;
  late List<List<int>> grid;
  late List<List<int>> psum;

  Minesweeper(this.rows, this.cols, int mineCount) {
    _generateGrid(mineCount);
    _buildPrefixSum();
  }

  void _generateGrid(int mineCount) {
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
  }

  void _buildPrefixSum() {
    psum = List.generate(rows, (_) => List.filled(cols, 0));
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        psum[r][c] = grid[r][c] +
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
