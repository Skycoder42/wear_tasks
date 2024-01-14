import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../expressions/expression.dart';
import '../expressions/static_expressions.dart';

part 'expression_repository.g.dart';

@riverpod
ExpressionRepository expressionRepository(ExpressionRepositoryRef ref) =>
    ExpressionRepository();

class ExpressionRepository {
  Stream<Expression> loadExpressions() =>
      Stream.fromIterable(staticExpressions);
}
