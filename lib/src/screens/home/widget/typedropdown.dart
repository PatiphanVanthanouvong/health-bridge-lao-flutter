class DropdownItem {
  final String id;
  final String name;

  DropdownItem({required this.id, required this.name});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DropdownItem && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return name;
  }
}

final test1 = DropdownItem(id: '0', name: 'ປະເພດທັງໝົດ');
final test2 = DropdownItem(id: '0', name: 'ປະເພດທັງໝົດ');





