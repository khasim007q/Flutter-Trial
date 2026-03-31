import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_smooth_corners/auto_smooth_corners.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TaskProvider>().loadTasks(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                // Debounce could be added here for better performance
                context.read<TaskProvider>().setSearchQuery(value);
              },
            ),
          ),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Filter options
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: ['All', 'To-Do', 'In Progress', 'Done'].map((
                    status,
                  ) {
                    final isSelected = provider.statusFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(
                          status,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.secondary,
                            shadows: const [],
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => provider.setFilter(status),
                        backgroundColor: Colors.white,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        showCheckmark: false,
                        shape: OutlinedSquircle(
                          smoothingFactor: 1.0,
                          autoSmoothBorderRadius:
                              const AutoSmoothBorderRadius.all(0.35),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withAlpha(80),
                            width: 1.0,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.tasks.isEmpty
                    ? const Center(child: Text('No tasks found'))
                    : RefreshIndicator(
                        onRefresh: provider.loadTasks,
                        child: ListView.builder(
                          itemCount: provider.tasks.length,
                          itemBuilder: (context, index) {
                            final task = provider.tasks[index];
                            // Check if task is blocked and blocker is not done
                            bool isBlocked = false;
                            if (task.blockedById != null) {
                              // Find the blocking task to check its status
                              try {
                                final blocker = provider.tasks.firstWhere(
                                  (t) => t.id == task.blockedById,
                                );
                                isBlocked = blocker.status != 'Done';
                              } catch (e) {
                                isBlocked = false;
                              }
                            }

                            return TaskCard(
                              task: task,
                              index: index,
                              isBlocked: isBlocked,
                              onTap: () {
                                provider.loadDraftFromTask(task);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TaskFormScreen(),
                                  ),
                                );
                              },
                              onDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Task'),
                                    content: const Text(
                                      'Are you sure you want to delete this task?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          provider.deleteTask(task.id);
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.read<TaskProvider>().draftId != null) {
            context.read<TaskProvider>().clearDraft();
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class OutlinedSquircle extends OutlinedBorder {
  final double smoothingFactor;
  final AutoSmoothBorderRadius autoSmoothBorderRadius;

  const OutlinedSquircle({
    this.smoothingFactor = 1.0,
    required this.autoSmoothBorderRadius,
    super.side,
  });

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return OutlinedSquircle(
      smoothingFactor: smoothingFactor,
      autoSmoothBorderRadius: autoSmoothBorderRadius,
      side: side ?? this.side,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return AutoSmoothRectangleBorder(
      smoothingFactor: smoothingFactor,
      autoSmoothBorderRadius: autoSmoothBorderRadius,
      side: side,
    ).getInnerPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return AutoSmoothRectangleBorder(
      smoothingFactor: smoothingFactor,
      autoSmoothBorderRadius: autoSmoothBorderRadius,
      side: side,
    ).getOuterPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    AutoSmoothRectangleBorder(
      smoothingFactor: smoothingFactor,
      autoSmoothBorderRadius: autoSmoothBorderRadius,
      side: side,
    ).paint(canvas, rect, textDirection: textDirection);
  }

  @override
  ShapeBorder scale(double t) {
    return OutlinedSquircle(
      smoothingFactor: smoothingFactor,
      autoSmoothBorderRadius: autoSmoothBorderRadius,
      side: side.scale(t),
    );
  }
}
