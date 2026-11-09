# Trang chủ và chăm sóc rồng

Trang chủ chỉ trưng bày các cá thể đang sở hữu đã đánh dấu Yêu thích. Có nhiều rồng yêu thích thì dùng hai mũi tên để chuyển; không có thì hiện lời nhắc vào Bộ sưu tập, không dùng rồng mẫu thay thế.

Khu Chăm sóc nằm bên dưới Trang chủ; cuộn xuống hoặc bấm lối tắt Chăm sóc và cho rồng ăn. Thanh điều hướng vẫn cố định ở cuối màn hình. Tại đây chọn một cá thể đang sở hữu, xem ảnh, cấp và chỉ số chiến đấu rồi Cho ăn.

Mỗi lần cho ăn tăng một cấp, tốn 5 × cấp hiện tại thức ăn, tối đa cấp 100. Ví dụ cấp 1 lên 2 tốn 5 thức ăn; cấp 2 lên 3 tốn 10. Không đủ thức ăn hoặc đạt cấp tối đa thì khóa nút. Cấp mới áp dụng vào chỉ số chiến đấu hiện có (hệ số tăng trưởng 8% mỗi cấp). Dữ liệu cấp và thức ăn ghi cùng một bản lưu; ghi lỗi sẽ hoàn tác cả hai. Chi phí hiện là cân bằng thử nghiệm trong PlayerCollection.

Chọn rồng để chăm sóc không làm thay đổi yêu thích. Cấp mới cũng cập nhật trên thẻ yêu thích ở Trang chủ. Không tự tặng rồng nếu bộ sưu tập trống.

Kiểm thử: home_care_integration.gd, gồm trạng thái trống, chỉ trưng bày yêu thích, chuyển rồng, tăng chỉ số, trừ thức ăn, hoàn tác ghi lỗi, thiếu thức ăn, cấp tối đa, kiểm tra sở hữu và tải lại dữ liệu.
