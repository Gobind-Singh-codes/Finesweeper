# 🎯 Finesweeper (Flutter)

**Finesweeper** is a fast, playable Minesweeper-style game built with **Flutter**, featuring efficient neighbor calculations using **2D prefix sums**. Clear all safe cells without hitting a mine! 💣✨

---

## 🕹 Features

- Classic Minesweeper gameplay on a customizable grid (default 10x10 with 15 mines)
- Tap to reveal cells, long press to flag/unflag 🚩
- Automatic flood-fill for empty cells
- Real-time neighbor mine counts calculated via **prefix sum** for instant performance
- **Game Over** and **Win** alerts with restart option
- All mines revealed on game over
- Fully responsive UI ready for desktop and web

---

## 🚀 Getting Started

1. **Clone the repository**

```bash
git clone https://github.com/Gobind-Singh-codes/ubiquitous-barnacle.git
cd ubiquitous-barnacle
```
2. **Get Dependencies**
```bash
flutter pub get
```   
3. **Run The App**
```bash
flutter run
```
4. **🗂 Project Structure**
```bash
lib/
├── main.dart
├── models/
│   ├── cell.dart
│   ├── minesweeper.dart
│   └── minesweeper_game.dart
└── widgets/
    └── mine_board.dart
```  
5. **How it works**

-  The game uses a 2D prefix sum grid to quickly calculate the number of neighboring mines for each cell.
-  Revealing a cell with zero neighboring mines triggers a flood-fill animation to reveal safe cells automatically.
-  Flags are managed with a long press.
-  Game-over reveals all mines with a dialog prompt.
-   Winning triggers a congratulatory dialog with a restart option.
