import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/addclass_widgets/basic_info_section.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/addclass_widgets/schedule_selector.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/addclass_widgets/study_detail_section.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/addclass_widgets/submit_section.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/addclass_widgets/summary_section.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/widgets/addclass_widgets/class_detail_section.dart'; // ✅ thêm dòng này


class AddClassPage extends StatefulWidget {
  const AddClassPage({super.key});

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final _formKey = GlobalKey<FormState>();
  String? subject;
  String? grade;
  bool agree = false;

  final days = ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "CN"];
  final times = ["Sáng", "Chiều", "Tối"];
  final selectedSlots = <String>{};

  // ✅ Thêm các controller cho phần thông tin lớp
  final classCodeController = TextEditingController();
  final requesterController = TextEditingController();
  final phoneController = TextEditingController();
  final feeController = TextEditingController();
  final receiveFeeController = TextEditingController();

  void toggleSlot(String day, String time) {
    final key = "$day - $time";
    setState(() {
      selectedSlots.contains(key)
          ? selectedSlots.remove(key)
          : selectedSlots.add(key);
    });
  }

  @override
  void dispose() {
    // ✅ Giải phóng controller khi thoát
    classCodeController.dispose();
    requesterController.dispose();
    phoneController.dispose();
    feeController.dispose();
    receiveFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TẠO LỚP HỌC MỚI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SummarySection(),
              const SizedBox(height: 16),
              BasicInfoSection(
                onSubjectChanged: (v) => subject = v,
                onGradeChanged: (v) => grade = v,
              ),
              const SizedBox(height: 16),
              const StudyDetailSection(),
              const SizedBox(height: 16),

              // ✅ Thêm phần thông tin lớp chi tiết
              ClassDetailSection(
                classCodeController: classCodeController,
                requesterController: requesterController,
                phoneController: phoneController,
                feeController: feeController,
                receiveFeeController: receiveFeeController,
              ),

              const SizedBox(height: 16),
              const Text("Thời gian có thể học *"),
              const SizedBox(height: 8),
              ScheduleSelector(
                days: days,
                times: times,
                selectedSlots: selectedSlots,
                onToggle: toggleSlot,
              ),
              const SizedBox(height: 20),
              SubmitSection(
                agree: agree,
                onAgreeChanged: (v) => setState(() => agree = v ?? false),
                onSubmit: () {
                  if (_formKey.currentState!.validate() && agree) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đăng ký thành công!")),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
