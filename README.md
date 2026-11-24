# BigDataTrino — Лабораторная работа №4: ETL-пайплайн на базе Trino

Реализация распределенного ETL-процесса с использованием **Trino**, **PostgreSQL** и **ClickHouse**. Проект объединяет сырые данные из двух независимых источников (по 5 000 записей в каждом), преобразует их в многомерную модель **«Звезда» (Star Schema)** в ClickHouse и формирует 6 аналитических витрин отчетов.

---

## Архитектура решения

1. **Источники данных (Raw Layer):**
   - **ClickHouse (`default.mock_data`)** — 5 000 строк из первых 5 CSV-файлов (`MOCK_DATA.csv` — `MOCK_DATA (4).csv`).
   - **PostgreSQL (`public.mock_data`)** — 5 000 строк из следующих 5 CSV-файлов (`MOCK_DATA (5).csv` — `MOCK_DATA (9).csv`).
2. **DWH / Модель «Звезда» (`clickhouse.star_schema`):**
   - Таблица фактов: `fact_sales` (10 000 записей о продажах).
   - Таблицы измерений: `dim_customers`, `dim_sellers`, `dim_products`, `dim_stores`, `dim_suppliers`, `dim_dates`.
   - Детерминированные суррогатные ключи (`*_sk`) генерируются в Trino через `xxhash64`.
3. **Витрины отчетов (`clickhouse.reports`):**
   - `report_products` — витрина продаж по продуктам (топ продаж, выручка по категориям, средний рейтинг и отзывы).
   - `report_customers` — витрина продаж по клиентам (топ покупателей, распределение по странам, средний чек).
   - `report_time` — витрина продаж по времени (месячные и годовые тренды, сравнение периодов MoM, средний размер заказа).
   - `report_stores` — витрина продаж по магазинам (топ магазинов, распределение выручки по городам и странам, средний чек).
   - `report_suppliers` — витрина продаж по поставщикам (топ поставщиков, средняя цена товаров, распределение по странам).
   - `report_product_quality` — витрина качества продукции (рейтинги, количество отзывов, корреляция между рейтингом и объемом продаж).

---

## Структура репозитория

```text
├── data/                               # Исходные данные (10 файлов CSV по 1000 строк)
├── init-scripts/
│   ├── postgres_init.sql               # Создание таблицы и загрузка 5 CSV в PostgreSQL
│   └── clickhouse_init.sql             # Создание БД, таблиц Звезды, отчетов и загрузка 5 CSV в ClickHouse
├── trino/
│   └── catalog/
│       ├── postgresql.properties       # Конфигурация коннектора PostgreSQL для Trino
│       └── clickhouse.properties       # Конфигурация коннектора ClickHouse для Trino
├── trino_scripts/
│   ├── 01_etl_star_schema.sql          # ETL-скрипт: Источники (PG + CH) -> Модель Звезда (CH)
│   └── 02_create_reports.sql           # ETL-скрипт: Модель Звезда -> 6 витрин отчетов (CH)
├── docker-compose.yml                  # Оркестрация контейнеров PostgreSQL, ClickHouse и Trino
└── README.md                           # Документация и инструкция по запуску
```

---

## Инструкция по запуску и проверке

### 1. Запуск инфраструктуры
Из корневой директории проекта запустите контейнеры в фоновом режиме:
```bash
docker compose up -d
```
Дождитесь полной инициализации сервисов (около 15–20 секунд). При старте PostgreSQL и ClickHouse автоматически создадут таблицы и импортируют по 5 000 строк из папки `data/`.

### 2. Проверка загрузки исходных данных
Убедитесь, что в каждой базе находится по 5 000 записей:
```bash
# Проверка PostgreSQL (ожидается 5000)
docker exec -it lab_postgres psql -U user -d lab_db -c "SELECT COUNT(*) FROM mock_data;"

# Проверка ClickHouse (ожидается 5000)
docker exec -it lab_clickhouse clickhouse-client --query "SELECT COUNT(*) FROM default.mock_data;"
```

### 3. Запуск ETL-трансформации в модель «Звезда»
Выполните первый SQL-скрипт через Trino для объединения данных из обеих СУБД и заполнения таблиц измерений и фактов в ClickHouse:
```bash
docker exec -i lab_trino trino --catalog clickhouse --schema star_schema < trino_scripts/01_etl_star_schema.sql
```
Проверка заполнения таблицы фактов (ожидается `10000`):
```bash
docker exec -it lab_clickhouse clickhouse-client --query "SELECT COUNT(*) FROM star_schema.fact_sales;"
```

### 4. Формирование аналитических витрин (отчетов)
Выполните второй SQL-скрипт через Trino для расчета метрик и заполнения 6 таблиц отчетов в базе `reports`:
```bash
docker exec -i lab_trino trino --catalog clickhouse --schema reports < trino_scripts/02_create_reports.sql
```

---

## Проверка результатов в ClickHouse

Проверить сформированные витрины можно через **DBeaver** (подключение к ClickHouse: `localhost:8123`, пользователь `default`, без пароля; к PostgreSQL: `localhost:25432`, пользователь `user`, пароль `password`, БД `lab_db`) или напрямую через `clickhouse-client`:

```bash
docker exec -it lab_clickhouse clickhouse-client
```

```sql
-- 1. Топ-10 самых продаваемых продуктов
SELECT * FROM reports.report_products WHERE sales_rank <= 10 ORDER BY sales_rank;

-- 2. Топ-10 клиентов с наибольшей общей суммой покупок
SELECT * FROM reports.report_customers WHERE spent_rank <= 10 ORDER BY spent_rank;

-- 3. Месячные и годовые тренды продаж
SELECT * FROM reports.report_time ORDER BY year, month;

-- 4. Топ-5 магазинов с наибольшей выручкой
SELECT * FROM reports.report_stores WHERE revenue_rank <= 5 ORDER BY revenue_rank;

-- 5. Топ-5 поставщиков с наибольшей выручкой
SELECT * FROM reports.report_suppliers WHERE revenue_rank <= 5 ORDER BY revenue_rank;

-- 6. Анализ качества продукции (рейтинги, отзывы и корреляция с продажами)
SELECT * FROM reports.report_product_quality WHERE highest_rating_rank <= 10 ORDER BY highest_rating_rank;
```

### Остановка и очистка окружения
Для полной остановки контейнеров и удаления созданных томов выполните:
```bash
docker compose down -v
```
