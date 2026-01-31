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

**First-time auth**:
```bash
oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope gmail.modify --output_format bare
```

This might fail if the auth opened in e.g the wrong chrome profile, in which case the user will need claude to run this again.

## Handling SERVICE_DISABLED errors

If an API call returns `SERVICE_DISABLED`, the API needs to be enabled in the Google Cloud project. Use AskUserQuestion with the activation URL in the question title:

```
Question: "Please enable the <API> API: <activationUrl from error>"
Options: ["Enabled", "Need help"]
```

## Adding or upgrading scopes

oauth2l caches tokens per scope. To add a new scope or upgrade permissions:

**Add a new API** (e.g., Docs after using Gmail):
```bash
oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope documents.readonly --output_format bare
```
This triggers a new consent flow for the additional scope.

**Upgrade permissions** (e.g., `documents.readonly` → `documents`):
```bash
oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope documents --output_format bare
```
The user will be prompted to grant the broader permission.

**Common scopes:**
- `gmail.readonly`, `gmail.modify`, `gmail.send`
- `drive.readonly`, `drive`, `drive.file`
- `spreadsheets.readonly`, `spreadsheets`
- `documents.readonly`, `documents`

---

API usage for all services should be available via the *official* google docs (don't use e.g posts from medium) or via a docs tool like context7 if you have it.

Below are some examples:

# Gmail

## List emails

```bash
curl -s "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=10" \
  -H "Authorization: Bearer $(oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope gmail.modify --output_format bare --refresh)"
```

## Read email

```bash
MSG_ID="<message_id>"
curl -s "https://gmail.googleapis.com/gmail/v1/users/me/messages/${MSG_ID}?format=metadata" \
  -H "Authorization: Bearer $(oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope gmail.modify --output_format bare --refresh)"
```

- `format=metadata` - Headers only (From, To, Subject, Date)
- `format=full` - Complete email including body

## Send email

```bash
EMAIL=$(printf 'To: recipient@example.com\r\nSubject: Subject here\r\nContent-Type: text/plain; charset="UTF-8"\r\n\r\nEmail body here' | base64 | tr '+/' '-_' | tr -d '=')

curl -s -X POST "https://gmail.googleapis.com/gmail/v1/users/me/messages/send" \
  -H "Authorization: Bearer $(oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope gmail.modify --output_format bare --refresh)" \
  -H "Content-Type: application/json" \
  -d "{\"raw\": \"${EMAIL}\"}"
```

The email must be base64url encoded (standard base64 with `+/` replaced by `-_`, padding removed).

---

# Drive

## List files

```bash
curl -s "https://www.googleapis.com/drive/v3/files?pageSize=10" \
  -H "Authorization: Bearer $(oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope drive.readonly --output_format bare --refresh)"
```

## Download file

```bash
FILE_ID="<file_id>"
curl -s "https://www.googleapis.com/drive/v3/files/${FILE_ID}?alt=media" \
  -H "Authorization: Bearer $(oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope drive.readonly --output_format bare --refresh)" \
  -o output_filename
```

For Google Docs/Sheets/Slides, export to a specific format:
```bash
curl -s "https://www.googleapis.com/drive/v3/files/${FILE_ID}/export?mimeType=application/pdf" \
  -H "Authorization: Bearer $(oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope drive.readonly --output_format bare --refresh)" \
  -o output.pdf
```

## Upload file

```bash
curl -s -X POST "https://www.googleapis.com/upload/drive/v3/files?uploadType=media" \
  -H "Authorization: Bearer $(oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope drive --output_format bare --refresh)" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @local_file.txt
```

---

# Sheets

## Read cells

```bash
SPREADSHEET_ID="<spreadsheet_id>"
RANGE="Sheet1!A1:B10"
curl -s "https://sheets.googleapis.com/v4/spreadsheets/${SPREADSHEET_ID}/values/${RANGE}" \
  -H "Authorization: Bearer $(oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope spreadsheets.readonly --output_format bare --refresh)"
```

## Write cells

```bash
SPREADSHEET_ID="<spreadsheet_id>"
RANGE="Sheet1!A1:B2"
curl -s -X PUT "https://sheets.googleapis.com/v4/spreadsheets/${SPREADSHEET_ID}/values/${RANGE}?valueInputOption=USER_ENTERED" \
  -H "Authorization: Bearer $(oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope spreadsheets --output_format bare --refresh)" \
  -H "Content-Type: application/json" \
  -d '{"values": [["A1", "B1"], ["A2", "B2"]]}'
```

---

# Docs

## Read document

```bash
DOC_ID="<document_id>"
curl -s "https://docs.googleapis.com/v1/documents/${DOC_ID}" \
  -H "Authorization: Bearer $(oauth2l fetch --credentials ~/.claude/google-workspace-credentials.json --scope documents.readonly --output_format bare --refresh)"
```

## Comments

It isn't possible to create a comment in google docs on a specific word (see more in the official docs). It should be possible to read comments, and reply to existing comments.
