import 'package:game_x_o/core/constants/runtime_config.dart';
import 'package:game_x_o/core/constants/settings.dart';
import 'dart:math';

import 'package:game_x_o/utils/app_icons.dart';
import 'package:game_x_o/features/game/logic/game.dart';
import 'package:game_x_o/core/services/firebase_service.dart';
import 'package:game_x_o/features/game/models/player_model.dart';

// Local two-player mode: both players share one device, so there's no self
// player, no AI, and no server round-trip on a move.
class PassNPlayGame extends Game {
  PassNPlayGame({required super.settings});

  @override
  void onGameStart() async {
    super.onGameStart();

    final skin = RuntimeConfig.offlineMode
        ? AppSettings.defaultSkin
        : DatabaseService.instance.activeSkin;
    player1 = Player(
      playerId: '0',
      skinX: skin.skinX,
      name: 'User1',
      skinO: skin.skinO,
      activeSkinType: 'O',
      playerProfile: AppIcons.dora1,
    );

    player2 = Player(
      playerId: '1',
      skinX: skin.skinX,
      name: 'User2',
      skinO: skin.skinO,
      activeSkinType: 'X',
      playerProfile: AppIcons.dora1,
    );
    currentPlayer = [player1, player2][Random().nextInt(2)];
  }

  @override
  void onUpdate(int row, int column, Player player) async {}

  @override
  bool restrictedMoves = false;
}
