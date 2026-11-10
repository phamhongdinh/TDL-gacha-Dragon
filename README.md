# Dragon Awakening

Game 2D gacha rồng được dựng bằng Godot 4. Đã có Home chibi, Long điển, Bộ sưu tập, gacha ×1/×10, bảo hiểm 60, hợp thể và PvE theo lượt với lưu cục bộ. PvE có ba kỹ năng hệ, đội tối đa ba rồng, hai đợt quái mỗi màn, tinh anh và thưởng. Nuôi rồng chưa triển khai đầy đủ. Xem `design/pve_requirements.md` để biết cơ chế và giới hạn bản mẫu.

## Định hướng hiện tại

- Cốt truyện: quái vật cổ đại dưới lòng đất thức tỉnh và hóa thân thành tộc rồng để chống trả.
- Gacha là cách chính để nhận và sưu tầm rồng.
- Lai tạo là tính năng phụ, tỉ lệ thành công thấp; có thể tạo biến thể lai hiếm, gồm rồng tam hệ đặc biệt.
- Ba hệ ban đầu: Hỏa, Thủy, Bóng Tối/Hư Không.
- Bản đầu dành cho nhóm 3 người tìm hiểu, chạy trên PC, lưu cục bộ; chưa có đăng nhập, server hay giao dịch thật.

## Mở project

1. Cài Godot 4.x.
2. Mở Godot Project Manager, chọn **Import**.
3. Chọn file `project.godot` trong thư mục dự án.
4. Nhấn **Run Project**.

Home hiện có long động, rồng Thủy chibi chuyển động nhẹ, tài nguyên mẫu, thẻ cốt truyện, banner Triệu hồi và 5 mục điều hướng. Bộ sưu tập và Triệu hồi mở màn hình tương ứng; các tính năng khác hiện thông báo xem trước. Trong Triệu hồi, bấm Roll ×1 hoặc Roll ×10 để nhận rồng, xem kết quả và chuyển sang Bộ sưu tập. Hiện quay miễn phí thử nghiệm, không trừ các tài nguyên mẫu trên Home. Rồng được tự động lưu tại `user://collection.json`. Thiết kế dùng viewport 1280×720 và tự co giãn theo cửa sổ. Các hình SVG được vẽ riêng trong `assets/textures/`, không cần tải asset bên ngoài.

## Cấu trúc thư mục

```text
dragon_awakening/
├── assets/
│   ├── audio/
│   ├── fonts/
│   ├── icons/
│   └── textures/
├── resources/
│   ├── banners/
│   ├── dragons/
│   └── breeding/
├── scenes/
│   ├── main/
│   ├── gacha/
│   ├── collection/
│   ├── breeding/
│   └── battle/
├── scripts/
│   ├── core/
│   ├── data/
│   │   ├── enums/
│   │   └── models/
│   ├── systems/
│   └── ui/
│       ├── screens/
│       └── components/
├── design/
│   └── references/
└── project.godot
```

## Class dự kiến

