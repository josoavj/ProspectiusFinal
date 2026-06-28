import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prospectius/providers/task_provider.dart';
import 'package:prospectius/domain/repositories/i_task_repository.dart';
import 'package:prospectius/models/task.dart';

class MockTaskRepository extends Mock implements ITaskRepository {}

void main() {
  late TaskProvider taskProvider;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    taskProvider = TaskProvider(repository: mockRepository);
  });

  group('TaskProvider Tests', () {
    final tTask = Task(
      id: 1,
      idProspect: 1,
      title: 'Appeler client',
      description: 'Relance devis',
      dueDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    test('loadTasks should update list', () async {
      when(() => mockRepository.getTasksByProspect(any()))
          .thenAnswer((_) async => [tTask]);

      await taskProvider.loadTasks(1);

      expect(taskProvider.tasks, [tTask]);
      expect(taskProvider.isLoading, false);
    });

    test('toggleTaskStatus should call repository and reload', () async {
      when(() => mockRepository.updateTaskStatus(any(), any()))
          .thenAnswer((_) async => {});
      when(() => mockRepository.getTasksByProspect(any()))
          .thenAnswer((_) async => [tTask.copyWith(isCompleted: true)]);

      final result = await taskProvider.toggleTaskStatus(tTask);

      expect(result, true);
      verify(() => mockRepository.updateTaskStatus(tTask.id, true)).called(1);
    });
  });
}
