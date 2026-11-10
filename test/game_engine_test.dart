import 'package:flutter_test/flutter_test.dart';
import 'package:game_x_o/features/game/blocs/game_bloc.dart';
import 'package:game_x_o/features/game/logic/game.dart';
import 'package:game_x_o/features/game/logic/pass_n_play.dart';
import 'package:game_x_o/features/game/models/game_position_model.dart';
import 'package:game_x_o/features/game/models/game_setting_model.dart';
import 'package:game_x_o/features/game/models/player_model.dart';

class RecordingGame extends Game {
  RecordingGame(int size) : super(settings: GameSettings(boardSize: size));
  final events = <GameEvent>[];
  @override
  bool get restrictedMoves => false;
  @override
  void addEvent(GameEvent event) => events.add(event);
  @override
  void onUpdate(int row, int column, Player player) {}
}

Player player(String id) => Player(
  playerId: id,
  skinX: 'x',
  skinO: 'o',
  name: id,
  playerProfile: '',
  activeSkinType: 'X',
);

void main() {
  for (final size in [3, 4, 5]) {
    group('$size × $size wins', () {
      late RecordingGame game;
      setUp(() {
        game = RecordingGame(size)..currentPlayer = player('a');
      });
      for (var line = 0; line < size; line++) {
        test('row $line', () {
          for (var c = 0; c < size; c++) {
            game.board[line][c] = const GamePosition(playerId: 'a');
          }
          expect(game.checkWin(), isTrue);
          expect((game.events.single as GameOverEvent).gameOverRow, line);
        });
        test('column $line', () {
          for (var r = 0; r < size; r++) {
            game.board[r][line] = const GamePosition(playerId: 'a');
          }
          expect(game.checkWin(), isTrue);
          expect((game.events.single as GameOverEvent).gameOverColumn, line);
        });
      }
      for (final diagonal in WinDiagonal.values) {
        test('$diagonal', () {
          for (var i = 0; i < size; i++) {
            game.board[i][diagonal == WinDiagonal.main ? i : size - 1 - i] =
                const GamePosition(playerId: 'a');
          }
          expect(game.checkWin(), isTrue);
          expect((game.events.single as GameOverEvent).diagonal, diagonal);
        });
      }
      test('empty and partial lines do not win', () {
        expect(game.checkWin(), isFalse);
        for (var i = 0; i < size - 1; i++) {
          game.board[0][i] = const GamePosition(playerId: 'a');
        }
        expect(game.checkWin(), isFalse);
        expect(game.events, isEmpty);
      });
    });
  }

  test('a full board without a line is a draw', () {
    final game = RecordingGame(3)..currentPlayer = player('a');
    game.board =
        [
              ['a', 'b', 'a'],
              ['a', 'b', 'b'],
              ['b', 'a', 'a'],
            ]
            .map((row) => row.map((id) => GamePosition(playerId: id)).toList())
            .toList();
    expect(game.checkWin(), isTrue);
    expect(game.events.single, isA<GameDrawEvent>());
  });

  test('occupied or out-of-range moves do not change the turn', () async {
    final game = PassNPlayGame(settings: GameSettings(boardSize: 3))
      ..onGameStart();
    final bloc = GameBloc(GameState(game));
    addTearDown(bloc.close);
    final first = game.currentPlayer;
    final moved = bloc.stream.firstWhere((s) => s is PlayerMoveState);
    bloc.add(Move(row: 0, column: 0));
    await moved;
    final second = game.currentPlayer;
    expect(second, isNot(first));
    bloc.add(Move(row: 0, column: 0));
    bloc.add(Move(row: -1, column: 0));
    bloc.add(Move(row: 3, column: 0));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(game.currentPlayer, same(second));
    expect(game.board[0][0].playerId, first!.playerId);
  });

  test('settled rounds reject further moves and duplicate results', () async {
    final game = PassNPlayGame(settings: GameSettings(boardSize: 3))
      ..onGameStart();
    final bloc = GameBloc(GameState(game));
    addTearDown(bloc.close);
    final settled = bloc.stream.firstWhere((s) => s is GameDrawState);
    bloc.add(GameDrawEvent());
    await settled;
    bloc.add(Move(row: 0, column: 0));
    bloc.add(
      GameOverEvent(
        winner: game.player1!,
        gameOverRow: 0,
        gameOverColumn: null,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(bloc.state, isA<GameDrawState>());
    expect(game.board[0][0].isBlank, isTrue);
  });
}
