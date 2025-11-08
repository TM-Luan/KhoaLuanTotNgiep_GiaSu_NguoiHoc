# CẬP NHẬT BỘ LỌC TÌM KIẾM - HOÀN THÀNH

## 🎯 Tổng quan
Đã hoàn thành việc làm lại hệ thống tìm kiếm/lọc cho cả trang Gia sư và Người học theo yêu cầu.

## ✅ Các vấn đề đã sửa

### 1. Lỗi lọc theo giá (CRITICAL FIX)
**Vấn đề**: Nhập giá vào filter nhưng vẫn load toàn bộ danh sách
**Nguyên nhân**: Flutter gửi giá dưới dạng String, nhưng API expect kiểu numeric
**Giải pháp**: 
- ✅ Updated `lib/data/models/class_filter.dart` - Convert String to double/int trong toJson()
- ✅ Updated `BE_GiaSu/app/Models/LopHocYeuCau.php` - Cast HocPhi to double
- ✅ Updated `BE_GiaSu/app/Http/Controllers/LopHocYeuCauController.php` - Force cast to float

**Code thay đổi**:
```dart
// lib/data/models/class_filter.dart
if (minHocPhi != null && minHocPhi!.isNotEmpty) 
  'min_price': double.tryParse(minHocPhi!) ?? int.tryParse(minHocPhi!),
if (maxHocPhi != null && maxHocPhi!.isNotEmpty) 
  'max_price': double.tryParse(maxHocPhi!) ?? int.tryParse(maxHocPhi!),
```

```php
// LopHocYeuCauController.php
if ($request->filled('min_price')) {
    $minPrice = (float) $request->min_price;
    $query->where('HocPhi', '>=', $minPrice);
}
```

## 📋 Thay đổi theo yêu cầu

### TRANG GIA SƯ (Tìm lớp học)
#### ❌ Đã xóa:
- Bộ lọc theo trạng thái (không cần thiết như user yêu cầu)

#### ✅ Đã thêm:
1. **Lọc theo lớp/khối** (grade_id)
   - Backend: Đã có sẵn trong controller
   - Frontend: Dropdown "Cấp học" đã có sẵn trong UI

2. **Lọc theo hình thức Online/Offline** (form) ⭐ NEW
   - Backend: `BE_GiaSu/app/Http/Controllers/LopHocYeuCauController.php`
   - Frontend: `lib/widgets/class_filter_widget.dart`
   - Options: "Online", "Offline", "Cả hai"

#### ✅ Đã giữ nguyên:
- Lọc theo môn học (subject_id)
- Lọc theo giá (min_price, max_price) - ĐÃ SỬA LỖI

### TRANG NGƯỜI HỌC (Tìm gia sư)
#### ✅ Đã thêm:
1. **Lọc theo đánh giá** (min_rating, max_rating) ⭐ NEW
   - Backend: `BE_GiaSu/app/Http/Controllers/GiaSuController.php`
   - Model: `BE_GiaSu/app/Models/GiaSu.php` - Added relationships
   - Frontend: `lib/widgets/tutor_filter_widget.dart`
   - Options: "3.0+", "3.5+", "4.0+", "4.5+", "5.0"

#### ✅ Đã giữ nguyên:
- Lọc theo chuyên môn/môn dạy (subject_id)
- Lọc theo kinh nghiệm (experience_level)
- Lọc theo giới tính (gender)

## 📂 Files đã sửa đổi

### Backend (Laravel)
1. ✅ `app/Http/Controllers/LopHocYeuCauController.php`
   - Added form filter (Online/Offline/Cả hai)
   - Fixed price filter with type casting
   - Added debug logging

2. ✅ `app/Http/Controllers/GiaSuController.php`
   - Added rating filter with AVG calculation
   - Enhanced subject filter via relationships

3. ✅ `app/Models/GiaSu.php`
   - Added lopHocYeuCau() relationship
   - Added danhGia() hasManyThrough relationship

4. ✅ `app/Models/LopHocYeuCau.php`
   - Added HocPhi cast to double
   - Added SoLuong cast to integer

5. ✅ `app/Http/Requests/SearchRequest.php`
   - Already updated in previous session

