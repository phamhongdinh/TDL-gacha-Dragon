# Hướng Dẫn Deploy Backend Cloudflare (Worker/Pages + D1 / KV)

Tất cả các file cần thiết đã được tạo sẵn trong project của bạn:
- **File Worker độc lập (1 file duy nhất)**: [`cloudflare/worker.js`](file:///c:/Users/ASUS/Documents/Codex/TDL-gacha-Dragon/cloudflare/worker.js)
- **File Pages Function (tự nhận khi đẩy lên Cloudflare Pages)**: [`functions/api/[[route]].js`](file:///c:/Users/ASUS/Documents/Codex/TDL-gacha-Dragon/functions/api/[[route]].js)
- **File tạo bảng SQLite D1**: [`cloudflare/schema.sql`](file:///c:/Users/ASUS/Documents/Codex/TDL-gacha-Dragon/cloudflare/schema.sql)
- **File cấu hình Wrangler**: [`cloudflare/wrangler.toml`](file:///c:/Users/ASUS/Documents/Codex/TDL-gacha-Dragon/cloudflare/wrangler.toml)

---

## Cách A: Chạy bằng lệnh Terminal (Wrangler CLI — Nhanh nhất)

Mở PowerShell / Terminal tại thư mục gốc project `TDL-gacha-Dragon` và chạy lần lượt:

### 1. Đăng nhập tài khoản Cloudflare
```powershell
npx wrangler login
```

### 2. Lệnh tạo Database D1 (SQLite) hoặc KV

#### Lựa chọn 1: Tạo Cloudflare D1 Database (Khuyên dùng)
```powershell
# Tạo database tên là dragon_awakening_db
npx wrangler d1 create dragon_awakening_db
```
Sau khi chạy lệnh trên, Terminal sẽ in ra `database_id = "xxxx-xxxx-xxxx"`. Bạn mở file [`cloudflare/wrangler.toml`](file:///c:/Users/ASUS/Documents/Codex/TDL-gacha-Dragon/cloudflare/wrangler.toml), bỏ dấu `#` ở mục `[[d1_databases]]` và dán `database_id` vào, sau đó chạy lệnh khởi tạo bảng:
```powershell
npx wrangler d1 execute dragon_awakening_db --remote --file=cloudflare/schema.sql
```
*(Lưu ý: Kể cả bạn quên chạy `schema.sql`, code trong `worker.js` cũng đã có hàm `ensureD1Tables()` tự động tạo bảng `users` và `world_boss` ngay ở lần gọi đầu tiên!)*

#### Lựa chọn 2: Nếu bạn thích dùng Cloudflare KV thay vì D1
```powershell
npx wrangler kv namespace create DRAGON_KV
```
Copy `id` hiện ra dán vào mục `[[kv_namespaces]]` trong [`cloudflare/wrangler.toml`](file:///c:/Users/ASUS/Documents/Codex/TDL-gacha-Dragon/cloudflare/wrangler.toml).

### 3. Deploy lên Cloudflare

- **Nếu chỉ muốn chạy thử ngay Backend API (Worker)**:
  ```powershell
  npx wrangler deploy cloudflare/worker.js --name tdl-gacha-dragon-api --compatibility-date 2024-11-01
  ```
  Cloudflare sẽ cấp cho bạn đường dẫn dạng: `https://tdl-gacha-dragon-api.<ten-ban>.workers.dev`.
  Bạn chỉ cần mở game -> Bấm **"👤 Tài khoản"** ở góc trên Trang chủ -> Dán link `https://tdl-gacha-dragon-api.<ten-ban>.workers.dev/api` vào ô **Cloudflare API URL** là đồng bộ trực tiếp!

- **Nếu muốn đẩy cả bản Web Game (`builds/web`) + API (`/api/*`) lên Cloudflare Pages**:
  ```powershell
  npx wrangler pages deploy builds/web --project-name tdl-gacha-dragon
  ```

---

## Cách B: Thao tác trực tiếp trên Web Cloudflare Dashboard (Không cần gõ lệnh)

1. Vào **Cloudflare Dashboard** -> **Storage & Databases** -> **D1 SQL Database** -> Bấm **Create Database** -> Đặt tên `dragon_awakening_db`.
2. Vào **Workers & Pages** -> **Create** -> **Create Worker** -> Đặt tên `tdl-gacha-dragon-api` -> Bấm **Deploy**.
3. Bấm **Edit Code**, xóa code mẫu đi và **copy toàn bộ nội dung file [`cloudflare/worker.js`](file:///c:/Users/ASUS/Documents/Codex/TDL-gacha-Dragon/cloudflare/worker.js)** dán vào -> Bấm **Deploy** ở góc phải trên.
4. Vào tab **Settings** của Worker -> **Bindings** -> **Add** -> Chọn **D1 database**:
   - **Variable name**: gõ chính xác là `DB` (hoặc nếu dùng KV thì chọn KV namespace và đặt tên biến là `DRAGON_KV`).
   - Chọn database `dragon_awakening_db` -> Bấm **Save**.
5. Lấy đường dẫn Worker (`https://tdl-gacha-dragon-api.<subdomain>.workers.dev/api`) dán vào mục **👤 Tài khoản** trong game là 3 người có thể đăng nhập, lưu data và cùng đánh Boss Thế Giới!
