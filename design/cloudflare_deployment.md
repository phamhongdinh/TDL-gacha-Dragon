# Triển khai Cloudflare Pages miễn phí

Link chính: https://tdl-gacha-dragon.pages.dev/

Dự án Cloudflare Pages: tdl-gacha-dragon. Bản này chỉ dùng static assets, không có Pages Functions, Worker xử lý, R2, cơ sở dữ liệu hoặc tài nguyên trả phí. Không bật nâng cấp gói.

Bản Godot dùng single-thread. WebAssembly gốc khoảng 33,7 MiB, vượt giới hạn 25 MiB/file của Pages. Công cụ chuẩn bị nén thành index.wasm.gz khoảng 7,7 MiB. cloudflare-loader.js tải file gzip, giải nén bằng DecompressionStream rồi trả Response application/wasm cho Godot. Không gắn Content-Encoding thủ công để tránh Cloudflare nén chồng. Không thay file xuất local gốc.

## Cập nhật bản game sau này

1. Xuất Godot Web mới vào thư mục outputs/dragon-web hiện tại.
2. Chạy ở thư mục project:

```powershell
node tools/prepare_cloudflare.cjs 'C:/Users/ASUS/Documents/Codex/2026-11-09/t-x20-2/outputs/dragon-web' 'C:/Users/ASUS/Documents/Codex/2026-11-09/t-x20-2/outputs/cloudflare-pages'
npx wrangler pages deploy 'C:/Users/ASUS/Documents/Codex/2026-11-09/t-x20-2/outputs/cloudflare-pages' --project-name tdl-gacha-dragon --branch main
```

Wrangler dùng phiên đăng nhập Cloudflare trên máy. Không chép token vào source hoặc thư mục public. Chỉ upload thư mục cloudflare-pages đã chuẩn bị, không upload toàn bộ project.

## Kiểm tra đã hoàn tất

- Cloudflare nhận bản production, HTTPS hoạt động.
- Bộ nạp công khai giải nén được 35.376.909 byte, mã WASM 0061736d, byte-for-byte trùng bản gốc.
- Từng file tải lên dưới 25 MiB; không dùng functions.
- Link gốc pages.dev là link chia sẻ ổn định; các link có mã hash là bản triển khai cụ thể.

Game vẫn lưu tiến độ ở trình duyệt trên từng domain. Dữ liệu localhost không tự chuyển sang domain pages.dev, cũng không tự đồng bộ giữa điện thoại và máy tính. Không sửa/xóa bản lưu localhost khi triển khai.
