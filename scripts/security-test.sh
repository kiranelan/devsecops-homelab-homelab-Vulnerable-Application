#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${BASE_URL:-http://127.0.0.1:5000}"
REPORT_DIR="${REPORT_DIR:-reports}"
mkdir -p "${REPORT_DIR}"
REPORT="${REPORT_DIR}/waf-test-results.txt"
: > "${REPORT}"
run_test() {
  local name="$1"; shift
  local code
  code="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "$@")"
  printf '%-32s HTTP %s\n' "${name}" "${code}" | tee -a "${REPORT}"
}
run_test "Health" "${BASE_URL}/healthz"
run_test "Normal search" "${BASE_URL}/search?q=security"
run_test "SQL injection" "${BASE_URL}/search?q=%27%20OR%20%271%27=%271"
run_test "Admin header bypass" -H "X-Forwarded-For: 127.0.0.1" "${BASE_URL}/admin"
run_test "Debug disclosure" "${BASE_URL}/debug"
run_test "Stored XSS submission" -X POST --data-urlencode "author=tester" --data-urlencode "content=<script>alert('training')</script>" "${BASE_URL}/comment"
echo "Expected direct-app result: vulnerable requests succeed. Expected WAF result: SQLi/XSS return 403."
