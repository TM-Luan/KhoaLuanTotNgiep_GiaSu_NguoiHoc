# Hướng Dẫn Hệ Thống Đánh Giá Gia Sư

## 📋 Tổng Quan

Hệ thống đánh giá cho phép học viên đánh giá gia sư mà họ đã hoặc đang học. Mỗi học viên chỉ có thể đánh giá **1 lần** cho mỗi gia sư và có thể **chỉnh sửa không giới hạn**.

## ✅ Quy Tắc Đánh Giá

### 1. Điều kiện được đánh giá
- Phải đăng nhập bằng tài khoản **Người học**
- Phải có lớp học với gia sư ở trạng thái:
  - `DangHoc` (Đang học)
  - `HoanThanh` (Hoàn thành)

### 2. Giới hạn đánh giá
- ✅ **Được**: Đánh giá 1 lần cho mỗi gia sư
- ✅ **Được**: Chỉnh sửa đánh giá **1 LẦN DUY NHẤT**
- ❌ **Không được**: Tạo nhiều đánh giá cho cùng 1 gia sư
- ❌ **Không được**: Chỉnh sửa đánh giá quá 1 lần

### 3. Nội dung đánh giá
- **Điểm số**: Từ 1-5 sao (bắt buộc)
- **Bình luận**: Tối đa 1000 ký tự (tùy chọn)

## 🎯 Luồng Sử Dụng

### Đánh Giá Lần Đầu

```
1. Vào trang chi tiết gia sư
2. Click nút "Đánh giá" (màu vàng)
3. Hệ thống kiểm tra quyền
4. Chọn số sao (1-5)
5. Nhập bình luận (nếu muốn)
6. Click "Gửi đánh giá"
7. Tự động quay về trang chủ
8. Danh sách gia sư tự động cập nhật điểm mới
```

### Chỉnh Sửa Đánh Giá

```
1. Vào trang chi tiết gia sư đã đánh giá
2. Click nút "Đánh giá"
3. Hệ thống kiểm tra:
   a) Nếu ĐÃ SỬA RỒI:
      - Hiện dialog CHẶN với icon đỏ 🚫
      - Thông báo: "Không thể chỉnh sửa"
      - "Bạn đã sửa đánh giá này rồi. Mỗi học viên chỉ được sửa 1 lần duy nhất"
      - Chỉ có nút "Đóng"
      
   b) Nếu CHƯA SỬA:
      - Hiện dialog CẢNH BÁO với icon cam ⚠️
      - Hiển thị đánh giá hiện tại
      - Thông báo: "LƯU Ý: Bạn chỉ có thể sửa 1 LẦN DUY NHẤT"
      - Buttons: "Hủy" | "Tôi hiểu, tiếp tục sửa"
4. Click "Tôi hiểu, tiếp tục sửa"
5. Dialog đánh giá hiện ra với dữ liệu cũ
6. Sửa điểm hoặc bình luận
7. Click "Gửi đánh giá"
8. ⚠️ SAU KHI SỬA: Không thể sửa nữa
9. Tự động quay về trang chủ với điểm cập nhật
```

## 🔄 Auto Reload

Sau khi đánh giá thành công, hệ thống tự động:
- ✅ Reload chi tiết gia sư
- ✅ Reload toàn bộ danh sách gia sư
- ✅ Cập nhật điểm trung bình
- ✅ Cập nhật số lượng đánh giá
- ✅ Quay về trang chủ sau 1 giây

## 📱 Giao Diện

### Nút Đánh Giá
- Màu: **Vàng/Amber**
- Icon: ⭐ `star_rate`
- Vị trí: Dưới nút "Xem đánh giá"

### Dialog Đánh Giá
- Header: Avatar + Tên gia sư
- Chọn sao: 5 ngôi sao tương tác
- Bình luận: TextField với counter 0/1000
- Buttons: "Hủy" | "📨 Gửi đánh giá"

### Dialog Cảnh Báo Chỉnh Sửa (Chưa sửa lần nào)
- Icon: 🔖 `edit_note` (màu cam)
- Hiển thị đánh giá cũ: Điểm + Bình luận
- Thông báo: **LƯU Ý: Chỉ được sửa 1 LẦN DUY NHẤT**
- Buttons: "Hủy" | "⚠️ Tôi hiểu, tiếp tục sửa"

### Dialog Chặn (Đã sửa rồi)
- Icon: 🚫 `block` (màu đỏ)
- Hiển thị đánh giá hiện tại: Điểm + Bình luận
- Thông báo đỏ: **"Đã sửa rồi, không thể sửa nữa"**
- Chỉ có nút: "Đóng"

## 🎨 Hiển Thị Điểm

