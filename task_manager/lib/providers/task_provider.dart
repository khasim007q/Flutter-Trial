import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  String _searchQuery = '';
  String _statusFilter = 'All';

  // Draft state for new/edit task
  int? draftId;
  String draftTitle = '';
  String draftDescription = '';
  DateTime? draftDueDate;
  String draftStatus = 'To-Do';
  int? draftBlockedById;
  bool draftIsRecurring = false;
  String? draftRecurrenceType;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _apiService.fetchTasks(
        search: _searchQuery,
        status: _statusFilter,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadTasks();
  }

  void setFilter(String status) {
    _statusFilter = status;
    loadTasks();
  }

  Future<void> addTask(Task task) async {
    try {
      await _apiService.createTask(task);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _apiService.updateTask(task);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _apiService.deleteTask(id);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Draft Management
  void loadDraftFromTask(Task task) {
    draftId = task.id;
    draftTitle = task.title;
    draftDescription = task.description ?? '';
    draftDueDate = task.dueDate;
    draftStatus = task.status;
    draftBlockedById = task.blockedById;
    draftIsRecurring = task.isRecurring;
    draftRecurrenceType = task.recurrenceType;
    notifyListeners();
  }

  void clearDraft() {
    draftId = null;
    draftTitle = '';
    draftDescription = '';
    draftDueDate = null;
    draftStatus = 'To-Do';
    draftBlockedById = null;
    draftIsRecurring = false;
    draftRecurrenceType = null;
    notifyListeners();
  }

  void updateDraft({
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    int? blockedById,
    bool? isRecurring,
    String? recurrenceType,
  }) {
    if (title != null) draftTitle = title;
    if (description != null) draftDescription = description;
    if (dueDate != null) draftDueDate = dueDate;
    if (status != null) draftStatus = status;
    // blockedById could be intentionally set to null, so we need a different check if we want to support unsetting
    // But for simplicity, we'll just check if it's passed. To unset, we would pass a specific value or use another flag.
    // For this context, checking != null works if we don't unset. Let's add a clearBlockedBy explicitly.
    draftBlockedById = blockedById;
    if (isRecurring != null) draftIsRecurring = isRecurring;
    if (recurrenceType != null) draftRecurrenceType = recurrenceType;
    notifyListeners();
  }

  void setDraftBlockedBy(int? id) {
    draftBlockedById = id;
    notifyListeners();
  }
}
