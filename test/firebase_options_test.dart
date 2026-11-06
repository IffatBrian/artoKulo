import 'package:flutter_test/flutter_test.dart';
import 'package:tenang_finance/firebase_options.dart';

void main() {
  test('Android and web Firebase apps use the configured project', () {
    expect(DefaultFirebaseOptions.android.projectId, 'sgtenang-130209');
    expect(DefaultFirebaseOptions.web.projectId, 'sgtenang-130209');
    expect(DefaultFirebaseOptions.android.appId, contains(':android:'));
    expect(DefaultFirebaseOptions.web.appId, contains(':web:'));
  });
}
