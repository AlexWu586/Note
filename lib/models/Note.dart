class Note {
  String title;
  String description;
  String date;
  String time;
  Note(
      {required this.title,
      required this.description,
      required this.date,
      required this.time});

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "date": date,
      "time": time,
    };
  }
}
