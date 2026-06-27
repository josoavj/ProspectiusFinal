import 'package:flutter/material.dart';
import '../models/task.dart';
import '../domain/repositories/i_task_repository.dart';
import '../utils/exception_handler.dart';
import '../core/di/service_locator.dart';

class TaskProvider extends ChangeNotifier {
  final ITaskRepository _repository;
  
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TaskProvider({ITaskRepository? repository}) 
      : _repository = repository ?? sl.taskRepository;

  Future<void> loadTasks(int prospectId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _tasks = await _repository.getTasksByProspect(prospectId);
      _error = null;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(Task task) async {
    try {
      await _repository.createTask(task);
      await loadTasks(task.idProspect);
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskStatus(Task task) async {
    try {
      await _repository.updateTaskStatus(task.id, !task.isCompleted);
      await loadTasks(task.idProspect);
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int taskId, int prospectId) async {
    try {
      await _repository.deleteTask(taskId);
      await loadTasks(prospectId);
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      notifyListeners();
      return false;
    }
  }
}