| Nhóm | Class | Vai trò dự kiến |
|---|---|---|
| Core | `AppRoot` | Điểm vào và khởi tạo giao diện chính |
| Core | `GameManager` | Điều phối trạng thái game và các hệ thống |
| Core | `SaveManager` | Đọc/ghi tiến trình cục bộ |
| Core | `SceneRouter` | Chuyển màn hình |
| Data | `ElementType` | Enum hệ rồng: Hỏa, Thủy, Bóng Tối |
| Data | `DragonRarity` | Enum độ hiếm |
| Data | `DragonDefinition` | Dữ liệu mẫu cố định của một loài rồng |
| Data | `DragonInstance` | Một cá thể rồng người chơi sở hữu |
| Data | `DragonLineage` | Quan hệ bố mẹ và nguồn gốc rồng lai |
| Data | `PlayerProfile` | Thông tin tiến trình người chơi |
| Data | `BannerDefinition` | Cấu hình banner gacha |
| Data | `GachaResult` | Kết quả một lượt quay |
| Data | `BreedingRecipe` | Điều kiện/cặp rồng dùng để lai |
| Data | `BreedingResult` | Kết quả lần lai |
| Data | `BattleUnitData` | Dữ liệu rồng trong trận |
| Data | `BattleResult` | Kết quả trận đấu |
| Systems | `DragonCatalog` | Tra cứu dữ liệu rồng |
| Systems | `BannerManager` | Quản lý banner đang mở |
| Systems | `GachaManager` | Xử lý lượt quay và kết quả gacha |
| Systems | `PlayerCollection` | Quản lý bộ sưu tập rồng |
| Systems | `InventoryManager` | Quản lý vé quay và tài nguyên |
| Systems | `BreedingManager` | Xử lý luật và kết quả lai rồng |
| Systems | `BattleManager` | Điều phối trận chiến |
| Systems | `RewardManager` | Tính và cấp phần thưởng |
| UI | `MainMenuScreen` | Màn hình chính |
| UI | `GachaScreen` | Màn hình quay rồng |
| UI | `DragonCollectionScreen` | Danh sách rồng sở hữu |
| UI | `DragonDetailScreen` | Chi tiết cá thể rồng |
| UI | `BreedingScreen` | Màn hình chọn rồng lai |
| UI | `BattleScreen` | Màn hình chiến đấu |
| UI | `BattleResultPopup` | Kết quả sau trận |
| UI | `DragonCard` | Thẻ hiển thị rồng tái sử dụng |
| UI | `ConfirmDialog` | Hộp thoại xác nhận dùng chung |

Home, Bộ sưu tập, Triệu hồi và Lai tạo đã nối điều hướng. GachaManager, BreedingManager, PlayerCollection và SaveManager xử lý quay, lai, sở hữu và lưu dữ liệu. Nuôi và chiến đấu vẫn là placeholder. Yêu cầu các màn được ghi trong `design/`.

## Triệu hồi và âm thanh

Roll ×1/×10 có hoạt ảnh vòng triệu hồi, trứng rung và nứt, vỡ vỏ, rồi rồng xuất hiện trước bảng kết quả. Rồng hai hệ có hiệu ứng vàng và hợp âm riêng. Có nút Bỏ qua; kết quả đã lưu trước khi hoạt ảnh bắt đầu nên bỏ qua không tạo thêm lượt hay mất rồng. Tỉ lệ cơ bản 0,1%; sau 59 lượt không trúng vàng, lượt 60 đảm bảo rồng nổi bật. Trúng vàng đặt bộ đếm về 0, kể cả giữa gói ×10. Bộ đếm lưu cùng bộ sưu tập. File lưu cũ vẫn giữ rồng và bắt đầu bộ đếm mới từ 0.

Bảy mẫu rồng dùng PNG nền trong suốt, vẽ lại theo mockup tham chiếu bằng ImageGen tích hợp: Hỏa, Thủy, Bóng Tối, Hỏa–Thủy, Hỏa–Bóng Tối, Thủy–Bóng Tối và Tam Hệ. Ảnh nằm trong `assets/textures/dragons/`; Home, banner, hoạt ảnh nở và Bộ sưu tập dùng cùng asset.

×10 hiện mười trứng theo màu nguyên tố, nở đồng loạt. Rồng rate-up phóng to từ ô của nó sau khi nở xong. UI Triệu hồi có danh sách banner, bệ triệu hồi và thanh bảo hiểm. Lai tạo: hai rồng 1 hệ khác nhau có 5% ra 2 hệ; hai rồng 2 hệ đủ ba nguyên tố có 1% ra Tam Hệ. Bố mẹ được giữ nguyên, không tốn phí bản thử, không ảnh hưởng bảo hiểm Gacha. Thông tin bố mẹ của rồng con được lưu.

