import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';

class ComplaintFormScreen extends StatefulWidget {
  // ✨ BƯỚC 1: THÊM CÁC THAM SỐ NÀY ĐỂ NHẬN ID ✨
  final int? lopId;
  final int? giaoDichId;

  const ComplaintFormScreen({
    super.key,
    this.lopId, // ID lớp học được truyền vào
    this.giaoDichId, // ID giao dịch được truyền vào
  });

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final TextEditingController noiDungController = TextEditingController();
  bool isSubmitting = false;
  String _pageTitle = "Trợ giúp / Khiếu nại";
  String _hintText = "Nhập nội dung khiếu nại chi tiết...";

  @override
  void initState() {
    super.initState();
    // Tự động cập nhật tiêu đề dựa trên ID được truyền vào
    if (widget.lopId != null) {
      _pageTitle = "Khiếu nại Lớp học";
      _hintText = "Nhập nội dung khiếu nại về lớp học này...";
    } else if (widget.giaoDichId != null) {
      _pageTitle = "Khiếu nại Giao dịch";
      _hintText = "Nhập nội dung khiếu nại về giao dịch này...";
    }
  }

  @override
  void dispose() {
    noiDungController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (noiDungController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập nội dung khiếu nại")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final res = await ApiService().post(
        '/khieunai',
        data: {
          "NoiDung": noiDungController.text.trim(),
          
          // ✨ BƯỚC 2: GỬI ID ĐI TRONG API CALL ✨
          "LopYeuCauID": widget.lopId, 
          "GiaoDichID": widget.giaoDichId,
        },
      );

      if (!mounted) return; 

      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gửi khiếu nại thành công!")),
        );
        // Đóng màn hình khiếu nại sau khi gửi thành công
        Navigator.of(context).pop(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${res.message}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi gửi khiếu nại: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle), // Dùng tiêu đề động
        backgroundColor: Colors.lightBlue,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nội dung khiếu nại",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noiDungController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: _hintText, // Dùng hint text động
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  isSubmitting ? "Đang gửi..." : "Gửi khiếu nại",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: isSubmitting ? null : _submitComplaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}