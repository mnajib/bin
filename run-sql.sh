#!/usr/bin/env bash

set -euo pipefail

# Konfigurasi Pangkalan Data (Lalai daripada environment variables jika ada)
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-}"
TARGET_DB="${DB_NAME:-app2_db}"
SQL_FILE=""

# Fungsi bantuan (Help)
usage() {
    echo "Penggunaan: $0 --input-file <path_to_sql> [--db-name <database_name>]"
    echo ""
    echo "Pilihan Flag:"
    echo "  -i, --input-file   Path ke fail .sql yang hendak dijalankan (Wajib)"
    echo "  -d, --db-name      Nama pangkalan data sasaran (Pilihan, lalai: ${TARGET_DB})"
    echo "  -h, --help         Tunjukkan bantuan ini"
    exit 1
}

# Parse Command-Line Arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--input-file)
            SQL_FILE="$2"
            shift 2
            ;;
        -d|--db-name)
            TARGET_DB="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "❌ Flag tidak dikenali: $1"
            usage
            ;;
    esac
done

# Semak jika fail SQL disediakan
if [ -z "${SQL_FILE}" ]; then
    echo "❌ Ralat: Flag '--input-file' atau '-i' diperlukan."
    usage
fi

# Semak kewujudan fail SQL
if [ ! -f "${SQL_FILE}" ]; then
    echo "❌ Ralat: Fail '${SQL_FILE}' tidak ditemui."
    exit 1
fi

# Bina arahan asas MySQL
MYSQL_CMD=(mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}")

if [ -n "${DB_PASS}" ]; then
    MYSQL_CMD+=("-p${DB_PASS}")
fi

echo "==> Menjalankan '${SQL_FILE}' pada pangkalan data '${TARGET_DB}'..."

# Pastikan pangkalan data wujud
"${MYSQL_CMD[@]}" -e "CREATE DATABASE IF NOT EXISTS \`${TARGET_DB}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Jalankan fail SQL
"${MYSQL_CMD[@]}" "${TARGET_DB}" < "${SQL_FILE}"

echo "✔ Execution berjaya!"
