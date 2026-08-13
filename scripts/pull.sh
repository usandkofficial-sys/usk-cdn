#!/usr/bin/env bash
#
# pull.sh — 작업 시작 전에 실행하세요.
# 다른 기기(아이맥/맥북/웹)가 올린 최신 내용을 안전하게 받아옵니다.
# 로컬에 커밋하지 않은 변경이 있으면 잠시 보관(stash)했다가 다시 복원합니다.
#
set -euo pipefail

# 저장소 루트로 이동 (스크립트 위치 기준)
cd "$(dirname "$0")/.."

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo "🔄 [$BRANCH] 최신 내용을 받아옵니다..."

# 커밋 안 된 변경이 있으면 임시 보관
STASHED=0
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "📦 커밋되지 않은 변경을 임시 보관합니다."
  git stash push -u -m "auto-stash before pull ($(date '+%Y-%m-%d %H:%M:%S'))"
  STASHED=1
fi

# 최신 내용 받기 (rebase로 히스토리 깔끔하게)
git pull --rebase origin "$BRANCH"

# 보관해둔 변경 복원
if [ "$STASHED" -eq 1 ]; then
  echo "📤 보관했던 변경을 복원합니다."
  git stash pop
fi

echo "✅ 최신 상태입니다. 이제 작업을 시작하세요."
