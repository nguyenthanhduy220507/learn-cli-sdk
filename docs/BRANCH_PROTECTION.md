# 🛡️ GitHub Branch Protection - Hướng dẫn thiết lập

Để bảo vệ nhánh `main` không bị đẩy code lỗi trực tiếp, bạn hãy thực hiện các bước cấu hình trên giao diện GitHub như sau:

### 1. Truy cập phần cấu hình
1. Tại trang Repository trên GitHub, chọn tab **Settings**.
2. Ở sidebar bên trái, chọn **Branches**.

### 2. Thêm quy tắc bảo vệ
1. Click nút **Add branch protection rule**.
2. **Branch name pattern**: Điền `main`.

### 3. Các thiết lập quan trọng (Bật các dấu tích sau)
1. **Require a pull request before merging**: 
   - Không cho phép push trực tiếp vào `main`. 
   - Bắt buộc phải tạo Pull Request (PR).
2. **Require status checks to pass before merging**: 
   - Đây là bước "gác cổng" CI/CD.
   - Tại ô tìm kiếm bên dưới, gõ và chọn: **Run tests**.
   - (Điều này bắt buộc job Test phải xanh thì mới cho Merged).
3. **Do not allow bypassing the above settings**: 
   - Áp dụng quy tắc cho cả quản trị viên (Admin).

### 4. Lưu lại
- Cuộn xuống dưới cùng và nhấn **Create**.

---

## 🚀 Quy trình làm việc mới (Workflow)

Sau khi bật tính năng này, bạn sẽ không dùng `git push origin main` được nữa. Hãy dùng quy trình sau:

1. **Tạo nhánh mới**: `git checkout -b feature/ten-tinh-nang`
2. **Làm việc và commit**: `git add . && git commit -m "..."`
3. **Push lên nhánh phụ**: `git push origin feature/ten-tinh-nang`
4. **Tạo Pull Request**: Lên GitHub và nhấn **Compare & pull request**.
5. **Đợi CI chạy**: Chờ cho đến khi dấu tích xanh hiện ra.
6. **Merge**: Nhấn nút **Merge pull request** để đưa code vào `main`.
