# Animation mạnh hơn và trạng thái ngủ

- Cánh tăng biên độ từ 0,045 lên 0,14 radian, giữ chuyển động quanh khớp và độ trễ hai bên. Thân có nhịp thở/sway rõ hơn, chân bám nền.
- Lửa dài hơn, tăng độ uốn và chuyển động dòng bên trong các vùng lửa đã định vị.
- Trang chủ: sau 12 giây không tương tác, rồng buồn ngủ; sau 15 giây chuyển sang tư thế nằm ngủ riêng. Rồng ngủ vẫn thở nhẹ và có ký hiệu z nổi lên.
- Click/chạm hoặc bấm phím để đánh thức. Di chuột khi đang thức đặt lại thời gian chờ; chỉ di chuột qua rồng đã ngủ không đánh thức.
- Không bật ngủ trong chiến đấu, kết quả triệu hồi hoặc các thẻ nhỏ mặc định.
- Long điển có nút Xem chuyển động: xem rồng lớn, Thử nằm ngủ và Đánh thức để kiểm tra trực tiếp mà không thay đổi bộ sưu tập.

## Ảnh được tạo và lưu

Dùng built-in image_gen (skill imagegen), không dùng CLI/API fallback. Bảy ảnh PNG có alpha, tư thế nằm riêng, giữ ảnh gốc hiện có.

Thư mục trong project: C:/Users/ASUS/Documents/Codex/TDL-gacha-Dragon/assets/textures/dragons/sleeping/

Các file: fire.png, water.png, shadow.png, fire_water.png, fire_shadow.png, water_shadow.png, triple.png.

Ảnh nguồn lần lượt là file cùng tên ở assets/textures/dragons/. Tất cả đầu ra đã chép vào project, không chỉ tham chiếu bản mặc định của công cụ.

## Prompt chính xác

Chạy một lần cho từng tên `fire`, `water`, `shadow`, `fire_water`, `fire_shadow`, `water_shadow`, `triple`; thay `{name}` bằng tên đó, dùng ảnh gốc cùng tên làm edit target và yêu cầu transparent_background=true:

> Edit target: the supplied {name} dragon game sprite. Create ONE matching alternate sleeping-pose game sprite of this exact individual dragon. Preserve its species, chibi illustration style, colors, horns, scales, wing type, markings, elemental identity and rendering quality. Change pose to genuinely lying down asleep: belly rests on the ground, legs folded underneath, head lowered onto forepaws, closed relaxed eyes, tail curled alongside the body, wings folded close if it has wings. For the long water dragons, coil the long serpentine body naturally on the ground. Keep fire small and calm. Entire dragon fits inside a square canvas with generous transparent margin. No floor, no bed, no background, no shadows painted as background, no letters, no Z symbols, no labels, no extra objects. True transparent background. Keep facing direction consistent with reference. Intended for an in-game idle-sleep state, clean alpha silhouette. Only one dragon.

## Kiểm tra

`tests/dragon_animation_integration.gd`: bảy rig, chớp mắt thưa, ảnh lật, không gắn trùng và không áp lên quái.

`tests/dragon_sleep_integration.gd`: đủ bảy tư thế, ngưỡng 35/15 giây, tắt ngủ mặc định trong chiến đấu, tư thế thở, ảnh lật, di chuột không đánh thức, click đánh thức, xem thử và tắt/reset.

Điểm chạm nền của hai tư thế được đo theo alpha trên ảnh gốc, lưu trong SLEEP_GROUND của DragonAnimator. Không đọc lại toàn bộ pixel ảnh trên web mỗi lần xem. Khi thay ảnh cần đo lại hai giá trị này để tránh rồng bị nổi hoặc lún nền.

