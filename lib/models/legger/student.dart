class Student {
  final String id;
  final String name;
  final String nisn; // opsional, bisa kosong

  Student({
    required this.id,
    required this.name,
    this.nisn = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'nisn': nisn,
      };

  factory Student.fromMap(Map<String, dynamic> map, String docId) {
    return Student(
      id: docId,
      name: map['name'] ?? '',
      nisn: map['nisn'] ?? '',
    );
  }
}
