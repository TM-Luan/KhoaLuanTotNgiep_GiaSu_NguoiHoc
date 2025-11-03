# Tài liệu sử dụng chức năng Tìm kiếm

## Tổng quan
Chức năng tìm kiếm cho phép người dùng tìm kiếm gia sư và lớp học với nhiều tiêu chí lọc khác nhau như tên, giá tiền, chuyên môn, môn học, v.v.

## Cấu trúc

### 1. Models
- **SearchFilter**: Quản lý các tiêu chí tìm kiếm và lọc
- **SearchResult**: Chứa kết quả tìm kiếm với phân trang
- **FilterOptions**: Chứa tất cả các tùy chọn lọc (dropdown data)
- **SearchStats**: Thống kê tổng quan
- **SearchSuggestion**: Gợi ý tìm kiếm

### 2. Repository
- **SearchRepository**: Xử lý API calls cho tìm kiếm

### 3. BLoC
- **SearchBloc**: Quản lý state cho tìm kiếm
- **SearchEvent**: Các sự kiện tìm kiếm
- **SearchState**: Các trạng thái tìm kiếm

### 4. UI Components
- **SearchScreen**: Màn hình tìm kiếm chính
- **SearchBarWidget**: Thanh tìm kiếm
- **SearchResultsWidget**: Hiển thị kết quả
- **SearchFilterWidget**: Bộ lọc nâng cao

## Cách sử dụng

### 1. Navigating to Search Screen

```dart
// Mở màn hình tìm kiếm gia sư
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SearchScreen(
      initialType: SearchType.tutors,
      initialQuery: 'toán học',
    ),
  ),
);

// Mở màn hình tìm kiếm lớp học
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SearchScreen(
      initialType: SearchType.classes,
    ),
  ),
);
```

### 2. Sử dụng SearchBarWidget riêng lẻ

```dart
SearchBarWidget(
  controller: _searchController,
  onSearch: (query) {
    // Xử lý tìm kiếm
    print('Searching for: $query');
  },
  onFilterPressed: () {
    // Mở bộ lọc
    _showFilterDialog();
  },
  hasActiveFilters: _hasActiveFilters,
  hintText: 'Tìm kiếm gia sư...',
)
```

### 3. Tạo filter tùy chỉnh

```dart
SearchFilter filter = SearchFilter(
  keyword: 'toán học',
  subjectId: 1,
  gradeId: 10,
  priceFrom: 100000,
  priceTo: 500000,
  gender: 'female',
  educationLevel: 'university',
  experienceLevel: '2-5_years',
  sortBy: 'rating_desc',
  page: 1,
  perPage: 10,
);

// Sử dụng với BLoC
context.read<SearchBloc>().add(SearchTutorsEvent(filter));
```

### 4. Lắng nghe kết quả tìm kiếm

```dart
BlocListener<SearchBloc, SearchState>(
  listener: (context, state) {
    if (state is SearchTutorsSuccess) {
      print('Found ${state.result.total} tutors');
      // Xử lý kết quả
    } else if (state is SearchError) {
      print('Search error: ${state.message}');
      // Hiển thị lỗi
    }
  },
  child: YourWidget(),
)
```

## API Endpoints

### 1. Tìm kiếm gia sư
```
GET /api/giasu/search?keyword=toán&subject_id=1&grade_id=10&price_from=100000&price_to=500000
```

### 2. Tìm kiếm lớp học
```
GET /api/lophoc/search?keyword=cần gia sư&subject_id=1&grade_id=10&location=Hà Nội
```

### 3. Lấy tùy chọn lọc
```
GET /api/filter-options
```

### 4. Thống kê tìm kiếm
```
GET /api/search-stats
```

### 5. Gợi ý tìm kiếm
```
GET /api/search-suggestions?q=toán&type=tutors
```

## Ví dụ đầy đủ

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/features/search/search.dart';

class MySearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(SearchRepository()),
      child: Scaffold(
        appBar: AppBar(title: Text('Tìm kiếm')),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16),
              child: SearchBarWidget(
                controller: TextEditingController(),
                onSearch: (query) {
                  final filter = SearchFilter(keyword: query);
                  context.read<SearchBloc>().add(SearchTutorsEvent(filter));
                },
                onFilterPressed: () {
                  // Show filter dialog
                },
                hasActiveFilters: false,
              ),
            ),
            
            // Results
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is SearchTutorsSuccess) {
                    return ListView.builder(
                      itemCount: state.result.data.length,
                      itemBuilder: (context, index) {
                        final tutor = state.result.data[index];
                        return ListTile(
                          title: Text(tutor.hoTen),
                          subtitle: Text(tutor.diaChi ?? ''),
                          trailing: Text('${tutor.diemSo}⭐'),
                        );
                      },
                    );
                  } else if (state is SearchError) {
                    return Center(child: Text('Lỗi: ${state.message}'));
                  }
                  return Center(child: Text('Nhập từ khóa để tìm kiếm'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Tùy chỉnh

### 1. Custom Filter Options
Bạn có thể tùy chỉnh các tùy chọn lọc bằng cách chỉnh sửa backend API `/api/filter-options`.

### 2. Custom Sort Options
Thêm các tùy chọn sắp xếp mới trong `FilterOptions.sortOptions`.

### 3. Custom UI
Tất cả các widget đều có thể tùy chỉnh style thông qua `AppColors` trong `/constants/colors.dart`.

## Lưu ý

1. **Hiệu suất**: Sử dụng debouncing cho tìm kiếm real-time
2. **Cache**: Repository có thể được mở rộng để cache kết quả
3. **Offline**: Cần xử lý trường hợp offline
4. **Validation**: Backend đã có validation cho các tham số tìm kiếm
5. **Pagination**: Kết quả được phân trang, sử dụng `SearchPagination` để điều hướng

## Troubleshooting

1. **Lỗi kết nối**: Kiểm tra URL base trong `SearchRepository`
2. **Dữ liệu không hiển thị**: Kiểm tra format JSON response từ backend
3. **Filter không hoạt động**: Đảm bảo backend API hỗ trợ các tham số filter
4. **Performance issue**: Sử dụng `ListView.builder` cho danh sách lớn