import 'package:flutter/material.dart';
import '../models/custom_field.dart';
import '../domain/repositories/i_custom_field_repository.dart';
import '../utils/exception_handler.dart';
import '../core/di/service_locator.dart';

class CustomFieldProvider extends ChangeNotifier {
  final ICustomFieldRepository _repository;
  
  List<CustomField> _fields = [];
  final Map<int, List<CustomFieldValue>> _prospectValues = {};
  bool _isLoading = false;
  String? _error;

  List<CustomField> get fields => _fields;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CustomFieldProvider({ICustomFieldRepository? repository}) 
      : _repository = repository ?? sl.customFieldRepository;

  Future<void> loadFields() async {
    _isLoading = true;
    notifyListeners();
    try {
      _fields = await _repository.getCustomFields();
      _error = null;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadValuesForProspect(int prospectId) async {
    try {
      final values = await _repository.getValuesByProspect(prospectId);
      _prospectValues[prospectId] = values;
      notifyListeners();
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
    }
  }

  List<CustomFieldValue> getValues(int prospectId) => _prospectValues[prospectId] ?? [];

  Future<bool> saveValue(int prospectId, int fieldId, String value) async {
    try {
      await _repository.saveCustomFieldValue(prospectId, fieldId, value);
      await loadValuesForProspect(prospectId);
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return false;
    }
  }

  Future<bool> createField(String name, CustomFieldType type) async {
    try {
      await _repository.createCustomField(name, type);
      await loadFields();
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return false;
    }
  }
}
