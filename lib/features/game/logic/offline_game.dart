import 'package:game_x_o/core/constants/runtime_config.dart';
import 'package:game_x_o/core/constants/settings.dart';
import 'dart:math';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_x_o/utils/app_icons.dart';
import 'package:game_x_o/commons/models/enums/enums.dart';
import 'package:game_x_o/features/game/logic/dora_ai.dart';
import 'package:game_x_o/features/game/logic/game.dart';
import 'package:game_x_o/core/services/firebase_service.dart';
import 'package:game_x_o/features/auth/blocs/authentication_bloc.dart';
import 'package:game_x_o/features/game/blocs/game_bloc.dart';
import 'package:game_x_o/features/game/models/player_model.dart';

/// Single-player mode against the "Dora" CPU opponent ([TicTacToeAI]).
class OfflineGame extends Game {
  @override
  String get selfPlayerId => player1!.playerId;

  OfflineGame({required super.settings, this.difficulty = Difficulty.hard});

  /// Chosen by the player before the match; controls how sharply Dora plays.
  final Difficulty difficulty;
  final TicTacToeAI ai = TicTacToeAI();
  Timer? _moveTimer;
  @override
  void onGameStart() async {
    super.onGameStart();
    final skin = RuntimeConfig.offlineMode
        ? AppSettings.defaultSkin
        : DatabaseService.instance.activeSkin;
    player1 = Player(
      playerId: '0',
      skinX: skin.skinX,
      name: 'You',
      skinO: skin.skinO,
      activeSkinType: 'O',
      playerProfile:
          getContext()?.read<AuthenticationBloc>().user?.profilePic ?? '',
    );
    player2 = Player(
      playerId: '1',
      skinX: skin.skinX,
      name: 'Dora',
      skinO: skin.skinO,
      activeSkinType: 'X',
      playerProfile: AppIcons.dora1,
    );
    currentPlayer = [player1, player2][Random().nextInt(2)];

    // If Dora wins the coin toss she has to open the game. There's no human
    // move to trigger her through [onUpdate], and `restrictedMoves` locks the
    // board for the human while it's her turn, so kick off her move directly.
    if (currentPlayer == player2) {
      _playDoraMove();
    }
  }

  @override
  void onUpdate(int row, int column, Player player) async {
    // This fires for every applied move, including Dora's own. Only respond to
    // the human's move, otherwise Dora would loop on her own placement.
    if (player == player2) return;
    if (isBoardFull()) return;
    await _playDoraMove();
  }

  /// Computes Dora's best move for the current board and plays it after a short
  /// "thinking" pause. Driven both from the opening (see [onGameStart]) and as
  /// the reply to the human's move (see [onUpdate]).
  Future<void> _playDoraMove() async {
    // Maps each player's id to their mark ('X'/'O'), so the board below can be
    // converted from GamePosition/playerId into the plain mark grid the AI expects.
    final Map markByPlayerId = {
      player1?.playerId: player1!.activeSkinType,
      player2?.playerId: player2!.activeSkinType,
    };

    final int position = ai.getBestMove(
      board
          .map(
            (e) => e
                .map(
                  (e) => e.isBlank ? "" : markByPlayerId[e.playerId!] as String,
                )
                .toList(),
          )
          .toList(),
      settings.boardSize,
      difficulty: difficulty,
    );

    if (position < 0) return;
    final int row = position ~/ settings.boardSize;
    final int column = position % settings.boardSize;
    _moveTimer?.cancel();
    _moveTimer = Timer(
      Duration(milliseconds: 400 + Random().nextInt(800)),
      () => addEvent(Move(row: row, column: column)),
    );
  }

  @override
  void onDispose() => _moveTimer?.cancel();

  @override
  void reset() {
    _moveTimer?.cancel();
    super.reset();
  }

  @override
  bool restrictedMoves = true;
}
