class Participant {
  Participant({required this.id, required this.name});

  final String id;
  final String name;

  Participant copyWith({String? id, String? name}) {
    return Participant(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(id: json['id'] as String, name: json['name'] as String);
  }
}
