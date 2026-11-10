import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game_x_o/main.dart' as app;
import 'package:game_x_o/features/game/widgets/tile_box_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launch and complete a local match on a device', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('soundEnabled', false);
    await preferences.setString('languageCode', 'en');
    await app.main([]);
    await tester.pumpAndSettle();
    expect(find.text('Play Now'), findsNWidgets(2));
    await tester.tap(find.text('Play Now').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.byType(TileBoxWidget), findsNWidgets(9));
    for (final cell in [0, 3, 1, 4, 2]) {
      await tester.tap(find.byType(TileBoxWidget).at(cell));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Game Over'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Play Now'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
