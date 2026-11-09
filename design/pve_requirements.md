# Kỹ năng PvE — bản triển khai

Đánh thường: 100% tấn công, một mục tiêu. Kỹ năng sẵn sàng khi bắt đầu trận. Dùng ở lượt riêng thứ nhất thì phải hoàn thành lượt riêng 2, 3, 4; sẵn sàng lại ở lượt 5. Lượt bị đóng băng vẫn tính vào hồi chiêu.

| Hệ | Kỹ năng | Phạm vi | Hệ số | Hiệu ứng |
|---|---|---|---|---|
| Thủy | Băng Triều | Tất cả địch còn sống | 40% | Mỗi mục tiêu kiểm tra riêng 35% Đóng Băng |
| Hỏa | Hỏa Vũ | Tất cả địch còn sống | 50% | Không khống chế; một địch vẫn chỉ 50% |
| Bóng Tối | Hắc Ám Xuyên Tâm | Một địch do người chơi chọn | 160% | Nếu còn sống, bị Làm Mù |

Sát thương mẫu: max(1, làm tròn(tấn công × hệ số kỹ năng × khắc chế − 0,5 × phòng thủ)). Hỏa Vũ dùng 50% tấn công trước khắc chế và phòng thủ theo lựa chọn của người dùng.

Đóng Băng không cộng dồn, bỏ lượt hành động tiếp theo rồi hết. Sau đó mục tiêu miễn nhiễm Đóng Băng đến khi hoàn thành một hành động thực sự. Tinh anh miễn nhiễm, vẫn nhận sát thương và có phản hồi “Miễn nhiễm”.

Làm Mù không cộng dồn. Khi thực hiện hành động tấn công kế tiếp, kiểm tra đúng một lần với 50% khả năng hụt toàn bộ đòn, kể cả diện rộng. Hụt không gây sát thương hoặc hiệu ứng kèm theo, vẫn tốn lượt và hồi chiêu. Làm Mù hết sau tấn công dù trúng hay hụt; được giữ qua lượt bị Đóng Băng và hành động hồi máu/tạo giáp. Tinh anh có thể bị Làm Mù.

## Bản mẫu chơi được

- Chọn tối đa ba rồng đang sở hữu, thứ tự hành động theo tốc độ.
- Ba màn mở lần lượt; mỗi màn gồm ba quái thường, sau đó tinh anh và hai hỗ trợ. Giữ máu qua đợt, đầy máu khi bắt đầu màn mới.
- Sâu nhắm mục tiêu có phần trăm máu thấp nhất; nấm gây độc 5% máu tối đa trong hai lượt; tinh anh báo trước Chấn Động và cuồng nộ một lần khi còn 40% máu.
- Chọn đánh thường/kỹ năng để xem phạm vi và hệ số trước khi xác nhận. Trạng thái trên thanh máu có mô tả; nhật ký hiển thị Đóng băng, Hụt và Miễn nhiễm.
- Thưởng và sao được lưu cục bộ; thưởng đầu màn chỉ một lần. Ba sao tương ứng thắng, không rồng gục và hoàn thành trong tối đa mười vòng.

## Cấu hình và giới hạn bản mẫu

`resources/battle/config.json` chứa hệ, kỹ năng, trạng thái, quái, chỉ số và màn. `BattleCatalog` dựng đơn vị; `BattleManager` giải quyết lượt, mục tiêu, sát thương và trạng thái; `BattleScreen` hiển thị và xác nhận thao tác.

Chưa có bảng khắc chế được chốt nên các cặp mặc định trung tính; bổ sung trong `elements.*.counters`. Chỉ số và nội tại hiện là dữ liệu thử nghiệm để cân bằng sau. Rồng lai tạm dùng hệ đầu tiên trong dữ liệu làm hệ chiến đấu. Các kiểu trạng thái/kỹ năng mới ngoài những kiểu bộ máy hỗ trợ cần thêm trình xử lý tương ứng, không chỉ thêm tên vào JSON.

Kiểm thử tự động: `tests/battle_integration.gd`, gồm hệ số trước phòng thủ, ba lượt hồi chiêu, miễn nhiễm, Làm Mù diện rộng, hồi máu không tiêu Làm Mù, mục tiêu chết, độc, giữ máu qua đợt, báo trước tinh anh, trận thắng đầy đủ và thưởng một lần.
