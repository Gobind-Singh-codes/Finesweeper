/// Cell model
class Cell {
  final int row, col;
  bool revealed = false;
  bool flagged = false;
  final bool hasMine;
  int neighborMines = 0;

  Cell(this.row, this.col, this.hasMine);
}