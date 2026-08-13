# 🔄 아이맥 · 맥북 · Claude Code(웹) 작업 동기화 가이드

이 저장소(`usandkofficial-sys/usk-cdn`)를 **아이맥, 맥북, 그리고 Claude Code 웹**에서
끊김 없이 이어서 작업하기 위한 방법을 정리했습니다.

---

## 핵심 개념

동기화의 "허브"는 **GitHub 저장소 하나**입니다.
세 곳 모두 같은 저장소를 바라보므로, 흐름은 단순합니다.

```
아이맥  ──push──▶  ┌──────────────┐  ◀──pull──  맥북
                  │   GitHub      │
Claude(웹) ◀─pull─│  usk-cdn 저장소 │──push──▶  Claude(웹)
                  └──────────────┘
```

> ⚠️ **iCloud Drive / Dropbox 안에 저장소를 두지 마세요.**
> `.git` 폴더가 클라우드 앱과 충돌하면 히스토리가 깨집니다. 동기화는 오직 `git`으로만.

---

## 1. 최초 1회 설정 (아이맥 · 맥북 각각)

각 맥에서 저장소를 한 번만 복제(clone)합니다.

```bash
# 원하는 작업 폴더로 이동 (예: ~/work)
cd ~/work
git clone https://github.com/usandkofficial-sys/usk-cdn.git
cd usk-cdn
```

이름/이메일이 설정돼 있지 않다면:

```bash
git config user.name "본인 이름"
git config user.email "usandkofficial@gmail.com"
```

---

## 2. 매일 작업 흐름 (가장 중요)

**작업 시작 전 = 항상 최신으로 당기기 → 작업 → 끝나면 밀어올리기**

```bash
# ① 시작할 때: 다른 기기가 올린 최신 내용 받기
git pull

# ② 작업 (이미지/영상 추가, 파일 수정 등)

# ③ 끝날 때: 내 변경사항 올리기
git add -A
git commit -m "작업 내용 요약"
git push
```

이 3단계만 지키면 아이맥 → 맥북 → 웹 어디서든 이어집니다.
위 과정을 한 방에 처리하는 헬퍼 스크립트를 아래에 준비했습니다.

---

## 3. 헬퍼 스크립트

저장소의 `scripts/` 폴더에 두 개의 스크립트가 있습니다.

| 스크립트 | 하는 일 | 사용 시점 |
|---|---|---|
| `scripts/pull.sh` | 최신 내용 받기 (+ 로컬 변경 보호) | 작업 **시작 전** |
| `scripts/push.sh` | 변경사항 커밋 & 푸시 | 작업 **끝난 후** |

### 사용법

```bash
# 작업 시작 전
./scripts/pull.sh

# 작업 끝난 후 (커밋 메시지는 선택)
./scripts/push.sh "새 배너 이미지 3개 추가"
```

메시지를 생략하면 자동으로 날짜/시간이 붙은 메시지로 커밋됩니다.

### 별칭(alias)으로 더 짧게 (선택)

`~/.zshrc`에 추가하면 어느 폴더에서든 짧게 쓸 수 있습니다.

```bash
alias cdnpull='cd ~/work/usk-cdn && ./scripts/pull.sh'
alias cdnpush='cd ~/work/usk-cdn && ./scripts/push.sh'
```

적용: `source ~/.zshrc`

---

## 4. Claude Code(웹)에서 이어서 하기

지금 이 세션이 바로 웹에서 저장소에 연결된 상태입니다.

- 아이맥/맥북에서 `push` 한 내용은 여기서 자동으로 최신 상태로 반영됩니다.
- 여기서 만든 변경은 지정된 브랜치(`claude/...`)로 푸시되고, **Pull Request**로 정리됩니다.
- 웹에서 한 작업을 맥에서 받으려면, PR이 `main`에 병합된 뒤 맥에서 `git pull` 하면 됩니다.

> 💡 즉, 맥끼리는 `main` 브랜치로 바로 주고받고, Claude가 한 작업은 PR을 거쳐 합쳐집니다.

---

## 5. 충돌이 났을 때

두 기기에서 **같은 파일**을 동시에 고치면 충돌(conflict)이 날 수 있습니다.
이 저장소는 대부분 이미지라 충돌은 드물지만, 났을 때는:

```bash
git pull                 # 충돌 파일이 표시됨
# 충돌 파일을 열어 원하는 내용으로 정리
git add <정리한파일>
git commit
git push
```

가장 좋은 예방책은 **작업 시작 전에 항상 `./scripts/pull.sh`** 를 실행하는 습관입니다.

---

## 6. 대용량 파일 주의 (CDN 저장소 특성)

이 저장소는 이미지/영상이 계속 쌓이는 CDN이라 `.git` 용량이 커지고 있습니다
(현재 약 676MB). 앞으로 영상·대용량 파일이 많아지면 다음을 고려하세요.

- **Git LFS** 도입: 대용량 바이너리를 별도로 관리해 clone 속도 유지
  ```bash
  git lfs install
  git lfs track "*.mp4" "*.mov" "*.zip"
  git add .gitattributes && git commit -m "Track large files with LFS"
  ```
- 오래된/미사용 에셋 정리

---

## CDN 사용 참고

푸시된 에셋은 jsDelivr를 통해 CDN URL로 바로 쓸 수 있습니다.

```
https://cdn.jsdelivr.net/gh/usandkofficial-sys/usk-cdn@main/img/파일명.png
https://cdn.jsdelivr.net/gh/usandkofficial-sys/usk-cdn@main/video/파일명.mp4
```
