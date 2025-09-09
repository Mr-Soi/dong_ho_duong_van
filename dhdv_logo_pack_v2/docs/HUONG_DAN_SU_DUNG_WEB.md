# HƯỚNG DẪN TRIỂN KHAI LOGO TRÊN WEBSITE (donghoduongvan.com)

## Mục tiêu
- Đưa logo chính thức của dòng họ lên website, hiển thị chuẩn trên header, trang chủ và favicon.

## Cấu trúc & file cần dùng
- Logo ngang (header): `svgs/duongvan_logo_horizontal.svg`
- Logo dọc (trang chủ/banner): `svgs/duongvan_logo_vertical.svg`
- Favicon: `svgs/favicon.svg` (tùy chọn thêm `favicon.ico`)

> Khuyến nghị: Giữ nguyên tên file như trên để tiện bảo trì.

---

## 1) Vị trí đặt file tĩnh (ASP.NET Core)
- Sao chép các file SVG vào thư mục tĩnh, ví dụ: `wwwroot/assets/logo/`
- Kết quả mẫu:
  - `wwwroot/assets/logo/duongvan_logo_horizontal.svg`
  - `wwwroot/assets/logo/duongvan_logo_vertical.svg`
  - `wwwroot/assets/logo/favicon.svg`

> Nếu site dùng Nginx/Caddy để phục vụ tĩnh, đảm bảo map thư mục `/assets/logo/` đúng đường dẫn.

---

## 2) Logo header (biến thể ngang)
**HTML (Razor):**
```html
<!-- _Layout.cshtml (ví dụ) -->
<a class="navbar-brand" href="@Url.Content("~/")" aria-label="Dòng họ Dương Văn">
  <img src="~/assets/logo/duongvan_logo_horizontal.svg"
       alt="Logo Dương Văn"
       style="max-height:56px; height:auto; width:auto; object-fit:contain;" />
</a>
```

**Lưu ý:**
- Nếu chiều cao header < 64px, có thể dùng phiên bản không khẩu hiệu (tuỳ chỉnh) hoặc giảm max-height về ~48px.
- Giữ `object-fit: contain;` để logo không bị méo hình khi CSS co giãn.

---

## 3) Logo trang chủ/banner (biến thể dọc)
**HTML (Razor):**
```html
<section class="hero text-center">
  <img src="~/assets/logo/duongvan_logo_vertical.svg"
       alt="Logo Dương Văn"
       style="max-width:420px; width:100%; height:auto;" />
</section>
```

**Gợi ý:**
- Dùng trên nền sáng, để logo nổi bật.
- Tránh nền quá nhiễu (giảm tương phản).

---

## 4) Favicon
**Thêm vào `<head>` (Razor):**
```html
<link rel="icon" type="image/svg+xml" href="~/assets/logo/favicon.svg">
<!-- Tùy chọn fallback cho trình duyệt cũ: -->
<link rel="alternate icon" type="image/x-icon" href="~/favicon.ico">
```

**Tạo `favicon.ico` (tuỳ chọn):**
- Dùng ImageMagick (PowerShell/Windows):
```powershell
magick convert -background transparent `
  wwwroot/assets/logo/favicon.svg `
  -define icon:auto-resize=16,32,48,64 wwwroot/favicon.ico
```
- Hoặc dùng công cụ chuyển đổi trực tuyến uy tín nếu không cài phần mềm.

---

## 5) Kiểm thử hiển thị
- Mở trang chủ trên **Desktop + Mobile** (Chrome/Safari/Edge) kiểm tra độ nét và tương phản.
- Thu nhỏ header: đảm bảo logo vẫn rõ, không cắt mất phần chữ.
- Kiểm favicon hiển thị đúng trên tab trình duyệt.

---

## 6) ✅ Checklist nhanh
- [ ] Upload `duongvan_logo_horizontal.svg` vào `/assets/logo/` và gắn vào header.
- [ ] Upload `duongvan_logo_vertical.svg` và gắn vào hero/trang chủ.
- [ ] Thêm thẻ `<link rel="icon" ...>` trỏ về `favicon.svg`.
- [ ] (Tuỳ chọn) Tạo `favicon.ico` và thêm `<link rel="alternate icon" ...>`.
- [ ] Kiểm thử responsive: header < 64px thì hạn chế khẩu hiệu, giữ logo rõ nét.

---

## 7) Lỗi thường gặp
- **SVG không hiển thị đủ:** Kiểm tra đường dẫn tĩnh và quyền truy cập (HTTP 200). 
- **Logo bị mờ khi thu nhỏ:** Giảm chi tiết (ẩn khẩu hiệu ở header), hoặc tăng `max-height` vài px.
- **Nền/tương phản kém:** Ưu tiên nền sáng/đơn sắc, tránh hình nền quá rối.

---

© Dòng họ Dương Văn — Hướng dẫn triển khai web (Torch Edition).
