import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  Future<List<Task>>? _allTasksFuture;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TaskProvider>();
    _titleController = TextEditingController(text: provider.draftTitle);
    _descController = TextEditingController(text: provider.draftDescription);
    _allTasksFuture = ApiService().fetchTasks();

    _titleController.addListener(() {
      provider.updateDraft(title: _titleController.text);
    });
    _descController.addListener(() {
      provider.updateDraft(description: _descController.text);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isEditing = provider.draftId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'New Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Due Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due Date *'),
                subtitle: Text(
                  provider.draftDueDate != null
                      ? provider.draftDueDate!.toLocal().toString().split(
                          ' ',
                        )[0]
                      : 'Select a date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: provider.draftDueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    provider.updateDraft(dueDate: picked);
                  }
                },
              ),
              if (provider.draftDueDate == null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Due date is required',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<String>(
                initialValue: provider.draftStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ['To-Do', 'In Progress', 'Done']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.updateDraft(status: value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Blocked By Dropdown
              FutureBuilder<List<Task>>(
                future: _allTasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
                  
                  final allTasks = snapshot.data ?? provider.tasks;
                  final availableBlockers = allTasks
                      .where((t) => t.id != provider.draftId && t.status != 'Done')
                      .toList();

                  int? safeBlockedById = provider.draftBlockedById;
                  if (safeBlockedById != null &&
                      !availableBlockers.any((t) => t.id == safeBlockedById)) {
                    safeBlockedById = null;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (provider.draftBlockedById != null) {
                        provider.updateDraft(blockedById: null);
                      }
                    });
                  }

                  return DropdownButtonFormField<int?>(
                    initialValue: safeBlockedById,
                    decoration: const InputDecoration(
                      labelText: 'Blocked By (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...availableBlockers.map(
                        (task) => DropdownMenuItem<int?>(
                          value: task.id,
                          child: Text(task.title),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      provider.updateDraft(blockedById: value);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Recurring Toggle
              SwitchListTile(
                title: const Text('Recurring Task'),
                contentPadding: EdgeInsets.zero,
                value: provider.draftIsRecurring,
                onChanged: (value) {
                  provider.updateDraft(isRecurring: value);
                  if (value && provider.draftRecurrenceType == null) {
                    provider.updateDraft(recurrenceType: 'Daily');
                  }
                },
              ),

              if (provider.draftIsRecurring)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: provider.draftRecurrenceType ?? 'Daily',
                    decoration: const InputDecoration(
                      labelText: 'Recurrence Type',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Daily', 'Weekly']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.updateDraft(recurrenceType: value);
                      }
                    },
                  ),
                ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      provider.draftDueDate != null) {
                    final task = Task(
                      id: provider.draftId ?? 0,
                      title: provider.draftTitle,
                      description: provider.draftDescription,
                      dueDate: provider.draftDueDate!,
                      status: provider.draftStatus,
                      blockedById: provider.draftBlockedById,
                      isRecurring: provider.draftIsRecurring,
                      recurrenceType: provider.draftIsRecurring
                          ? provider.draftRecurrenceType
                          : null,
                      createdAt: DateTime.now(),
                    );

                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    try {
                      if (isEditing) {
                        await provider.updateTask(task);
                      } else {
                        await provider.addTask(task);
                      }
                      
                      if (!mounted) return;
                      provider.clearDraft(); // Clear ONLY on save success
                      navigator.pop();
                    } catch (e) {
                      if (!mounted) return;
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Failed to save task: $e')),
                      );
                    }
                  } else if (provider.draftDueDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a Due Date')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditing ? 'Update Task' : 'Save Task',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
