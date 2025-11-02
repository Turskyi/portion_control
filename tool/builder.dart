import 'package:build/build.dart';

/// Builder that copies the (hidden, `build_to: cache`) output of
/// `build_web_compilers` into `web/` (visible, this builder is defined with
/// `build_to: source`).
class CopyCompiledJs extends Builder {
  CopyCompiledJs([BuilderOptions? options]);

  @override
  Future<void> build(BuildStep buildStep) async {
    final AssetId inputId = AssetId(
      buildStep.inputId.package,
      'web/worker.dart.js',
    );
    final List<int> input = await buildStep.readAsBytes(inputId);
    await buildStep.writeAsBytes(buildStep.allowedOutputs.single, input);
  }

  @override
  Map<String, List<String>> get buildExtensions => <String, List<String>>{
    r'$package$': <String>['web/drift_worker.js'],
  };
}
