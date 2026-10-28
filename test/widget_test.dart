import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/main.dart';

void main() {
  testWidgets('StudyFlow app can be created', (tester) async {
    expect(const StudyFlowApp(), isA<StudyFlowApp>());
  });
}
