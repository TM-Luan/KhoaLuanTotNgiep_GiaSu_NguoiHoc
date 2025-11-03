# 🔍 HƯỚNG DẪN SỬ DỤNG CHỨC NĂNG TÌM KIẾM

## ✅ **ĐÃ TÍCH HỢP THÀNH CÔNG**

### 📱 **Trang chủ Người học (Student Home)**
- **Thanh tìm kiếm**: "Tìm kiếm gia sư..."
- **Nút lọc**: Mở màn hình tìm kiếm với bộ lọc nâng cao
- **Tìm kiếm theo từ khóa**: Nhập text và Enter → Mở SearchScreen với keyword
- **Loại tìm kiếm**: `SearchType.tutors` (tìm gia sư)

### 👨‍🏫 **Trang chủ Gia sư (Tutor Home)**  
- **Thanh tìm kiếm**: "Tìm kiếm lớp học..."
- **Nút lọc**: Mở màn hình tìm kiếm với bộ lọc nâng cao
- **Tìm kiếm theo từ khóa**: Nhập text và Enter → Mở SearchScreen với keyword
- **Loại tìm kiếm**: `SearchType.classes` (tìm lớp học)

## 🚀 **CÁCH SỬ DỤNG**

### 1. **Tìm kiếm nhanh**
```
Người học: Gõ "toán học" → Enter → Tìm gia sư dạy toán
Gia sư: Gõ "lớp 10" → Enter → Tìm lớp học cần gia sư lớp 10
```

### 2. **Tìm kiếm với bộ lọc**
```
Click nút Filter (🔧) → Mở màn hình tìm kiếm đầy đủ
- Chọn môn học
- Chọn khối lớp  
- Thiết lập khoảng giá
- Lọc theo giới tính, kinh nghiệm...
```

### 3. **Màn hình tìm kiếm đầy đủ**
- **2 Tabs**: Gia sư / Lớp học
- **Thanh tìm kiếm**: Với nút filter tích hợp
- **Bộ lọc nâng cao**: Slide panel từ trên xuống
- **Kết quả**: Hiển thị với pagination
- **Sắp xếp**: Theo điểm số, giá, ngày tạo...

## 🔧 **TÍNH NĂNG**

### ✅ **Đã hoàn thành**
- [x] Tích hợp vào 2 trang chủ
- [x] SearchBarCustom hoạt động đầy đủ
- [x] Navigation đến SearchScreen
- [x] Truyền keyword từ thanh tìm kiếm
- [x] Phân biệt loại tìm kiếm (tutors/classes)
- [x] Bộ lọc nâng cao
- [x] Hiển thị kết quả với pagination
- [x] BLoC state management

### 🎯 **Backend APIs sẵn sàng**
- [x] `/api/giasu/search` - Tìm gia sư
- [x] `/api/lophoc/search` - Tìm lớp học  
- [x] `/api/filter-options` - Dữ liệu dropdown
- [x] `/api/search-stats` - Thống kê
- [x] `/api/search-suggestions` - Gợi ý

## 🎮 **DEMO**

### Người học:
1. Mở app → Đăng nhập với role Người học
2. Vào trang chủ → Thấy "Tìm kiếm gia sư phù hợp"
3. Gõ "toán" vào thanh tìm kiếm → Enter
4. Màn hình Search mở với kết quả tìm gia sư dạy toán

### Gia sư:
1. Mở app → Đăng nhập với role Gia sư  
2. Vào trang chủ → Thấy "Tìm kiếm lớp học phù hợp"
3. Click nút Filter → Màn hình Search mở với bộ lọc
4. Chọn "Lớp 10" + "Toán học" → Tìm các lớp 10 cần gia sư toán

## 🔥 **SẴNS SÀNG SỬ DỤNG!**

**Tất cả chức năng tìm kiếm đã được tích hợp hoàn chỉnh vào trang chủ của cả Người học và Gia sư. Người dùng có thể:**

✅ Tìm kiếm nhanh bằng keyword  
✅ Sử dụng bộ lọc nâng cao  
✅ Xem kết quả với giao diện đẹp  
✅ Chuyển trang và sắp xếp  
✅ Navigation mượt mà giữa các màn hình  

**🎯 Ready to test!**