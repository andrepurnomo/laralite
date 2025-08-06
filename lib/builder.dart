import 'package:build/build.dart';
import 'src/generator/model_generator.dart';

/// Builder for laralite code generation
Builder laraliteBuilder(BuilderOptions options) {
  return LaraliteGenerator();
}
