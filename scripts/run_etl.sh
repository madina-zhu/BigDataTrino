#!/usr/bin/env bash
# Полный прогон: инфраструктура -> (очистка) -> ETL в звезду -> витрины -> проверка.
set -euo pipefail
cd "$(dirname "$0")/.."

docker compose up -d

echo ">> Ожидание готовности PostgreSQL, ClickHouse и Trino (healthcheck)..."
for c in lab_postgres lab_clickhouse lab_trino; do
  for _ in $(seq 1 90); do
    [ "$(docker inspect -f '{{.State.Health.Status}}' "$c")" = "healthy" ] && break
    sleep 5
  done
  [ "$(docker inspect -f '{{.State.Health.Status}}' "$c")" = "healthy" ] || { echo "!! $c не стал healthy"; exit 1; }
  echo "   $c: healthy"
done

echo ">> Очистка звезды и витрин (идемпотентность)"
docker exec -i lab_clickhouse clickhouse-client --multiquery < scripts/reset_dwh.sql

echo ">> Trino: источники -> звезда"
docker exec lab_trino trino --file /scripts/01_etl_star_schema.sql

echo ">> Trino: звезда -> витрины"
docker exec lab_trino trino --file /scripts/02_create_reports.sql

echo ">> Проверка"
docker exec -i lab_clickhouse clickhouse-client --multiquery --format PrettyCompactMonoBlock < scripts/check.sql
