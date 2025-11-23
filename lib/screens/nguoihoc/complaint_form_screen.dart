import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_service.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/api/api_config.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/complaint_model.dart';

class ComplaintFormScreen extends StatefulWidget {
  final int? lopId;
  final int? giaoDichId;

  const ComplaintFormScreen({super.key, this.lopId, this.giaoDichId});

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final TextEditingController noiDungController = TextEditingController();
  bool isSubmitting = false;
  bool isLoadingList = true;
  
  // Biến kiểm tra xem đã khiếu nại chưa
  bool _hasExistingComplaint = false; // <--- MỚI

  bool isEditing = false;
  int? editingId; 

  String _pageTitle = "Trợ giúp / Khiếu nại";
  String _hintText = "Mô tả chi tiết vấn đề bạn gặp phải...";
  
  List<ComplaintModel> _serverComplaints = [];

  @override
  void initState() {
    super.initState();
    if (widget.lopId != null) {
      _pageTitle = "Khiếu nại Lớp học";
      _hintText = "Vui lòng mô tả vấn đề về lớp học này...";
    } else if (widget.giaoDichId != null) {
      _pageTitle = "Khiếu nại Giao dịch";
      _hintText = "Vui lòng mô tả vấn đề về giao dịch này...";
    }
    _fetchDataFromServer();
  }

  Future<void> _fetchDataFromServer() async {
    try {
      if (!mounted) return;
      setState(() => isLoadingList = true);
      
      final res = await ApiService().get<List<ComplaintModel>>(
        ApiConfig.khieuNai, 
        fromJsonT: (json) => (json as List).map((e) => ComplaintModel.fromJson(e)).toList(),
      );

      if (mounted && res.success && res.data != null) {
        // LOGIC KIỂM TRA: Đã có khiếu nại cho lớp này chưa?
        bool exists = false;
        if (widget.lopId != null) {
          // Tìm xem có cái nào trùng lopId không
          exists = res.data!.any((item) => item.lopId == widget.lopId);
        }

        setState(() {
          _serverComplaints = res.data!;
          _hasExistingComplaint = exists; // <--- Cập nhật trạng thái
        });
      }
    } catch (e) {
      debugPrint("Lỗi: $e");
    } finally {
      if (mounted) setState(() => isLoadingList = false);
    }
  }

  Future<void> _submitComplaint() async {
    if (noiDungController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập nội dung")));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final api = ApiService();
      final dynamic res;

      if (isEditing && editingId != null) {
        res = await api.put(
          '${ApiConfig.khieuNai}/$editingId',
          data: { "NoiDung": noiDungController.text.trim() },
        );
      } else {
        res = await api.post(
          ApiConfig.khieuNai,
          data: {
            "NoiDung": noiDungController.text.trim(),
            "LopYeuCauID": widget.lopId,
            "GiaoDichID": widget.giaoDichId,
          },
        );
      }

      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? "Thành công!"), backgroundColor: Colors.green),
        );
        noiDungController.clear();
        setState(() {
          isEditing = false;
          editingId = null;
        });
        await _fetchDataFromServer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> _deleteComplaint(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn muốn thu hồi khiếu nại này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Thu hồi", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final res = await ApiService().delete('${ApiConfig.khieuNai}/$id');
      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thu hồi thành công")));
        _fetchDataFromServer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _startEdit(ComplaintModel item) {
    setState(() {
      isEditing = true;
      editingId = item.id;
      noiDungController.text = item.noiDung;
    });
  }

  bool _canAction(ComplaintModel item) {
    if (item.trangThai != 'TiepNhan') return false;
    try {
      final DateTime ngayTao = DateTime.parse(item.ngayTao);
      final int diff = DateTime.now().difference(ngayTao).inMinutes.abs();
      return diff <= 5; // Giới hạn 5 phút
    } catch (e) {
      return false;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'TiepNhan': return Colors.orange;
      case 'DangXuLy': return Colors.blue;
      case 'DaGiaiQuyet': return Colors.green;
      case 'TuChoi': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'TiepNhan': return 'Đang tiếp nhận';
      case 'DangXuLy': return 'Đang xử lý';
      case 'DaGiaiQuyet': return 'Đã giải quyết';
      case 'TuChoi': return 'Đã từ chối';
      default: return status;
    }
  }

  String _formatDate(String rawDate) {
    try {
      final DateTime date = DateTime.parse(rawDate).toLocal();
      return DateFormat('HH:mm dd/MM/yyyy').format(date);
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_pageTitle, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 18)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade100, height: 1)),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDataFromServer,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === LOGIC ẨN HIỆN FORM NHẬP ===
              // Nếu đã có khiếu nại (và không phải đang sửa) -> Hiện thông báo chặn
              if (_hasExistingComplaint && !isEditing) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, size: 48, color: Colors.orange.shade700),
                      const SizedBox(height: 16),
                      Text(
                        "Bạn đã gửi khiếu nại về lớp này rồi",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Vui lòng chờ Admin phản hồi. Bạn có thể xem trạng thái hoặc chỉnh sửa (nếu còn hạn) ở danh sách bên dưới.",
                        style: TextStyle(fontSize: 14, color: Colors.orange.shade900),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ] else ...[
                // Nếu chưa có -> Hiện form nhập bình thường
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEditing ? "Chỉnh sửa nội dung" : "Nội dung khiếu nại", 
                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    if (isEditing) 
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isEditing = false;
                            editingId = null;
                            noiDungController.clear();
                          });
                        }, 
                        icon: const Icon(Icons.close, size: 16, color: Colors.red),
                        label: const Text("Hủy sửa", style: TextStyle(color: Colors.red)),
                      )
                  ],
                ),
                const SizedBox(height: 8),
                
                Container(
                  decoration: BoxDecoration(
                    color: isEditing ? Colors.blue.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isEditing ? Colors.blue.shade200 : Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: noiDungController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: _hintText,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditing ? Colors.blue : AppColors.primary, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isEditing ? "Cập nhật ngay" : "Gửi yêu cầu", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 30),
              ],

              const Divider(thickness: 1),
              
              // Danh sách lịch sử
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("Lịch sử khiếu nại [${_serverComplaints.length}]", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),

              if (isLoadingList)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (_serverComplaints.isEmpty)
                 Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Chưa có dữ liệu", style: TextStyle(color: Colors.grey.shade500))))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _serverComplaints.length,
                  itemBuilder: (context, index) {
                    final item = _serverComplaints[index];
                    final bool showActions = _canAction(item);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: showActions ? Colors.blue.shade100 : Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 5)
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(item.trangThai).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatusText(item.trangThai), 
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusColor(item.trangThai))
                                ),
                              ),
                              Text(
                                _formatDate(item.ngayTao),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(item.noiDung, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                          
                          if (showActions) ...[
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Còn hiệu lực chỉnh sửa", 
                                  style: TextStyle(fontSize: 10, color: Colors.blue.shade300, fontStyle: FontStyle.italic)
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () => _startEdit(item),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(children: [
                                      Icon(Icons.edit, size: 16, color: Colors.blue),
                                      SizedBox(width: 4),
                                      Text("Sửa", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ]),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () => _deleteComplaint(item.id),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(children: [
                                      Icon(Icons.delete, size: 16, color: Colors.red),
                                      SizedBox(width: 4),
                                      Text("Thu hồi", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ]),
                                  ),
                                ),
                              ],
                            )
                          ]
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}