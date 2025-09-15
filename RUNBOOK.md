# DHDV — Restore .bak → Compat → Smoke (One-click)

## Prereqs
- Containers: `dhdv_sql`, `dhdv_web` đang chạy (Docker Desktop).
- `web.env` cấu hình: `ConnectionStrings__DefaultConnection=...;Database=dhdv;...`.

## Bước 1 — Tạo hoặc lấy file .bak
- Tạo .bak tại môi trường nguồn:
  ```powershell
  # xem mục 1 trong hướng dẫn (tạo .bak)
