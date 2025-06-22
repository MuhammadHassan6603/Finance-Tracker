import 'package:flutter/material.dart';

import '../../../../core/models/collaborator.dart';
import '../../../../core/utils/helpers.dart';

class BudgetItem extends StatelessWidget {
  const BudgetItem({
    super.key,
    required this.name,
    required this.icon,
    required this.limit,
    required this.spent,
    required this.remaining,
    required this.isShared,
    required this.collaborators,
    required this.onEdit,
    required this.onShare,
    required this.onDelete,
  });

  final String name;
  final IconData icon;
  final double limit;
  final double spent;
  final double remaining;
  final bool isShared;
  final List<dynamic> collaborators;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final List<Collaborator> typedCollaborators =
        collaborators.map((c) => c as Collaborator).toList();

    final progress = spent / limit;

    return Container(
      padding: const EdgeInsets.all(16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit();
                              break;
                            // case 'share':
                            //   onShare();
                            //   break;
                            case 'delete':
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit Budget'),
                          ),
                          // const PopupMenuItem(
                          //   value: 'share',
                          //   child: Text('Share Budget'),
                          // ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete Budget'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Limit: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${Helpers.storeCurrency(context)}${limit.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Spent: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${Helpers.storeCurrency(context)}${spent.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Remaining: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${Helpers.storeCurrency(context)}${remaining.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress > 0.9 ? Colors.red : Colors.green,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  if (isShared && typedCollaborators.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildCollaboratorAvatars(typedCollaborators),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaboratorAvatars(List<Collaborator> collaborators) {
    return Stack(
      children: [
        ...collaborators.take(3).map((c) => CircleAvatar(
              backgroundImage: NetworkImage(c.avatarUrl),
              radius: 12,
            )),
        if (collaborators.length > 3)
          CircleAvatar(
            radius: 12,
            child: Text('+${collaborators.length - 3}'),
          ),
      ],
    );
  }
}
