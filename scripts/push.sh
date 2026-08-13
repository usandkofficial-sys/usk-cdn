#!/usr/bin/env bash
#
# push.sh — 작업이 끝난 후 실행하세요.
# 변경사항을 커밋하고 GitHub에 올립니다.
#
# 사용법:
#   ./scripts/push.sh                 # 자동 메시지로 커밋
#   ./scripts/push.sh "커밋 메시지"    # 직접 메시지 지정
#
set -euo pipefail

# 저장소 루트로 이동 (스크립트 위치 기준)
cd "$(dirname "$0")/.."

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# 올릴 변경이 없으면 종료
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "ℹ️  올릴 변경사항이 없습니다."
  exit 0
fi

# 커밋 메시지 (인자로 받거나 자동 생성)
MSG="${1:-"update: $(date '+%Y-%m-%d %H:%M:%S')"}"

echo "➕ 변경사항을 추가합니다..."
git add -A

echo "📝 커밋: $MSG"
git commit -m "$MSG"

echo "🚀 [$BRANCH] 로 올립니다..."
# 네트워크 오류 시 지수 백오프로 최대 4회 재시도
n=0
until git push -u origin "$BRANCH"; do
  n=$((n+1))
  if [ "$n" -ge 4 ]; then
    echo "❌ 4회 시도 후 실패했습니다. 네트워크를 확인하세요."
    exit 1
  fi
  wait=$((2 ** n))
  echo "⏳ 실패. ${wait}초 후 재시도합니다... ($n/4)"
  sleep "$wait"
done

echo "✅ 완료! 다른 기기에서 ./scripts/pull.sh 로 받을 수 있습니다."
