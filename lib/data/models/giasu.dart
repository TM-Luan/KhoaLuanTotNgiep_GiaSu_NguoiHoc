class Tutor {
  final String name;
  final String subject;
  final double rating;
  final String image;

  Tutor({
    required this.name,
    required this.subject,
    required this.rating,
    required this.image,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      image: json['image'] ?? '',
    );
  }
}
