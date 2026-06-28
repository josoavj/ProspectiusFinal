import '../../domain/repositories/i_task_repository.dart';
import '../../models/task.dart';
import '../../services/mysql_service.dart';
import '../../core/constants/sql_queries.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final MySQLService _mysqlService;

  TaskRepositoryImpl(this._mysqlService);

  @override
  Future<List<Task>> getTasksByProspect(int prospectId) async {
    final results = await _mysqlService.query(
      SqlQueries.selectTasksByProspectId,
      [prospectId],
    );

    return results.map((row) => Task.fromJson(row.fields)).toList();
  }

  @override
  Future<void> createTask(Task task) async {
    await _mysqlService.query(
      SqlQueries.insertTask,
      [
        task.idProspect,
        task.title,
        task.description,
        task.dueDate.toIso8601String(),
        task.isCompleted ? 1 : 0,
      ],
    );
  }

  @override
  Future<void> updateTaskStatus(int taskId, bool isCompleted) async {
    await _mysqlService.query(
      SqlQueries.updateTaskStatus,
      [isCompleted ? 1 : 0, taskId],
    );
  }

  @override
  Future<void> deleteTask(int taskId) async {
    await _mysqlService.query(
      'DELETE FROM taches WHERE id_tache = ?',
      [taskId],
    );
  }
}