Âm thanh gồm nhạc nền long động và tiếng rê/bấm nút, tích năng lượng, nứt vỏ, nở trứng, lộ diện thường/hiếm. Mở **Cài đặt** từ nút dấu ba chấm trên Trang chủ để bật/tắt toàn bộ âm hoặc chỉnh riêng nhạc nền/hiệu ứng; lựa chọn được lưu. Không có nút âm nổi trên các màn khác. Nhạc bắt đầu sau lần tương tác đầu tiên để tương thích trình duyệt. WAV được tự tạo bằng `python tools/generate_audio.py`, không dùng nhạc bên thứ ba. Font Noto được đóng gói cùng giấy phép SIL OFL trong `assets/fonts/OFL.txt`.

Giao diện và tên hiển thị dùng tiếng Việt: **Long Tộc Thức Tỉnh**. Tên cấu hình nội bộ được giữ để không đổi vị trí lưu cũ. Màn Triệu hồi chỉ có nút Quay lại để điều hướng, số kim cương ở trên phải, giới thiệu rồng nổi bật phía dưới và nút Chi tiết tỉ lệ nhỏ mở bảng nổi. Không hiện khung xác suất lớn hoặc tổng rồng sở hữu. Kim cương là số dư hồ sơ cục bộ, khởi đầu 280 cho dữ liệu cũ chưa có trường này; lượt triệu hồi hiện vẫn miễn phí.

**Hợp thể rồng thần** chọn rồng bằng loại và hình, tự dùng cá thể đầu tiên tương ứng. Kết quả và phần trăm không được tiết lộ trên màn chính; nút Xem tổ hợp rồng mở danh sách công thức có hình. Hợp thể thành công tạo trứng nở chậm, với hiệu ứng đặc biệt cho rồng hai hệ/Tam Hệ.

Mỗi lần Hợp thể luôn nhận một rồng: nếu không ra rồng thần thì nhận rồng một hệ thuộc nguyên tố hai rồng ban đầu, vẫn hiện trứng nở và rồng nhận được. Mỗi lần có thời gian hồi 30 giây từ lúc bắt đầu, được lưu cùng kết quả để không mất khi tải lại trang. Hai rồng ban đầu được giữ nguyên.

Nút Xem tổ hợp rồng chỉ bật khi chọn đủ hai loại; chỉ hiện các kết quả của chính cặp đó, gồm kết quả rồng thần và kết quả thường, không hiện phần trăm hoặc công thức khác.

## Export Web

Godot 4.3 Standard, export template cùng phiên bản. Preset `Web` dùng Compatibility và tắt Thread Support, không cần header cross-origin isolation. Tạo thư mục `builds/web`, rồi chạy:

```powershell
godot --headless --path . --export-release Web builds/web/index.html
python -m http.server 8060 --bind 127.0.0.1 --directory builds/web
```

Mở `http://127.0.0.1:8060`. Phải phục vụ toàn bộ thư mục export qua HTTP/HTTPS; không mở `index.html` bằng file://. Có thể đưa các file export lên static hosting sau. Bản web lưu riêng trong IndexedDB của trình duyệt; không tự đồng bộ với bản desktop và sẽ mất nếu xóa dữ liệu trang. Không có đăng nhập hay máy chủ gameplay.

Kiểm thử hoạt ảnh và âm thanh: chạy `godot --headless --path . --script res://tests/gacha_integration.gd` với APPDATA trỏ tới thư mục thử riêng.

Hợp thể Tam Hệ cũng hỗ trợ một rồng hai hệ + rồng một hệ còn thiếu, tỉ lệ 1%, ở cả hai thứ tự chọn. Nếu nguyên tố rồng một hệ đã nằm trong rồng hai hệ thì không đủ điều kiện.

## Tham chiếu khi thêm loài rồng

Xem [Hướng dẫn hình thái rồng mới](design/dragon_species_guide.md) và [ảnh người dùng cung cấp](design/references/dragon-body-types.png). Loài mới cần khác dáng và cấu trúc, không chỉ đổi màu/hệ trên cùng model.
