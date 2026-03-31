import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_smooth_corners/auto_smooth_corners.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isBlocked;
  final int index;

  const TaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onTap,
    required this.onDelete,
    this.isBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Using semantic colors defined by the theme where possible
    Color statusColor;
    switch (task.status) {
      case 'Done':
        statusColor = Colors.green.shade600; // Semantic success
        break;
      case 'In Progress':
        statusColor = colorScheme.tertiary; // Accent/Tertiary for highlights
        break;
      case 'To-Do':
      default:
        statusColor = colorScheme.secondary; // Secondary for chips/supporting
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Standard spacing 2 (16 horizontal padding)
      elevation: isBlocked ? 0 : 2,
      color: isBlocked ? colorScheme.outline.withAlpha(20) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isBlocked
            ? BorderSide(color: colorScheme.outline.withAlpha(76), width: 1)
            : BorderSide(color: colorScheme.outline.withAlpha(38), width: 1),
      ),
      child: Opacity(
        opacity: isBlocked ? 0.6 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isBlocked)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.lock,
                                size: 16,
                                color: colorScheme.outline,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              '${index + 1}. ${task.title}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: task.status == 'Done'
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.status == 'Done' 
                                    ? colorScheme.outline 
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        Text(
                          task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurface.withAlpha(178),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.dueDate.toLocal().toString().split(' ')[0],
                            style: TextStyle(
                              color: colorScheme.outline,
                              fontSize: 12,
                            ),
                          ),
                          if (task.isRecurring) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.repeat,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              task.recurrenceType ?? '',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: ShapeDecoration(
                        color: statusColor,
                        shape: AutoSmoothRectangleBorder(
                          smoothingFactor: 1.0,
                          autoSmoothBorderRadius: const AutoSmoothBorderRadius.all(0.35),
                          side: BorderSide(
                            color: colorScheme.outline.withAlpha(80), 
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Text(
                        task.status,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          shadows: [], // ensuring absolutely no text shadow/gradient
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
