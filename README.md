# DHDV Stack v5 (Web + UI + Import)
## Quick start
1) Install: .NET 8 SDK, Docker Desktop, SQL Server (local)
2) Unzip this package anywhere (e.g. F:\dhdv_stack_v5)
3) Update connection strings in `docker-compose.yml` if needed
4) Open PowerShell:
   ```powershell
   cd F:\dhdv_stack_v5
   .\deploy.ps1
   ```
5) Open http://localhost:8080

## DB bootstrap (optional)
Run scripts from `scripts/` in order:
 - init_dhdv.sql
 - create_indexes.sql
 - upgrade_posts.sql
 - normalize_categories.sql
 - normalize_albums.sql
 - create_vw_posts.sql, create_vw_persons.sql, create_vw_photos.sql (on legacy DB)
 - import_persons_relations.sql, import_albums_photos.sql
 - procs_views.sql
