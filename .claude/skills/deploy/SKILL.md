---
name: deploy
description: 만든 것을 인터넷에 올려 링크로 공유할 수 있게 돕는다(Netlify Drop, GitHub Pages, Vercel 중 가장 쉬운 것 추천). 사용자가 "/deploy", "배포", "인터넷에 올려줘", "친구한테 보여주고 싶어", "링크 만들어줘"라고 할 때 사용.
---

# /deploy — 인터넷에 올리기

배포는 외부에 공개하는 일이라 **각 단계마다 사용자 동의**를 받으세요. 가입·결제·push는 사용자가 직접 하거나 명시적으로 허락해야 합니다.

## 1. 먼저 점검

- `/review` 절차의 🔴 항목(특히 비밀 키 노출)이 없는지 확인하세요. 있으면 배포 전에 고치자고 하세요.
- `/save`로 저장돼 있는지 확인하세요.
- 웹페이지가 아니면(Python 스크립트 등) 배포 대상이 아니라고 설명하고, 대신 다른 사람과 나누는 방법(파일 공유)을 안내하세요.

## 2. 꼭 미리 알려줄 것 (기대와 다를 수 있는 부분)

- **데이터가 공유되지 않아요**: 데이터를 `localStorage`(브라우저 저장)에 두는 프로젝트라면, 링크를 연 사람마다 **자기 브라우저에만** 저장돼요. 내가 올린 글·기록을 친구가 볼 수 없어요. 사용자의 목적이 "같이 보기"라면 이걸 먼저 말하고, 필요하면 Supabase 같은 서버 저장소를 다음 단계로 제안하세요.
- **폴더 안의 파일이 공개돼요**: `my-project/PROJECT.md`(개인 메모)는 Netlify·Vercel로 올리면 `주소/PROJECT.md`로 누구나 볼 수 있어요. 공개되면 곤란한 내용이 있는지 물어보세요. (GitHub Pages 설정은 `PROJECT.md`, `.env`, `data/`를 자동으로 빼고 올려요)

## 3. 방법 고르기 (추천을 하나 제시)

`git remote -v`로 GitHub에 연결돼 있는지 먼저 확인하세요.

| 상황 | 추천 | 이유 |
|---|---|---|
| HTML 파일만 있음, GitHub 연결 없음 (가장 쉬움) | ⭐ **Netlify Drop** (app.netlify.com/drop) | 폴더를 끌어다 놓으면 끝. 가입 없이도 됨 |
| HTML/CSS/JS, GitHub에 이미 연결됨 (`git remote -v`에 주소가 나옴) | **GitHub Pages** | 무료, 저장(push)하면 자동 반영 |
| `package.json`이 있는 프로젝트 (Vite, React 등) | **Vercel** | 빌드까지 자동 |
| 서버·데이터베이스가 필요함 | 상황 설명 후 함께 결정 | 비밀 키 설정 등 추가 작업 필요 |

## 4. 단계별 안내

선택한 방법의 단계를 번호로 안내하세요. 사용자가 클릭해야 하는 버튼 이름을 정확히 적으세요.

**Netlify Drop**
1. 브라우저에서 app.netlify.com/drop 열기
2. 파일 탐색기(Mac은 Finder)에서 `my-project` 폴더를 찾아 브라우저 창으로 끌어다 놓기
3. 나온 주소 확인. 가입하지 않으면 일정 시간 후 사라질 수 있으니, 계속 쓰려면 무료 가입 권하기

**GitHub Pages**
1. GitHub 연결이 없다면 먼저 연결해야 해요. 입문자에게 터미널 로그인은 어려우니 이 순서를 권하세요:
   - github.com 가입 → **GitHub Desktop** 앱 설치·로그인 → File → Add local repository → 이 폴더 선택 → **Publish repository** (Private 체크 해제해야 무료 Pages 가능)
   - 이게 어렵다면 Netlify Drop으로 바꾸자고 제안하세요.
2. (동의를 받고) `templates/github-pages.yml`을 `.github/workflows/deploy-pages.yml`로 복사하고 `/save`
3. 사용자가 GitHub 레포 → **Settings** → **Pages** → Source를 **GitHub Actions**로 선택
4. (동의를 받고) 올리기: GitHub Desktop의 **Push origin** 버튼, 또는 AI가 `git push` (현재 브랜치 이름은 `git branch --show-current`로 확인)
5. 레포의 **Actions** 탭에서 초록 체크 ✅ 확인 → 1~2분 뒤 `https://아이디.github.io/레포이름/`
   - 실행이 안 보이면: Actions → "Deploy my-project to GitHub Pages" → **Run workflow** 버튼

**Vercel**
- vercel.com에 GitHub로 가입 → Add New → Project → 레포 선택 → **Root Directory**를 `my-project`로 바꾸기 → Deploy

환경변수(비밀 키)가 필요하면 `.env`를 올리지 말고 배포 서비스의 "Environment Variables" 설정 화면에 넣도록 안내하세요.

## 5. 끝나면

- 주소를 알려주고, 휴대폰으로도 열어보라고 하세요.
- `my-project/PROJECT.md`의 "현재 상태"에 배포 주소와 방법을 적으세요.
