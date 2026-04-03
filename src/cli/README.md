# IKIGAI AI CLI SDK

Bộ công cụ dòng lệnh (CLI) chính thức để tương tác với nền tảng IKIGAI AI.

## Cài đặt

1. Di chuyển vào thư mục CLI:
   ```powershell
   cd src/cli
   ```

2. Cài đặt gói ở chế độ chỉnh sửa (editable mode):
   ```powershell
   pip install -e .
   ```

## Các lệnh cơ bản

### 1. Kiểm tra trạng thái hệ thống
Sử dụng lệnh này để xem các dịch vụ (Postgres, Redis, Qdrant, Ollama...) có đang hoạt động hay không.
```powershell
ikigai info
```

### 3. Trò chuyện liên tục (Interactive Chat)
Bắt đầu một phiên chat liên tục với khả năng nhớ lịch sử hội thoại.
```powershell
ikigai chat
```
- Sử dụng `/exit` để thoát.
- Sử dụng `/clear` để xóa lịch sử trong phiên.

### 4. Hỏi đáp đơn lẻ (Ask)
Gửi một câu hỏi duy nhất và nhận câu trả lời ngay lập tức.
```powershell
ikigai ask "Xin chào, bạn có thể giúp gì cho tôi?"
```

### 5. Quản lý tài liệu
**Tải lên tài liệu mới:**
```powershell
ikigai upload "đường/dẫn/đến/file.txt"
```

**Liệt kê các tài liệu đã tải lên:**
```powershell
ikigai docs
```

## Cấu trúc thư mục
- `ikigai/main.py`: Logic điều khiển các lệnh CLI.
- `ikigai/client.py`: Trình khách (Client) xử lý các API gọi tới Backend.
- `ikigai/ui.py`: Các thành phần giao diện (Rich UI).
- `setup.py`: Cấu hình cài đặt gói.
