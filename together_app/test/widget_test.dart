import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:together_app/main.dart';
import 'package:together_app/providers/together_state.dart';

void main() {
  testWidgets('Together app renders smoke test', (WidgetTester tester) async {
    final state = TogetherState();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TogetherState>.value(value: state),
        ],
        child: const TogetherApp(),
      ),
    );

    // Initial loading or welcome screen
    await tester.pump();
    expect(find.byType(TogetherApp), findsOneWidget);
  });
}
