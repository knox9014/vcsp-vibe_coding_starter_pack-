#!/usr/bin/env bash
# 안전장치 훅 (Claude Code가 Bash 명령을 실행하기 직전에 호출됨)
#
# 명령을 3단계로 나눠요.
#   🛑 차단  : 되돌릴 수 없거나 비밀 키가 새는 명령 → 실행 안 함 (exit 2)
#   ⚠️ 확인  : 되돌리기 어렵지만 가끔 필요한 명령 → 사용자에게 이유를 보여주고 "허용할까요?" 물어봄
#   ✅ 통과  : 나머지 → 평소 권한 설정대로
#
# 입문자는 터미널을 직접 다루기 어려우니, 웬만한 건 "차단" 대신 "확인"으로 둬서
# 사용자가 버튼 한 번으로 결정할 수 있게 했어요.

payload="$(cat)"

# 훅 입력(JSON)에서 tool_input.command 값만 꺼냅니다. jq → node → python 순서로 시도.
extract_command() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" | jq -r '.tool_input.command // ""'
  elif command -v node >/dev/null 2>&1; then
    printf '%s' "$payload" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{console.log((JSON.parse(s).tool_input||{}).command||"")}catch(e){console.log(s)}})'
  elif command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
    "$(command -v python3 || command -v python)" -c 'import sys,json
try: print(json.loads(sys.stdin.read()).get("tool_input",{}).get("command",""))
except Exception: pass' <<<"$payload"
  else
    printf '%s' "$payload"
  fi
}

cmd="$(extract_command)"

block() {
  echo "🛑 안전장치가 이 명령을 막았어요: $1" >&2
  echo "사용자에게 무엇을 하려던 건지 쉽게 설명하고, 더 안전한 방법을 제안하세요." >&2
  exit 2
}

ask() {
  # Claude Code가 사용자에게 확인 창을 띄우고, 이 이유를 함께 보여줘요.
  local reason="⚠️ $1"
  reason="${reason//\\/\\\\}"; reason="${reason//\"/\\\"}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
}

# ── 폴더 삭제(rm -r)는 "무엇을" 지우는지 보고 판단 ─────────────────────────
check_rm() {
  local words recursive=0 w target danger="" spaced
  # "ls&&rm -rf ." 처럼 띄어쓰기 없이 붙여 쓴 명령도 나눠서 보도록, 구분 기호 앞뒤에 공백을 넣어요.
  spaced="$(printf '%s' "$cmd" | sed -E 's/(&&|\|\||;|\||&|\(|\))/ \1 /g')"
  read -ra words <<<"$spaced"
  local in_rm=0
  for w in "${words[@]}"; do
    case "$w" in
      rm) in_rm=1; continue ;;
      ";"|"&&"|"||"|"|"|"&"|"("|")") in_rm=0; continue ;;
    esac
    [ "$in_rm" = 1 ] || continue
    if [[ "$w" == -* ]]; then
      [[ "$w" == *[rR]* ]] && recursive=1
      continue
    fi
    target="${w%/}"
    target="${target#\"}"; target="${target%\"}"; target="${target#\'}"; target="${target%\'}"
    # 프로젝트 안의 절대경로는 상대경로처럼 취급
    if [ -n "$CLAUDE_PROJECT_DIR" ] && [[ "$target" == "$CLAUDE_PROJECT_DIR"/* ]]; then
      target="${target#"$CLAUDE_PROJECT_DIR"/}"
    fi
    # "./my-project" 처럼 앞에 ./ 를 붙여도 같은 대상으로 봐요
    while [[ "$target" == ./* && "$target" != "./" ]]; do target="${target#./}"; done
    case "$target" in
      ""|/|"~"|"~/"*|'$HOME'*|.|..|"*"|"./*"|"/*"|.git|*/.git|my-project|"my-project/*"|"my-project/.") danger="$w" ;;
      /*|*..*) danger="$w" ;;
    esac
    [ -n "$danger" ] && break
  done
  if [ "$recursive" = 1 ]; then
    [ -n "$danger" ] && block "'$danger' 를 통째로 지우면 프로젝트나 컴퓨터의 파일이 사라져요"
    ask "폴더를 통째로 삭제하려고 해요. /save로 저장돼 있던 파일만 /undo로 되돌릴 수 있어요 (node_modules·dist·build처럼 다시 만들 수 있는 폴더는 지워도 괜찮아요). 무엇을 지우는지 확인하고 허용해 주세요."
  fi
}

if printf '%s' "$cmd" | grep -Eq '(^|[;&|( ])rm( |$)'; then
  check_rm
fi

# ── 폴더 전체에서 글자 찾기(grep -r)는 .env 속 비밀 키를 화면에 출력할 수 있어요 ──
if printf '%s' "$cmd" | grep -Eq '(^|[;&|( ])grep +(-[a-zA-Z]*[rR]|--recursive)' \
   && ! printf '%s' "$cmd" | grep -Eq -- "--exclude=['\"]?\.env"; then
  ask "폴더 전체를 검색하면 .env 안의 비밀 키가 대화에 나올 수 있어요. --exclude='.env*' 를 붙였는지 확인해 주세요."
fi

# ── 나머지 규칙: "단계 :: 패턴 :: 이유" ───────────────────────────────────
while IFS= read -r rule; do
  [ -z "$rule" ] && continue
  level="${rule%% :: *}"
  rest="${rule#* :: }"
  pattern="${rest%% :: *}"
  reason="${rest##* :: }"
  if printf '%s' "$cmd" | grep -Eqi -- "$pattern"; then
    if [ "$level" = block ]; then block "$reason"; else ask "$reason"; fi
  fi
done <<'RULES'
block :: (^|[;&|(]) *sudo  :: 관리자 권한 명령은 컴퓨터 전체에 영향을 줘요
block :: git +push .*(--force|-f( |$)|\+[a-z]) :: 강제 푸시는 GitHub에 있는 기록을 지울 수 있어요
block :: (cat|less|more|head|tail|type|bat|grep|awk|strings)( [^|;&]*)? [^ ]*\.env(\.local)?( |$) :: 비밀 키 파일(.env) 내용이 대화에 노출돼요
block :: (^|[;&|(]) *printenv( |$) :: 비밀 키가 들어 있는 환경변수가 대화에 노출돼요
block :: (^|[;&|(]) *env *($|[;&|)]) :: 비밀 키가 들어 있는 환경변수가 대화에 노출돼요
block :: (curl|wget)[^|]*\| *(ba|z)?sh :: 인터넷에서 받은 스크립트를 확인 없이 실행하면 위험해요
block :: chmod +-R +777 :: 모든 파일의 권한을 열어버려요
ask :: git +reset +--hard :: 저장 안 한 변경, 그리고 지정한 지점 이후의 저장 기록까지 사라질 수 있어요. 보통은 /undo 를 쓰는 게 더 안전해요
ask :: git +clean +-[a-z]*f :: Git에 저장된 적 없는 새 파일들이 삭제돼요
ask :: git +(checkout +(--)? *|restore +)\.( |$) :: 저장 안 한 변경이 모두 사라져요. 보통은 /undo 를 쓰는 게 더 안전해요
ask :: find .*(-delete|-exec +rm) :: 찾은 파일들을 한꺼번에 삭제해요. 무엇이 지워지는지 확인해 주세요
ask :: (drop|truncate) +table :: 데이터베이스의 표(데이터)가 통째로 삭제돼요
RULES

exit 0