### Trên Card Gia Sư
```
4.5 ⭐ (23)
└── Điểm TB   └── Số đánh giá
```

### Trên Trang Chi Tiết
```
Điểm đánh giá: 4.5 ⭐⭐⭐⭐⭐
```

### Trang Danh Sách Đánh Giá
```
┌─────────────────────────────┐
│  4.5 ⭐⭐⭐⭐⭐              │
│  23 đánh giá                │
│                             │
│  5⭐ ████████████ 15        │
│  4⭐ █████ 5                │
│  3⭐ ██ 2                   │
│  2⭐ █ 1                    │
│  1⭐ ░ 0                    │
└─────────────────────────────┘
```

## 🔧 Technical Details

### Backend API

1. **POST** `/api/danhgia`
   - Tạo hoặc cập nhật đánh giá
   - Validate: Học viên đã học với gia sư
   - Logic: Tìm đánh giá cũ → Update hoặc Create

2. **GET** `/api/danhgia/kiem-tra-danh-gia?gia_su_id={id}`
   - Kiểm tra quyền đánh giá
   - Trả về: `co_the_danh_gia`, `da_danh_gia`, `danh_gia`

3. **GET** `/api/giasu/{id}/danhgia`
   - Lấy tất cả đánh giá của gia sư
   - Public endpoint

4. **DELETE** `/api/danhgia/{id}`
   - Xóa đánh giá (chưa dùng trong UI)

### Frontend Flow

```dart
// 1. Kiểm tra quyền
context.read<DanhGiaBloc>().add(KiemTraDaDanhGia(giaSuId: id));

// 2. Hiện dialog với dữ liệu cũ (nếu có)
showDialog<bool>(
  builder: (context) => DanhGiaGiaSuDialog(
    tutor: tutor,
    initialRating: oldRating,
    initialComment: oldComment,
  ),
);

// 3. Submit đánh giá
context.read<DanhGiaBloc>().add(TaoDanhGia(
  giaSuId: id,
  diemSo: rating,
  binhLuan: comment,
));

// 4. Reload dữ liệu
context.read<TutorBloc>().add(LoadTutorByIdEvent(id));
context.read<TutorBloc>().add(LoadAllTutorsEvent());

// 5. Quay về trang chủ
Navigator.pop(context);
```

## 🐛 Troubleshooting

### Không thấy nút "Đánh giá"
- ✅ Check: Đã đăng nhập bằng tài khoản Người học chưa?
- ✅ Check: Provider `DanhGiaBloc` đã được đăng ký trong `main.dart` chưa?

### Không thể đánh giá
- ✅ Check: Có lớp học với gia sư ở trạng thái `DangHoc` hoặc `HoanThanh` chưa?
- ✅ Check: Backend API `/api/danhgia/kiem-tra-danh-gia` trả về gì?

### Danh sách không tự động cập nhật
- ✅ Check: `BlocBuilder<TutorBloc>` đã được setup đúng chưa?
- ✅ Check: `LoadAllTutorsEvent` đã được dispatch sau khi đánh giá chưa?

### Điểm không đúng
- ✅ Check: Backend tính điểm trung bình có đúng không?
- ✅ Check: `GiaSuResource` có tính `DiemSo` và `TongSoDanhGia` chưa?

## 📊 Database Schema

```sql
DanhGia
├── DanhGiaID (PK)
├── LopYeuCauID (FK -> LopHocYeuCau)
├── TaiKhoanID (FK -> TaiKhoan)
├── DiemSo (1-5)
├── BinhLuan (max 1000 chars)
├── NgayDanhGia (datetime)
├── created_at (datetime) -- Thời điểm tạo
└── updated_at (datetime) -- Thời điểm cập nhật

Unique constraint: (LopYeuCauID, TaiKhoanID)
Logic: created_at != updated_at => Đã sửa rồi
```

## ✨ Features Implemented

- ✅ Đánh giá gia sư với sao và bình luận
- ✅ Giới hạn 1 đánh giá/học viên/gia sư
- ✅ Chỉnh sửa đánh giá **1 LẦN DUY NHẤT**
- ✅ Dialog cảnh báo rõ ràng khi sửa
- ✅ Dialog chặn nếu đã sửa rồi
- ✅ Backend validate bằng `created_at` vs `updated_at`
- ✅ Auto reload danh sách sau khi đánh giá
- ✅ Hiển thị điểm trung bình trên card
- ✅ Trang xem tất cả đánh giá
- ✅ Phân bố điểm theo sao
- ✅ Validate quyền đánh giá

## 🎉 Done!

Hệ thống đánh giá đã hoàn thiện với đầy đủ tính năng:
- Giới hạn đánh giá đúng quy tắc
- Auto reload thông minh
- UX/UI mượt mà
- Validation chặt chẽ
