import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game_x_o/core/app.dart';
import 'package:game_x_o/core/services/sound_service.dart';
import 'package:game_x_o/features/game/screens/maze_screen.dart';
import 'package:game_x_o/features/game/widgets/tile_box_widget.dart';
import 'package:game_x_o/features/settings/screens/settings_screen.dart';
import 'package:game_x_o/utils/local_storage.dart';

void main() {
  testWidgets(
    'boots without Firebase, opens settings and plays a local match',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'soundEnabled': false});
      await LocalStorage.init();
      await SoundService.setEnabled(false);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(
        find.text('Offline mode • Play without an account'),
        findsOneWidget,
      );
      expect(find.text('Play Now'), findsNWidgets(2));

      final context = tester.element(find.text('game_x_o'));
      Navigator.of(context).pushNamed('/settings');
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.byType(SettingsScreen))).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Play Now').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(find.byType(TileBoxWidget), findsNWidgets(9));
      final game = tester.widget<MazeScreen>(find.byType(MazeScreen)).game;
      final first = game.currentPlayer;
      for (final cell in [0, 3, 1, 4, 2]) {
        await tester.tap(find.byType(TileBoxWidget).at(cell));
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Game Over'), findsOneWidget);
      expect(
        game.board[0].every((cell) => cell.playerId == first!.playerId),
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();
      final restarted = tester.widget<MazeScreen>(find.byType(MazeScreen)).game;
      expect(
        restarted.board.expand((row) => row).every((cell) => cell.isBlank),
        isTrue,
      );
      for (final cell in [0, 3, 1, 4, 2]) {
        await tester.tap(find.byType(TileBoxWidget).at(cell));
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Play Now'), findsNWidgets(2));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
