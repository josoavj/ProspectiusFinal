import '../../models/task.dart';

abstract class ITaskRepository {
  Future<List<Task>> getTasksByProspect(int prospectId);
  Future<void> createTask(Task task);
  Future<void> updateTaskStatus(int taskId, bool isCompleted);
  Future<void> deleteTask(int taskId);
}
