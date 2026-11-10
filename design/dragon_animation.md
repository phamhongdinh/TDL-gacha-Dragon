# Chuyển động rồng tinh chỉnh

- Cánh được tách bằng mặt nạ riêng cho từng loài, quay nhẹ quanh khớp vai và có độ trễ hai bên; không kéo cả thân hoặc đầu. Rồng Thủy và Thủy–Bóng Tối không có cánh nên không áp chuyển động cánh lên bờm.
- Mắt dùng nhịp khép 45 ms, giữ 25 ms, mở 110 ms. Giữa các lần chớp cách khoảng 5,5–11 giây; thỉnh thoảng chớp kép ngắn, không tự lặp vô hạn. Ánh nhìn dịch rất nhẹ sau 8–15 giây.
- Lửa và linh khí chỉ biến dạng trong vùng được chỉ định của hình gốc. Lửa có dòng nhiễu bốc lên, đầu lửa cong và tàn lửa nhỏ, không phủ tam giác lửa lên ngực, chân hoặc cánh. Thủy giữ màu linh khí riêng.
- Ảnh lật ngang sử dụng cùng mặt nạ theo UV; rồng bị hạ gục dừng chuyển động. Mặt nạ là SVG riêng, ảnh PNG gốc được giữ nguyên.

Nguồn: scripts/ui/components/dragon_animator.gd; resources/dragon_idle.gdshader; assets/textures/dragons/motion/*_mask.svg.

Kiểm thử: dragon_animation_integration.gd kiểm tra bảy cấu hình, vật liệu/mặt nạ, chu kỳ chớp mắt mô phỏng hai phút, ảnh lật, không gắn trùng và không áp lên quái.

Cập nhật khớp cánh: dùng biến dạng UV liên tục, bỏ tách lớp cánh và khoét alpha. Cố định dải gốc cánh theo trục thân; trọng số uốn tăng dần về đầu cánh, giảm biên độ cực đại xuống 0,10 radian. Làm mềm ranh giới mặt nạ để không xuất hiện khe hở khi cánh vỗ. Thân và cánh dùng chung nhịp thở, không trượt khỏi nhau.


Tăng mức chuyển động theo yêu cầu: biên độ đầu cánh 0,18 radian, tốc độ 3,0; trọng số gốc cánh vẫn bằng 0. Thêm vùng đuôi riêng cho từng loài, nhịp thở 2,3%, tăng lửa và độ uốn đầu cánh. Không tăng tần suất chớp mắt hoặc thay ngưỡng ngủ 15 giây.

