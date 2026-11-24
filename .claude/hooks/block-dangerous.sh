#!/usr/bin/env bash
# 위험 명령 차단 훅 (Claude Code가 Bash 명령을 실행하기 직전에 호출됨)
#
# settings.json의 deny 목록은 "정확히 그 모양"의 명령만 막아요.
# 이 훅은 명령 문자열 전체를 훑어서, 다른 모양으로 써도 위험한 패턴이면 한 번 더 막습니다.
#
# 종료 코드 2 = 실행 차단 (stderr 메시지가 AI에게 전달됨)
# 종료 코드 0 = 통과

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
    # 도구가 하나도 없으면 원문 전체를 검사 대상으로 씀 (조금 더 엄격해질 뿐 안전함)
    printf '%s' "$payload"
  fi
}

cmd="$(extract_command)"

deny() {
  echo "🛑 안전장치가 이 명령을 막았어요: $1" >&2
  echo "사용자에게 무엇을 하려던 건지 쉽게 설명하고, 정말 필요하면 사용자가 직접 실행하도록 안내하세요." >&2
  exit 2
}

# 정규식(grep -E)으로 검사. 각 줄: "패턴 :: 이유"
while IFS= read -r rule; do
  [ -z "$rule" ] && continue
  pattern="${rule%% :: *}"
  reason="${rule##* :: }"
  if printf '%s' "$cmd" | grep -Eqi -- "$pattern"; then
    deny "$reason"
  fi
done <<'RULES'
(^|[;&| ])rm +-[a-z]*r :: 폴더·파일을 통째로 삭제
(^|[;&| ])sudo  :: 관리자 권한으로 실행
git +push .*(--force|-f( |$)|\+[a-z]) :: 강제 푸시 (GitHub 기록이 사라질 수 있음)
git +reset +--hard :: 저장 안 한 작업이 모두 사라짐
git +clean +-[a-z]*f :: 추적 안 하는 파일이 모두 삭제됨
git +checkout +(--)? *\.( |$) :: 저장 안 한 변경이 모두 사라짐
(drop|truncate) +table :: 데이터베이스 테이블 삭제
(cat|less|more|head|tail|type) +[^ ]*\.env( |$) :: 비밀 키 파일(.env) 내용이 화면에 노출됨
(^|[;&| ])(printenv|env)( |$) :: 환경변수(비밀 키 포함)가 화면에 노출됨
(curl|wget)[^|]*\| *(ba|z)?sh :: 인터넷에서 받은 스크립트를 확인 없이 실행
chmod +-R +777 :: 모든 파일 권한을 열어버림
RULES

exit 0
