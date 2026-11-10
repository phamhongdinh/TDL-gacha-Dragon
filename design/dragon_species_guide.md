# Tham chiếu hình thái cho các loài rồng mới

Yêu cầu người dùng, lưu ngày 10/11/2026: dùng ảnh Types of Dragon để định hướng khi thêm rồng mới. Các model hiện tại có dáng quá giống nhau. Loài mới cần khác cấu trúc và dáng tổng thể, không chỉ thay màu hoặc thêm hiệu ứng hệ.

Ảnh gốc: [dragon-body-types.png](references/dragon-body-types.png). Đây là ảnh người dùng cung cấp để tham khảo hình thái. Giữ phong cách chibi, màu sắc và độ hoàn thiện phù hợp game; không bắt buộc sao chép nét vẽ hoặc nền của ảnh.

## Các hướng hình thái trong ảnh

Tên bên dưới được giữ theo nhãn trong ảnh; mô tả là hướng thiết kế thị giác.

| Nhãn tham chiếu | Đặc điểm để phân biệt loài mới |
|---|---|
| Wyvern | Hai chân sau; chi trước là cánh; dáng nghiêng, cổ và đuôi dài |
| Feydragon | Thân nhỏ, cánh lớn như bướm hoặc tiên; đuôi cuộn |
| Dragonette | Rồng nhỏ thân chắc, có chân và cánh; dùng tỷ lệ riêng để tránh trùng dáng rồng hiện tại |
| Basilisk | Thân thấp, dày, nhiều chân; sống lưng có gai, không cánh |
| Dragon | Rồng cánh màng với chân riêng; nhấn dáng bay hoặc cổ cong, không lặp tư thế ngồi hiện tại |
| Amphiptere | Thân dài như rắn, có cánh; không dùng dáng bốn chân |
| Wyrm | Dáng rắn dài, không chân/cánh; nổi bật bằng cổ, vảy, sừng và cách cuộn thân |
| Coatl | Thân rắn, cánh và mào lông; đường nét mềm, bay uốn lượn |
| Hydra | Nhiều đầu, thân nặng; từng đầu có biểu cảm và nhịp chuyển động riêng |
| Arctic Dragon | Thân thú, lông hoặc bờm dày; chân lớn và đuôi dài, phù hợp biến thể băng giá |
| Drake | Bốn chân, không cánh; thân bò sát, dáng thấp và cơ bắp |
| Asian Dragon | Thân dài, bốn chân nhỏ, râu và bờm; bay không cần cánh |
| Sea Orc | Thân dài thích nghi dưới nước; vây và đuôi bơi thay cho cánh màng |

## Nguyên tắc khi thêm loài

1. Chọn hình thái trước, rồi mới chọn hệ. Hệ Hỏa/Thủy/Bóng Tối không quyết định mọi rồng phải có cùng bộ khung.
2. Chốt số đầu, số chân, có/không có cánh, loại cánh, tỷ lệ thân–cổ–đuôi và tư thế. So với bộ rồng đang có để tạo khác biệt rõ khi chỉ nhìn bóng đen.
3. Giữ phong cách chibi và độ dễ đọc ở kích thước nhỏ. Thêm chi tiết nguyên tố sau khi dáng đã phân biệt được.
4. Ghi rõ loài gốc và biến thể: chỉ đổi màu/hệ trên cùng dáng thì coi là biến thể, không thay thế mục tiêu đa dạng loài.
5. Không tự thiết kế lại hoặc xóa bảy rồng hiện tại khi chỉ được yêu cầu thêm loài mới.

## Animation đi theo cấu trúc thật

- Có cánh: chuyển động riêng quanh đúng khớp vai, màng hoặc lông có nhịp phù hợp.
- Không cánh: không áp vùng chuyển động cánh lên bờm, sừng hoặc thân.
- Thân rắn: ưu tiên sóng chuyển động dọc thân và đuôi; rồng biển ưu tiên vây và nhịp bơi.
- Nhiều đầu: định vị mắt và nhịp nhìn/chớp riêng cho từng đầu.
- Chỉ làm lửa chuyển động tại vùng thực sự có lửa; nước, lông và khói có chuyển động riêng.
- Tạo mặt nạ/rig riêng theo ảnh mới. Không dùng tọa độ mắt, cánh và lửa của rồng Hỏa làm mặc định cho một hình thái khác. Nếu chưa có rig đúng, giữ ảnh tĩnh.

## Phiếu thiết kế tối thiểu

- Tên loài và hình thái tham chiếu:
- Hệ và vai trò chiến đấu:
- Dáng tổng thể, số đầu/chân, loại cánh/vây:
- Điểm khác biệt với các rồng hiện tại:
- Tư thế, biểu cảm, bảng màu, chi tiết nguyên tố:
- Các bộ phận cần chuyển động và điểm khớp:
- Ảnh, mặt nạ/rig, portrait và dữ liệu cần bổ sung:

Hiện tại chỉ lưu định hướng và ảnh tham chiếu; chưa thêm loài, hệ hay luật chiến đấu mới.

Khi bổ sung loài mới có trạng thái nghỉ, tạo thêm tư thế nằm ngủ riêng, giữ đúng hình thái của loài; khai báo đường dẫn ảnh ngủ và điểm chạm nền để khi chuyển tư thế không bị nhảy vị trí. Không dùng lại tư thế ngủ của loài khác.

