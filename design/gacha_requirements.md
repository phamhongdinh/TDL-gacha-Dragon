# Triệu hồi — Hắc Hỏa thức giấc

Yêu cầu: rồng một hệ yếu, dùng làm thức ăn tăng cấp cho rồng hai/ba hệ. Một banner chỉ rate up một rồng hai hệ, xác suất 0,1% mỗi lượt.

Banner đầu chọn Rồng Hỏa · Bóng Tối. Phần xác suất còn lại tạm chia đều cho ba loài một hệ:

| Kết quả | Tỉ lệ |
| --- | ---: |
| Rồng Hỏa · Bóng Tối | 0,1% |
| Rồng Hỏa | 33,3% |
| Rồng Thủy | 33,3% |
| Rồng Bóng Tối | 33,3% |
| Rồng hai hệ khác, Tam Hệ | 0% |

Trọng số cơ bản lần lượt 10, 3330, 3330, 3330; tổng 10000. Trước mốc bảo hiểm, tỉ lệ rồng vàng là 0,1%. Nếu 59 lượt liên tiếp chưa trúng vàng, lượt kế tiếp đảm bảo rồng nổi bật (Hỏa · Bóng Tối). Trúng vàng sớm hoặc ở mốc bảo hiểm đều đếm lại từ 0. ×10 xử lý tuần tự, không đợi hết gói mới xét bảo hiểm. Chưa chốt chi phí hoặc EXP nguyên liệu.

Đã triển khai roll ×1 và ×10. Mỗi lượt trước bảo hiểm chọn một vé nguyên ngẫu nhiên trong 0–9999. Hiện roll miễn phí thử nghiệm, chưa trừ tài nguyên. Mỗi kết quả tạo một cá thể cấp 1 với ID riêng; rồng trùng vẫn được giữ. Bộ sưu tập gộp hiển thị theo loài kèm số lượng.

Kết quả lưu cục bộ vào `user://collection.json` qua file tạm rồi đổi tên; chỉ thêm rồng vào bộ nhớ sau khi lưu thành công. Autoload SaveManager tải lại khi mở app. Khi file lưu không hợp lệ, chặn ghi đè và báo lỗi nếu roll. Không có giao dịch thật. Chưa triển khai cho ăn/tăng cấp.

File lưu v2 ghi đồng thời danh sách rồng và `pity_count` (0–59). Nếu ghi thất bại, cả hai không thay đổi. File v1 vẫn được đọc và giữ nguyên rồng cũ, bắt đầu bộ đếm bảo hiểm ở 0 vì phiên bản đó chưa có bảo hiểm.

## Hoạt ảnh nở trứng

Trình tự: hội tụ năng lượng → rung/nứt vỏ → nở đồng loạt → hiện các rồng ở vị trí trứng → phóng to rồng rate-up nếu có → bảng kết quả. ×10 có đúng mười trứng lớn theo lưới 5×2, mỗi trứng ứng với đúng một kết quả đã roll. Hỏa cam, Thủy xanh ngọc, Bóng Tối tím; trứng hai hệ chia hai màu và viền vàng. Tất cả trứng nở cùng thời điểm. Rồng rate-up được phóng từ ô của nó ra giữa sau khi cả lưới nở xong; nếu có nhiều vàng, hiển thị số lượng và giữ đủ kết quả. Hiệu ứng không đổi kết quả, xác suất hay bảo hiểm. Nút Bỏ qua mở sau 0,7 giây, đi thẳng tới cùng bảng kết quả. Khóa nút nền khi đang triệu hồi/xem kết quả.

Âm thanh đồng bộ với các mốc nứt, nở, lộ diện; rồng hai hệ có màu vàng và âm báo riêng. Có nhạc nền và nút tắt âm toàn app.

Nếu một gói có nhiều rồng rate-up, lần lượt phóng to từng rồng vàng sau khi cả lưới nở, mỗi rồng có lượt giới thiệu riêng. Không bỏ qua bất kỳ kết quả nào.

## Giao diện tiếng Việt

Chỉ giữ nút Quay lại phía trên trái, kim cương hồ sơ ở trên phải và nút Chi tiết tỉ lệ nhỏ ở góc vùng triệu hồi. Bỏ thanh chuyển màn, khung xác suất lớn, số rồng sở hữu và câu khẩu hiệu cũ. Bên dưới có giới thiệu Hỏa · Bóng Tối với sức tấn công mạnh mẽ, chưa đặt chỉ số chiến đấu. Bảng tỉ lệ dạng thẻ có ảnh, bốn kết quả có xác suất và giải thích bảo hiểm. Bật/tắt âm cùng âm lượng nằm trong Cài đặt, không có nút âm nổi.
