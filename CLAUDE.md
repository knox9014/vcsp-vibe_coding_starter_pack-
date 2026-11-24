@AGENTS.md

# Claude Code 전용 메모

위 `AGENTS.md`가 핵심 지침입니다. 여기에는 Claude Code에만 해당하는 내용만 둡니다.

- 슬래시 명령어는 `.claude/skills/`에 있습니다. 사용자가 명령어 없이 비슷한 말을 해도 맞는 스킬을 사용하세요.
- 권한 설정은 `.claude/settings.json`, 위험 명령 차단 훅은 `.claude/hooks/block-dangerous.sh`에 있습니다. 훅이 🛑차단하면 우회하지 말고 다른 방법을 찾거나 사용자에게 이유를 설명하세요. ⚠️확인 창이 뜨는 명령은 실행 전에 무엇을 왜 지우거나 버리는지 한 줄로 먼저 말하세요.
- 사용자가 "허락 그만 물어봐" 류의 요청을 하면, 해당 명령만 `.claude/settings.local.json`의 `allow`에 추가하는 방법을 제안하세요 (`deny` 목록은 건드리지 마세요).
- 대화가 길어져 맥락이 흐려지면 `/wrap`으로 `my-project/PROJECT.md`를 정리한 뒤, 사용자에게 `/clear` 후 `/next`로 이어가라고 안내하세요.
