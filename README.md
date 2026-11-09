# Dragon Awakening

Khung dự án game 2D gacha rồng được dựng bằng Godot 4. Đây là bộ khung kiến trúc ban đầu: project, scene rỗng, thư mục và các class stub. Chưa triển khai logic gameplay.

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

Scene hiện tại cố ý để trống vì đây mới là khung kiến trúc.

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

Các script trong `scripts/` hiện là class stub rỗng để nhóm bổ sung sau. Các scene khác ngoài màn hình chính là placeholder.
