import 'dart:html';
import 'dart:async' show StreamSubscription;
import 'TTTBoard.dart';

TTTBoard mainBoard;
String currentPlayer;
List<int> availableSquares;
Map<DivElement, StreamSubscription> available;

DivElement mainBoardDiv = querySelector("#main-board");
DivElement messageDiv = querySelector("#message");

DivElement getMainSquareDiv(int mainSquare) =>
    querySelector('.main-square[data-square="$mainSquare"]');

bool toggleHighlight(DivElement squareDiv) =>
    squareDiv.classes.toggle("available-square");

String markSquare(DivElement squareDiv, String player) =>
    squareDiv.text = player;

String showMessage(String msg) => messageDiv.text = msg;

void newGame([MouseEvent event]) {
  mainBoard = new TTTBoard();
  currentPlayer = null;
  availableSquares = [];
  available = {};
  createBoard();
  nextTurn();
}

void createBoard() {
  mainBoardDiv.children.clear();
  final List<String> layout = [
    "layout",
    "horizontal",
    "center",
    "center-justified"
  ];

  for (int mainSquare = 0; mainSquare < 9; mainSquare++) {
    DivElement mainSquareDiv = new DivElement()
      ..classes.addAll(["main-square", "wrap"]..addAll(layout))
      ..attributes['data-square'] = mainSquare.toString();

    mainBoardDiv.append(mainSquareDiv);
  }
}

void nextTurn() {
  // toggle current player
  currentPlayer = currentPlayer == "X" ? "O" : "X";
  showMessage("Player: $currentPlayer");

  // figure out which main squares are available
  availableSquares = mainBoard.emptySquares;
  // find, save, and highlight all available main squares
  for (int square in availableSquares) {
    DivElement squareDiv = getMainSquareDiv(square);
    toggleHighlight(squareDiv);
    available[squareDiv] =
        squareDiv.onClick.listen((MouseEvent event) => move(square));
  }
}

void move(int mainSquare) {
  available
    ..forEach((DivElement squareDiv, StreamSubscription listener) {
      toggleHighlight(squareDiv);
      listener.cancel();
    })
    ..clear();
  String winner = mainBoard.move(mainSquare, currentPlayer);
  markSquare(getMainSquareDiv(mainSquare), currentPlayer);
  if (winner != null) {
    showMessage("Play $winner wins!");
    return;
  } else if (mainBoard.isFull) {
    showMessage("Draw!");
    return;
  } 
  nextTurn();
}

void main() async {
  querySelector('#new-game-btn').onClick.listen(newGame);
  newGame();
}
