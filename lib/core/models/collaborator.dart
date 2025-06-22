class Collaborator {
  final String id;
  final String name;
  final String avatarUrl;
  bool isSelected;

  Collaborator({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isSelected = false,
  });
} 