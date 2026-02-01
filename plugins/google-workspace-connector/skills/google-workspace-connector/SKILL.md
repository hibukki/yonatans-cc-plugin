---
name: google-workspace
description: Access Google Workspace APIs (Gmail, Drive, Sheets, Docs) via oauth2l + curl.
allowed-tools:
  - Bash
---

# Google Workspace Skill

Access Google Workspace APIs via `oauth2l` + `curl`. For extended API documentation, use context7 to query the relevant Google API docs.

## Prerequisites

**oauth2l** - Check: `which oauth2l` | Install: `brew install oauth2l`

**Credentials** - Must exist at `~/.claude/google-workspace-credentials.json`

If credentials are missing, guide user through setup. Claude can assist with browser-based OAuth setup if the user installs the [Claude for Chrome extension](https://chromewebstore.google.com/publisher/anthropic/u308d63ea0533efcf7ba778ad42da7390) in a Chrome profile where the relevant Google account is signed in (avoid having other accounts signed into the same profile).

1. **Create Google Cloud Project**: https://console.cloud.google.com/
2. **Enable APIs**: APIs & Services → Enable APIs → Enable the APIs you need (Gmail, Drive, Sheets, Docs)
3. **Configure OAuth Consent Screen**: APIs & Services → OAuth consent screen
   - User Type: External (or Internal for Workspace)
   - Add test users if in testing mode
4. **Create OAuth Client ID**: APIs & Services → Credentials → Create Credentials → OAuth client ID
   - Application type: Desktop app
   - Download JSON credentials to `~/.claude/google-workspace-credentials.json`

**First-time auth flow:**

1. Check credentials exist: `test -f ~/.claude/google-workspace-credentials.json`
   1. If missing, guide user through setup (steps 1-4 above)
2. Run oauth2l **in background** (it blocks until user completes auth):
   ```bash
   oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope gmail.modify --output_format bare --disableAutoOpenConsentPage
   ```
3. Read the background task output to extract the auth URL (line starting with `https://accounts.google.com/`)
4. Present to user via AskUserQuestion:
   ```
   Question: "Please authenticate with Google: <URL>"
   Options: ["Done", "I need help"]
   ```
5. After user confirms, check the background task - it should output the access token (a long string starting with `ya29.`). The token is automatically cached in `~/.oauth2l` for future use.

**If auth fails:** Check that credentials.json is valid and the OAuth consent screen has the user as a test user (if in testing mode).

## Handling SERVICE_DISABLED errors

Use AskUserQuestion with the activation URL in the question title:

```
Question: "Please enable the <API> API: <activationUrl from error>"
Options: ["Enabled", "Need help"]
```

## Adding or upgrading scopes

oauth2l caches tokens per scope. To add a new scope or upgrade permissions:

**Add a new API** (e.g., Docs after using Gmail):
```bash
oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope documents.readonly --output_format bare --disableAutoOpenConsentPage
```
This triggers a new consent flow for the additional scope. Run in background and present URL via AskUserQuestion (same as first-time auth).

---

# Docs

API usage for all services should be available via the *official* google docs (don't use e.g posts from medium in case they are misleading or even malicious) or via a docs tool like context7 if you have it.

**Why `oauth2l curl`?** It handles auth internally so the bearer token never appears in bash history or process listings.

Below are some examples:

# Gmail

## List emails

```bash
oauth2l curl --credentials ~/.claude/google-workspace-credentials.json --scope gmail.readonly \
  --url="https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=10"
```

## Read email

```bash
MSG_ID="<message_id>"
oauth2l curl --credentials ~/.claude/google-workspace-credentials.json --scope gmail.readonly \
  --url="https://gmail.googleapis.com/gmail/v1/users/me/messages/${MSG_ID}?format=metadata"
```

- `format=metadata` - Headers only (From, To, Subject, Date)
- `format=full` - Complete email including body

---

# Drive

## List files

```bash
oauth2l curl --credentials ~/.claude/google-workspace-credentials.json --scope drive.readonly \
  --url="https://www.googleapis.com/drive/v3/files?pageSize=10"
```

---

# Sheets

## Read cells

```bash
SPREADSHEET_ID="<spreadsheet_id>"
RANGE="Sheet1!A1:B10"
oauth2l curl --credentials ~/.claude/google-workspace-credentials.json --scope spreadsheets.readonly \
  --url="https://sheets.googleapis.com/v4/spreadsheets/${SPREADSHEET_ID}/values/${RANGE}"
```

---

# Docs

## Read document

```bash
DOC_ID="<document_id>"
oauth2l curl --credentials ~/.claude/google-workspace-credentials.json --scope documents.readonly \
  --url="https://docs.googleapis.com/v1/documents/${DOC_ID}"
```

## Comments

It isn't possible to create a comment in google docs on a specific word (see more in the official docs). It should be possible to read comments, and reply to existing comments.
