## Creating a new poll

### Option B — manually

```bash
cp -r template/ my-poll/
```

Edit `my-poll/config.txt`


```bash
git add my-poll/
git commit -m "Add doodle my-poll"
git push
```

## Sharing a poll

Participants need a link that carries your token. Generate it with one
command (reads `token.txt` and `config.txt`, prints the link and
copies it to your clipboard):

```bash
./share-link.sh FOLDER      # e.g. ./share-link.sh annex94-dk-2026-fall
./share-link.sh             # no argument: pick the poll from a list
```

### (Do once) Create a Personal Access Token

1. GitHub → profile picture → **Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token**
2. Set **Repository access** to this repo only, **Contents: Read & Write**.

### 3. Store the token locally

```bash
echo 'github_pat_YOUR_TOKEN_HERE' > token.txt
```
