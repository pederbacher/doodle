# Doodle Polls

A lightweight, serverless scheduling poll hosted entirely on GitHub Pages. No backend required — responses are saved as `.txt` files in the repository via the GitHub API.

## How it works

- **One global config** at the repo root holds your GitHub credentials.
- **Each poll lives in its own subfolder** (copied from `template/`).
- Participants visit `YOUR_DOODLE/` to vote and `YOUR_DOODLE/results.html` to see results.
- An optional **access word** per poll controls who can vote and view results.

---

## Initial Setup (one-time)

### 1. Enable GitHub Pages

In your repository: **Settings → Pages → Source: Deploy from branch → `main` → `/ (root)`**

### 2. Configure GitHub credentials

Open `setup.html` (via your Pages URL or locally) and fill in **Section 1**:

| Field | Description |
|-------|-------------|
| GitHub Username | Your GitHub username |
| Repository Name | This repository's name |
| Branch | Usually `main` |
| Personal Access Token | Fine-grained token with **Contents: Read & Write** on this repo |

Create a token at: **GitHub → Settings → Developer settings → Fine-grained personal access tokens**

Click **Save Global Config to GitHub** — this writes the root `config.txt`.

> ⚠️ The token is stored in the public `config.txt`. Use a fine-grained token scoped **only to this repo** to limit exposure.

---

## Creating a New Poll

### Option A — via setup.html (no git needed)

1. Open `setup.html` and make sure Section 1 credentials are filled in.
2. In **Section 2**, fill in:
   - **Folder Name** — URL slug, e.g. `team-meeting` (lowercase, hyphens only)
   - **Poll Title**, Description, Organizer
   - **Access Word** — participants must enter this to vote/view results (leave blank to disable)
   - **Time Slots** — one per line, format `YYYY-MM-DD HH:MM` or `YYYY-MM-DD` for all-day
3. Click **Save Doodle Config to GitHub** — creates `team-meeting/config.txt` and `team-meeting/responses/.gitkeep` in the repo.
4. In the repo, **copy the `template/` folder** and rename it to `team-meeting/`.
5. Commit and push. GitHub Pages serves it within ~1 minute.

### Option B — manually (fastest once you know the workflow)

1. Copy the `template/` folder, rename it to your poll slug (e.g. `birthday-party/`).
2. Edit `birthday-party/config.txt`:

```ini
[poll]
title = Birthday Party – When can you come?
description = Pick your preferred dates below.
organizer = Peder
access_word = sunshine42

[slots]
2026-05-10 18:00
2026-05-11 18:00
2026-05-17 18:00
```

3. Commit and push.

---

## Sharing a Poll

After the folder is pushed and Pages has deployed:

| Page | URL |
|------|-----|
| Vote | `https://USERNAME.github.io/REPO/FOLDER/` |
| Results | `https://USERNAME.github.io/REPO/FOLDER/results.html` |

Share the **Vote** URL with participants. Share the **Results** URL when you want everyone to see the outcome.

---

## Access Word

Each doodle can have an `access_word` in its `config.txt`. When set:

- Visitors must enter the word before they can vote or view results.
- The word is remembered for the browser session (no re-entry needed when navigating between vote and results pages).
- Leave `access_word` blank or remove the line entirely to make the poll publicly accessible.

> Note: The access word is stored in the plaintext `config.txt` which is publicly readable. It provides basic access control (obscurity), not cryptographic security.

---

## File Structure

```
config.txt                  ← Global: GitHub credentials (owner, repo, branch, token)
index.html                  ← Landing/hub page
setup.html                  ← Setup UI for global config and new doodle creation
results.html                ← Stub (results are per-doodle)

template/
  config.txt                ← Template doodle config — edit this for each new poll
  index.html                ← Vote page (copy unchanged)
  results.html              ← Results page (copy unchanged)
  responses/.gitkeep        ← Keeps the responses folder tracked by git

your-poll-name/             ← Created by copying template/
  config.txt                ← Poll-specific config (title, slots, access_word)
  index.html                ← Identical to template/index.html
  results.html              ← Identical to template/results.html
  responses/
    alice-1234567890.txt    ← One file per response, written via GitHub API
    bob-1234567891.txt
```

---

## Doodle config.txt reference

```ini
[poll]
title       = When can we meet?          # Required
description = Context for participants.  # Optional
organizer   = Your Name                  # Optional
access_word = secret123                  # Optional — leave blank to disable gate

[slots]
# One slot per line
# Date + time (24h):  YYYY-MM-DD HH:MM
# All day:            YYYY-MM-DD
2026-04-15 09:00
2026-04-15 14:00
2026-04-17
```

---

## Voting options

Participants choose one of three responses per slot:

| Symbol | Meaning |
|--------|---------|
| ✓ Yes | Available |
| ~ Maybe | Possibly available |
| ✗ No | Not available |

The results page ranks slots by score (`yes × 2 + maybe`) and shows the full response grid.
