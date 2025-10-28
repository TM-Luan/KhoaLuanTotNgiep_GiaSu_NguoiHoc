// data/models/giasu.dart

class Tutor {
  final String name;
  final String? subject; // Đổi thành nullable hoặc gán giá trị mặc định
  final double rating;
  final String image;
  final String? diaChi; // Thêm các trường bạn muốn hiển thị

  Tutor({
    required this.name,
    this.subject,
    required this.rating,
    required this.image,
    this.diaChi,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['AnhDaiDien'] as String? ?? 'https://i.pravatar.cc/300?img=${json['GiaSuID'] ?? 1}';

    return Tutor(
      name: json['HoTen'] as String,
      subject: json['MonHoc'] as String? ?? 'Chuyên môn chưa cập nhật', 
      rating: (json['DiemSo'] ?? 0).toDouble(),
      image: imageUrl,
      diaChi: json['DiaChi'] as String?,
    );
  }
}