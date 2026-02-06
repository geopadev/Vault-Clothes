import 'package:flutter_test/flutter_test.dart';
import 'package:vault_clothes/core/viewmodels/base_view_model.dart';

class TestViewModel extends BaseViewModel {
  Future<void> runSuccess() async {
    await runSafe(() async {
      await Future.delayed(const Duration(milliseconds: 10));
    });
  }

  Future<void> runFailure() async {
    await runSafe(() async {
      throw Exception('Oops');
    });
  }
}

void main() {
  group('BaseViewModel', () {
    late TestViewModel viewModel;

    setUp(() {
      viewModel = TestViewModel();
    });

    test('initial state is correct', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      expect(viewModel.hasError, false);
    });

    test('runSafe handles success correctly', () async {
      final future = viewModel.runSuccess();
      expect(viewModel.isLoading, true); // Should be loading immediately
      await future;
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
    });

    test('runSafe handles error correctly', () async {
      await viewModel.runFailure();
      expect(viewModel.isLoading, false);
      expect(viewModel.hasError, true);
      expect(viewModel.error, contains('Oops'));
    });
  });
}
