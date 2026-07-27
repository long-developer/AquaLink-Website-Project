import 'package:flutter_test/flutter_test.dart';
import 'package:project_aqualink/app/providers/app_data_provider.dart';

void main() {
  test('virtual shrimp account replies to simple questions', () async {
    final provider = AppDataProvider();

    provider.sendUserMessage('nguyenthuantom', text: 'Chào bạn');

    await Future.delayed(const Duration(milliseconds: 1100));

    final messages = provider.getChatThread('nguyenthuantom');
    expect(
      messages.any(
        (message) =>
            message['sender'] == 'nguyenthuantom' &&
            (message['text'] as String).toLowerCase().contains('tôm'),
      ),
      isTrue,
    );

    provider.dispose();
  });
}
