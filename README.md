# Doodle Polls

A lightweight, serverless scheduling poll hosted on GitHub Pages. No backend — responses are saved as `.txt` files via the GitHub API.

## Sharing a poll

Participants need a link that carries your token in the URL fragment:

```
https://YOU.github.io/doodle/FOLDER/#t=TOKEN
```

Generate it with one command (reads `token.txt` and `config.txt`, prints the link and copies it to your clipboard):

```bash
./share-link.sh FOLDER      # e.g. ./share-link.sh annex94-dk-2026-fall
./share-link.sh             # no argument: pick the poll from a list
```

If you're in a Claude Code session, run it as `! ./share-link.sh FOLDER` so the token stays out of the chat.

Browsers never send URL fragments to servers, so the token is not logged anywhere. When a participant opens the link their browser stores it in `localStorage` for that session.

**Always share this link — not the plain URL.** Opening the plain URL in a fresh browser will show "No GitHub token found".

---

Alternatively, open `setup.html` locally → **Section 3**, enter the folder name, click **Generate Share Link**, then copy it.

| Page | URL |
|------|-----|
| Vote | Output of `./share-link.sh FOLDER` (includes `#t=…`) |
| Results | `https://YOU.github.io/doodle/FOLDER/results.html` |

---


## How it works

- Each poll lives in its own subfolder copied from `template/`.
- Participants open a **share link** that carries a token fragment (`#t=…`) so they can submit responses.
- Responses are written directly to the repo via the GitHub API and displayed on the results page.

---

## Initial setup (one-time)

### 1. Fork / clone the repo and enable GitHub Pages

```bash
git clone git@github.com:YOU/doodle.git
cd doodle
```

In the repo on GitHub: **Settings → Pages → Source: Deploy from branch → `main` → `/ (root)`**

### 2. Create a Personal Access Token

1. GitHub → profile picture → **Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token**
2. Set **Repository access** to this repo only, **Contents: Read & Write**.

### 3. Store the token locally

```bash
echo 'github_pat_YOUR_TOKEN_HERE' > token.txt
```

`token.txt` is gitignored — it never gets committed. This is the only place your token lives at rest.

### 4. Configure global settings

Serve the repo locally and open `setup.html`:

```bash
python3 -m http.server 8000
# open http://localhost:8000/setup.html
```

Fill in **Section 1** (username, repo name, branch — the token auto-loads from `token.txt`), then click **Save Global Config to GitHub**. This writes `owner`, `repo`, and `branch` to the root `config.txt`.

---

## Creating a new poll

### Option A — via setup.html

1. Open `setup.html` locally (see above).
2. In **Section 2**, fill in folder name, title, organizer, optional access word, and time slots.
3. Click **Save Doodle Config to GitHub** — creates `FOLDER/config.txt` and `FOLDER/responses/.gitkeep` in the repo.
4. Copy the `template/` folder locally and push:

```bash
cp -r template/ FOLDER/
git add FOLDER/
git commit -m "Add doodle FOLDER"
git push
```

### Option B — manually

```bash
cp -r template/ my-poll/
```

Edit `my-poll/config.txt`:

```ini
[title]
When can we meet?

[description]
Pick your preferred dates.

[organizer]
Peder

[access_word]
sunshine42

[slots]
2026-05-10 18:00
2026-05-11 18:00
2026-05-17
```

```bash
git add my-poll/
git commit -m "Add doodle my-poll"
git push
```

---


## Access word

When `access_word` is set in a poll's `config.txt`, participants must enter it before voting or viewing results. It is stored for the browser session. Leave blank or omit to make the poll public.

> The access word is in a public plaintext file — it provides obscurity, not cryptographic security.

---

## File structure

```
.gitignore                  ← Ignores token.txt
token.txt                   ← Your GitHub token (gitignored, create manually)
config.txt                  ← Global: owner, repo, branch
setup.html                  ← UI for global config, new polls, and share links
share-link.sh               ← Prints/copies a poll's share link

template/
  config.txt                ← Edit this for each new poll
  index.html                ← Vote page
  results.html              ← Results page
  responses/.gitkeep

your-poll-name/             ← Copied from template/
  config.txt
  index.html
  results.html
  responses/
    alice-1234567890.txt    ← One file per submission
```

---

## config.txt reference

Each field starts with a `[name]` header. Every line below it — up to the
next `[name]` — is that field's value, so descriptions can span multiple
lines and contain blank lines. Lines starting with `#` are comments.

```ini
[title]
When can we meet?

[description]
Context for participants.

It can span several lines,
including blank ones.

[organizer]
Your Name

[access_word]
secret123

[image]
banner.png

[slots]
# YYYY-MM-DD HH:MM[; note][; options]   (note + options optional)
2026-04-15 09:00
2026-04-15 14:00; Lunch meeting
2026-04-16 09:00; Bus from DTU; Yes/No
2026-04-17
```

Fields: `title` (required), `description`, `organizer`, `access_word`,
`image` (all optional — leave the value empty to omit), and `slots`.

Each slot line is `date [time][; note][; options]`:

- **note** (optional) — short label shown next to the slot (e.g. "Sailing", "Bus from DTU").
- **options** (optional) — any subset of `Yes / Maybe / No`, separated by `/`. Default is all three. Use `Yes/No` to hide the Maybe button.

---

## Voting options

| | Meaning |
|---|---------|
| ✓ Yes | Available |
| ~ Maybe | Possibly available |
| ✗ No | Not available |

Per slot, you can restrict which of these are offered via the third `;`-separated field in `[slots]` (e.g. `; Yes/No`).

Results are ranked by score (`yes × 2 + maybe`).
