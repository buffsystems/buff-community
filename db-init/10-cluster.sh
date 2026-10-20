#!/bin/bash
# Базы и роли установки при первой инициализации кластера (как миграции 001/002/004/006 роли
# db мастера): пароль служебных ролей — тот же, что у postgres. Запускается образом postgres
# один раз, когда каталог данных пуст.
set -euo pipefail
psql -v ON_ERROR_STOP=1 -v pg_password="$POSTGRES_PASSWORD" -U postgres -d postgres <<'SQL'
SELECT 'CREATE ROLE windmill_user' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'windmill_user')\gexec
SELECT 'CREATE ROLE windmill_admin WITH BYPASSRLS' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'windmill_admin')\gexec
SELECT format('CREATE ROLE windmill LOGIN CREATEROLE PASSWORD %L', :'pg_password') WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'windmill')\gexec
GRANT windmill_user TO windmill_admin;
GRANT windmill_admin TO windmill;
GRANT windmill_user TO windmill;
SELECT 'CREATE DATABASE windmill OWNER windmill' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'windmill')\gexec
SELECT format('CREATE ROLE gitea LOGIN PASSWORD %L', :'pg_password') WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'gitea')\gexec
SELECT 'CREATE DATABASE gitea OWNER gitea' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'gitea')\gexec
SELECT 'CREATE DATABASE buffcode' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'buffcode')\gexec
SELECT format('CREATE ROLE backend_api LOGIN PASSWORD %L', :'pg_password') WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'backend_api')\gexec
SELECT format('CREATE ROLE admin_panel LOGIN PASSWORD %L', :'pg_password') WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'admin_panel')\gexec
SQL
psql -v ON_ERROR_STOP=1 -U postgres -d windmill <<'SQL'
GRANT USAGE ON SCHEMA public TO windmill_user, windmill_admin;
GRANT ALL ON ALL TABLES IN SCHEMA public TO windmill_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO windmill_user;
ALTER DEFAULT PRIVILEGES FOR ROLE windmill IN SCHEMA public GRANT ALL ON TABLES TO windmill_user;
ALTER DEFAULT PRIVILEGES FOR ROLE windmill IN SCHEMA public GRANT ALL ON SEQUENCES TO windmill_user;
GRANT CONNECT ON DATABASE windmill TO admin_panel;
SQL
echo "cluster: базы и роли установки созданы"