### Frontend (Flutter)
1. ✅ `lib/data/models/class_filter.dart`
   - Added hinhThuc field
   - Fixed toJson() to convert prices to numeric
   - Updated copyWith and hasActiveFilters

2. ✅ `lib/data/models/tutor_filter.dart`
   - Added minRating and maxRating fields
   - Added toJson() conversion to numeric
   - Updated copyWith and hasActiveFilters

3. ✅ `lib/widgets/class_filter_widget.dart`
   - ❌ REMOVED: Trạng thái dropdown
   - ✅ ADDED: Hình thức dropdown (Online/Offline/Cả hai)
   - ✅ KEPT: Cấp học dropdown (grade)

4. ✅ `lib/widgets/tutor_filter_widget.dart`
   - ✅ ADDED: Đánh giá tối thiểu dropdown (3.0+ to 5.0)

## 🧪 Test các filter

### Test Class Search (Gia sư tìm lớp)
```bash
# Test price filter
GET /api/lophoc/search?min_price=200000&max_price=300000

# Test grade filter
GET /api/lophoc/search?grade_id=2

# Test form filter
GET /api/lophoc/search?form=Online
GET /api/lophoc/search?form=Offline
GET /api/lophoc/search?form=Cả hai

# Test combined
GET /api/lophoc/search?subject_id=3&grade_id=2&form=Online&max_price=250000
```

### Test Tutor Search (Người học tìm gia sư)
```bash
# Test rating filter
GET /api/giasu/search?min_rating=4.0

# Test combined
GET /api/giasu/search?subject_id=3&min_rating=4.0&gender=Nữ&experience_level=5+
```

## 📊 So sánh trước/sau

| Feature | Trước | Sau | Status |
|---------|-------|-----|--------|
| **Trang Gia Sư** | | | |
| Lọc môn học | ✅ | ✅ | Giữ nguyên |
| Lọc giá | ⚠️ Lỗi | ✅ Đã sửa | **FIXED** |
| Lọc khối/lớp | ❌ | ✅ | **NEW** |
| Lọc hình thức | ❌ | ✅ Online/Offline | **NEW** |
| Lọc trạng thái | ✅ | ❌ | **REMOVED** |
| **Trang Người Học** | | | |
| Lọc chuyên môn | ✅ | ✅ | Giữ nguyên |
| Lọc đánh giá | ❌ | ✅ 3.0-5.0 | **NEW** |
| Lọc kinh nghiệm | ✅ | ✅ | Giữ nguyên |
| Lọc giới tính | ✅ | ✅ | Giữ nguyên |

## 🚀 Cách test trong app

### 1. Clear cache Laravel
```bash
cd BE_GiaSu
php artisan config:clear
```

### 2. Test trên Flutter app
- **Trang Gia sư**: Mở filter, test dropdown Hình thức (Online/Offline/Cả hai)
- **Trang Người học**: Mở filter, test dropdown Đánh giá (⭐ 3.0+ đến ⭐ 5.0)
- **Test giá**: Nhập 200000 - 300000, kiểm tra chỉ hiện lớp trong khoảng giá đó

## ⚠️ Lưu ý quan trọng

1. **Price Filter Fix**: Đây là fix CRITICAL - trước đây giá không hoạt động vì type mismatch
2. **Rating Filter**: Chỉ show gia sư có đánh giá. Nếu muốn show cả gia sư chưa có đánh giá, cần thay đổi logic whereHas
3. **Form Filter**: "Cả hai" sẽ không filter (show tất cả), còn Online/Offline sẽ filter chính xác
4. **Không ảnh hưởng chức năng khác**: Tất cả changes chỉ liên quan đến search/filter, không đụng tới rating, schedule, authentication

## 🎉 Kết luận

✅ Đã sửa xong lỗi giá không lọc đúng
✅ Đã thêm bộ lọc hình thức (Online/Offline) cho trang gia sư
✅ Đã thêm bộ lọc đánh giá cho trang người học
✅ Đã xóa bộ lọc trạng thái không cần thiết
✅ Đã giữ nguyên tất cả filter cũ (môn học, giới tính, kinh nghiệm)
✅ Sẵn sàng để test!

**Test ngay để kiểm tra nhé! 🚀**
