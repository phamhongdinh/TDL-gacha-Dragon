# Lai tạo nguyên tố

Các tỉ lệ dưới đây là lựa chọn ban đầu cho bản thử theo yêu cầu "cao hơn roll":

| Bố mẹ | Kết quả thành công | Tỉ lệ |
| --- | --- | ---: |
| Hai rồng 1 hệ khác nhau | Rồng lai tương ứng 2 hệ | 5% |
| Một rồng 2 hệ và một rồng 1 hệ còn thiếu | Tam Hệ | 1% |
| Hai rồng 2 hệ khác nhau, hợp đủ Hỏa/Thủy/Bóng Tối | Tam Hệ | 1% |

Tỉ lệ cao hơn rate Gacha cơ bản 0,1%; không so với lượt Gacha có bảo hiểm 100%. Không có bảo hiểm lai, xác suất không tích lũy.

Màn hình mang tên **Hợp thể rồng thần**, nút thao tác **Hợp thể**. Người chơi chọn hai loại rồng qua thẻ hình ảnh; mỗi loại xuất hiện một lần, loại chưa sở hữu bị làm mờ. Hệ thống lấy cá thể đầu tiên theo thứ tự dữ liệu của mỗi loại, không hiện số hiệu. Cặp cùng hệ, 1+2 hệ trùng nguyên tố (không đủ ba hệ), Tam Hệ hoặc cặp chưa có công thức bị chặn và giải thích trong UI. Hỏa–Thủy + Bóng Tối, Hỏa–Bóng Tối + Thủy, Thủy–Bóng Tối + Hỏa đều có thể ra Tam Hệ; thứ tự hai rồng không ảnh hưởng.

Bản thử miễn phí, hai rồng ban đầu không bị tiêu hao. Nếu không ra rồng thần, vẫn nhận một rồng một hệ được chọn đều từ tập nguyên tố của hai rồng ban đầu; có hoạt ảnh trứng nở và lộ diện như kết quả thường. Mỗi kết quả tạo một cá thể cấp 1 có ID riêng, thông tin hai rồng ban đầu và được lưu cục bộ. Bộ đếm bảo hiểm triệu hồi không thay đổi.

Mỗi lần hợp thể hợp lệ bắt đầu thời gian chờ 30 giây, tính từ lúc nhận yêu cầu, bao gồm thời gian hoạt ảnh. Khóa nút và hiện số giây còn lại. Mốc thời gian hết chờ lưu cùng rồng trong một lần ghi; tải lại trang hoặc đổi màn không xóa thời gian chờ. Thao tác sai cặp, đang hồi hoặc ghi file thất bại không nhận rồng và không bắt đầu thời gian chờ mới. File lưu cũ mặc định mốc chờ là 0.

UI gồm hai ô chọn loại, trứng bí ẩn ở giữa và nút **Xem tổ hợp rồng**. Không tiết lộ kết quả cụ thể hoặc phần trăm trên màn chính. Nút xem chỉ bật khi đã chọn đủ hai loại. Bảng hiển thị chính hai rồng đang chọn và chỉ các kết quả có thể nhận từ cặp đó, gồm rồng thần và rồng một hệ khi không ra rồng thần. Ví dụ Hỏa + Thủy chỉ hiển thị Hỏa–Thủy, Hỏa, Thủy. Không có công thức khác hoặc phần trăm. Danh sách xem và logic chọn kết quả dùng chung `possible_outcomes`. Các xác suất 5%/1% vẫn được áp dụng trong logic.

Thành công xuất hiện một trứng theo nguyên tố rồng con, nở chậm hơn triệu hồi thường, rồi mới lộ diện. Rồng hai hệ có hiệu ứng vàng; Tam Hệ có thêm vòng sáng ba nguyên tố và thông báo riêng. Bỏ qua hoạt ảnh không đổi phần thưởng. Khóa các thao tác khi đang hợp thể hoặc xem nở trứng.
