class Profile {
  bool? success;
  Data? data;

  Profile({this.success, this.data});

  Profile.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? taiKhoanID;
  String? email;
  String? soDienThoai;
  int? trangThai;
  int? vaiTro;
  String? hoTen;
  String? diaChi;
  String? gioiTinh;
  String? ngaySinh;
  String? bangCap;
  String? kinhNghiem;
  String? anhDaiDien;

  Data({
    this.taiKhoanID,
    this.email,
    this.soDienThoai,
    this.trangThai,
    this.vaiTro,
    this.hoTen,
    this.diaChi,
    this.gioiTinh,
    this.ngaySinh,
    this.bangCap,
    this.kinhNghiem,
    this.anhDaiDien,
  });

  Data.fromJson(Map<String, dynamic> json) {
    taiKhoanID = json['TaiKhoanID'];
    email = json['Email'];
    soDienThoai = json['SoDienThoai'];
    trangThai = json['TrangThai'];
    vaiTro = json['VaiTro'];
    hoTen = json['HoTen'];
    diaChi = json['DiaChi'];
    gioiTinh = json['GioiTinh'];
    ngaySinh = json['NgaySinh'];
    bangCap = json['BangCap'];
    kinhNghiem = json['KinhNghiem'];
    anhDaiDien = json['AnhDaiDien'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TaiKhoanID'] = this.taiKhoanID;
    data['Email'] = this.email;
    data['SoDienThoai'] = this.soDienThoai;
    data['TrangThai'] = this.trangThai;
    data['VaiTro'] = this.vaiTro;
    data['HoTen'] = this.hoTen;
    data['DiaChi'] = this.diaChi;
    data['GioiTinh'] = this.gioiTinh;
    data['NgaySinh'] = this.ngaySinh;
    data['BangCap'] = this.bangCap;
    data['KinhNghiem'] = this.kinhNghiem;
    data['AnhDaiDien'] = this.anhDaiDien;
    return data;
  }
}
