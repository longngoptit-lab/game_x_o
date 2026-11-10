import 'package:flutter_test/flutter_test.dart';
import 'package:game_x_o/commons/models/enums/enums.dart';
import 'package:game_x_o/features/game/logic/dora_ai.dart';

void main() {
  test('hard AI chooses an optimal move in every reachable 3 × 3 position', () {
    final ai = TicTacToeAI();
    final scores = <String, int>{};
    final visited = <String>{};
    var checked = 0;

    String? winner(List<String> board) {
      const lines = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
      ];
      for (final line in lines) {
        final mark = board[line.first];
        if (mark.isNotEmpty && line.every((i) => board[i] == mark)) return mark;
      }
      return null;
    }

    int solve(List<String> board, String turn) {
      final won = winner(board);
      if (won != null) return won == 'X' ? 1 : -1;
      if (!board.contains('')) return 0;
      final key = '${board.map((s) => s.isEmpty ? '-' : s).join()}$turn';
      if (scores.containsKey(key)) return scores[key]!;
      var best = turn == 'X' ? -2 : 2;
      for (var i = 0; i < 9; i++) {
        if (board[i].isNotEmpty) continue;
        board[i] = turn;
        final value = solve(board, turn == 'X' ? 'O' : 'X');
        board[i] = '';
        if (turn == 'X' ? value > best : value < best) best = value;
      }
      return scores[key] = best;
    }

    void visit(List<String> board, String turn) {
      if (winner(board) != null || !board.contains('')) return;
      final key = '${board.map((s) => s.isEmpty ? '-' : s).join()}$turn';
      if (!visited.add(key)) return;
      if (turn == 'X') {
        final expected = solve(board, turn);
        final move = ai.getBestMove([
          board.sublist(0, 3),
          board.sublist(3, 6),
          board.sublist(6, 9),
        ], 3);
        expect(board[move], '', reason: key);
        board[move] = 'X';
        expect(solve(board, 'O'), expected, reason: key);
        board[move] = '';
        checked++;
      }
      for (var i = 0; i < 9; i++) {
        if (board[i].isNotEmpty) continue;
        board[i] = turn;
        visit(board, turn == 'X' ? 'O' : 'X');
        board[i] = '';
      }
    }

    visit(List.filled(9, ''), 'X');
    visit(List.filled(9, ''), 'O');
    expect(checked, greaterThan(4000));
  });
  for (final size in [3, 4, 5]) {
    for (final difficulty in Difficulty.values) {
      test(
        '$difficulty chooses an empty cell on $size × $size without changing input',
        () {
          final board = List.generate(size, (_) => List.filled(size, ''));
          board[0][0] = 'O';
          final before = board.map((row) => List<String>.from(row)).toList();
          final move = TicTacToeAI().getBestMove(
            board,
            size,
            difficulty: difficulty,
          );
          expect(move, inInclusiveRange(1, size * size - 1));
          expect(board[move ~/ size][move % size], '');
          expect(board, before);
        },
      );
    }
  }
  for (final difficulty in [Difficulty.medium, Difficulty.hard]) {
    test('$difficulty takes a win before blocking', () {
      expect(
        TicTacToeAI().getBestMove(
          [
            ['X', 'X', ''],
            ['O', 'O', ''],
            ['', '', ''],
          ],
          3,
          difficulty: difficulty,
        ),
        2,
      );
    });
    test('$difficulty blocks an immediate loss', () {
      expect(
        TicTacToeAI().getBestMove(
          [
            ['O', 'O', ''],
            ['X', '', ''],
            ['', '', ''],
          ],
          3,
          difficulty: difficulty,
        ),
        2,
      );
    });
  }
  for (final difficulty in Difficulty.values) {
    test('$difficulty returns -1 when no moves remain', () {
      expect(
        TicTacToeAI().getBestMove(
          [
            ['X', 'O', 'X'],
            ['X', 'O', 'O'],
            ['O', 'X', 'X'],
          ],
          3,
          difficulty: difficulty,
        ),
        -1,
      );
    });
  }
}
