# Chiến dịch theo chương

Chiến đấu mở danh sách sáu chương trước màn chọn đội. Mỗi chương có ba quái khe nứt; chương 3, 5, 6 có Thạch Giáp Địa Tâm. Máu và tấn công nhân hệ số riêng, phòng thủ giữ nguyên chỉ số gốc.

| Chương | Máu quái | Tấn công | Vàng / thức ăn / mảnh tinh thể |
|---|---:|---:|---|
| 1 | ×1 | ×1 | 150 / 8 / 3 |
| 2 | ×1,25 | ×1,15 | 230 / 11 / 4 |
| 3 | ×1,55 | ×1,35 | 310 / 14 / 5 |
| 4 | ×1,9 | ×1,6 | 390 / 17 / 6 |
| 5 | ×2,35 | ×1,9 | 470 / 20 / 7 |
| 6 | ×2,9 | ×2,2 | 550 / 23 / 8 |

Thắng trận mới có nút Nhận thưởng. Vượt lần đầu cộng thêm phần thưởng được ghi trên thẻ chương; chương 1 tổng lần đầu là 250 vàng, 12 thức ăn, 4 mảnh. Chơi lại được thưởng cơ bản, không lặp thưởng đầu. Thua không thưởng. Nhận thành công mới mở chương tiếp theo; có thể nhận lại nếu ghi dữ liệu lỗi. Mỗi trận chỉ nhận một lần.

Sao: một sao thắng, thêm một sao không rồng gục, thêm một sao trong tối đa mười vòng. Sao tốt nhất lưu cục bộ.

Chỉ số và thưởng thử nghiệm cấu hình ở resources/battle/config.json, mục chapters. Chưa có cơ chế tự sinh chương vô hạn. Mọi rồng, tiền và tiến độ hiện tại được giữ nguyên khi cập nhật.

Kiểm thử chapter_integration.gd: tăng máu/tấn công, khóa chương, thắng thật, giao diện nhận thưởng, hoàn tác khi ghi lỗi, thưởng đầu một lần, thưởng chơi lại, thua không thưởng, tiến độ sau tải lại.
