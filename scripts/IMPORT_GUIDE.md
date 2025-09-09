# Hướng dẫn nhập dữ liệu cũ vào site mới

## A) Khởi chạy Docker
```
docker compose up -d
```

## B) Khôi phục database cũ từ file .bak
1. Copy file `.bak` vào container SQL:
```
docker cp /path/to/your.bak dhdv_sql:/var/opt/mssql/backup/dongho.bak
```
2. Mở sh vào container và chạy sqlcmd:
```
docker exec -it dhdv_sql /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "RESTORE FILELISTONLY FROM DISK='/var/opt/mssql/backup/dongho.bak'"
```
3. Ghi lại `LOGICAL_NAME` cho data/log rồi thay vào `scripts/restore_from_bak_template.sql`.
4. Thực thi restore:
```
docker exec -i dhdv_sql /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -i /app/scripts/restore_from_bak_template.sql
```

## C) Chạy Importer
```
# OLD_CS là kết nối DB cũ vừa restore; NEW_CS là DB mới (dhdv)
OLD_CS="Server=localhost,1433;Database=don7069c_dongho;User ID=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;Encrypt=True" NEW_CS="Server=localhost,1433;Database=dhdv;User ID=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;Encrypt=True" ETL_CONFIG="src/DHDV.Import/etl.config.json" dotnet run --project src/DHDV.Import/DHDV.Import.csproj
```
- Trước khi chạy, có thể mở `etl.config.json` để chỉnh tên bảng/cột khớp DB cũ của bạn.
- Importer sẽ cố tự dò bảng/column phổ biến; nếu không khớp, chỉnh lại config.

## D) Khởi động web và kiểm tra
```
http://localhost:8080
```
