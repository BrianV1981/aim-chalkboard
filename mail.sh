#!/bin/bash
# Standalone Swarm Post Office Wrapper
# Operates purely via local GitOps within this repository.

set -e

if [ -z "$1" ]; then
  echo "Usage:"
  echo "  ./mail.sh send <target_team> \"<subject>\" \"<body>\""
  echo "  ./mail.sh check <your_team>"
  exit 1
fi

ACTION=$1

# Make sure we are at the root of the chalkboard repository
cd "$(dirname "$0")"

# Pull latest changes to avoid conflicts before writing/reading
echo "[*] Synchronizing Swarm Hub (git pull --rebase)..."
git pull --rebase origin main || { echo "[ERROR] Failed to synchronize hub. Check git status."; exit 1; }

if [ "$ACTION" == "send" ]; then
  TARGET_TEAM=$2
  SUBJECT=$3
  BODY=$4

  if [ -z "$TARGET_TEAM" ] || [ -z "$SUBJECT" ] || [ -z "$BODY" ]; then
    echo "Usage: ./mail.sh send <target_team> \"<subject>\" \"<body>\""
    exit 1
  fi

  # Convert target team to lowercase
  INBOX_DIR="inbox/${TARGET_TEAM,,}"
  mkdir -p "$INBOX_DIR"

  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  # Strip special chars from subject for filename
  SAFE_SUBJECT=$(echo "$SUBJECT" | tr -dc '[:alnum:]' | cut -c 1-30)
  FILENAME="${TIMESTAMP}_${SAFE_SUBJECT}.md"
  FILEPATH="${INBOX_DIR}/${FILENAME}"

  echo "**Date:** $(date +"%Y-%m-%d %H:%M:%S")" > "$FILEPATH"
  echo "**Subject:** $SUBJECT" >> "$FILEPATH"
  echo "" >> "$FILEPATH"
  echo "---" >> "$FILEPATH"
  echo "" >> "$FILEPATH"
  echo "$BODY" >> "$FILEPATH"
  echo "" >> "$FILEPATH"
  echo "---" >> "$FILEPATH"
  echo "> **MANDATE: READ RECEIPT REQUIRED**" >> "$FILEPATH"
  echo "> To complete your execution loop, you MUST dispatch a confirmation receipt back to the sender." >> "$FILEPATH"

  echo "[*] Depositing mail to: /${INBOX_DIR}/"
  
  git add "$FILEPATH"
  git commit -m "Mail: -> ${TARGET_TEAM^^}"
  
  # Try to push, with simple rebase retry if rejected due to concurrency
  echo "[*] Pushing to Swarm Hub..."
  for i in 1 2 3; do
    if git push origin main; then
      echo "[SUCCESS] Mail successfully dispatched."
      exit 0
    else
      echo "[!] Push rejected (concurrency collision). Retrying ($i/3)..."
      sleep 2
      git pull --rebase origin main
    fi
  done
  echo "[ERROR] Failed to push after 3 retries."
  exit 1

elif [ "$ACTION" == "check" ]; then
  YOUR_TEAM=$2

  if [ -z "$YOUR_TEAM" ]; then
    echo "Usage: ./mail.sh check <your_team>"
    exit 1
  fi

  INBOX_DIR="inbox/${YOUR_TEAM,,}"
  ARCHIVE_DIR="${INBOX_DIR}/archive"
  mkdir -p "$ARCHIVE_DIR"

  # Find all .md files in the inbox (ignoring directories like archive)
  MAIL_FILES=()
  if [ -d "$INBOX_DIR" ]; then
    for f in "$INBOX_DIR"/*.md; do
      [ -e "$f" ] || continue
      MAIL_FILES+=("$f")
    done
  fi

  if [ ${#MAIL_FILES[@]} -eq 0 ]; then
    echo "[SUCCESS] Inbox is empty. Nothing new to read."
    exit 0
  fi

  echo "[*] Found ${#MAIL_FILES[@]} new piece(s) of mail."
  echo ""
  echo "## 📨 NEW MAIL FETCHED: $(date +"%Y-%m-%d %H:%M")"
  echo ""

  for mf in "${MAIL_FILES[@]}"; do
    cat "$mf"
    echo ""
    echo "---"
    echo ""
    mv "$mf" "$ARCHIVE_DIR/$(basename "$mf")"
  done

  echo "[*] Archiving fetched mail on remote..."
  git add "$ARCHIVE_DIR"
  git add "$INBOX_DIR"
  git commit -m "Mail: ${YOUR_TEAM^^} fetched ${#MAIL_FILES[@]} message(s)"

  for i in 1 2 3; do
    if git push origin main; then
      # No extra echo here since output might be piped to UNREAD_MAIL.md
      exit 0
    else
      echo "[!] Push rejected (concurrency collision). Retrying ($i/3)..." >&2
      sleep 2
      git pull --rebase origin main
    fi
  done
  echo "[ERROR] Failed to archive mail on remote after 3 retries." >&2
  exit 1

else
  echo "Unknown action: $ACTION"
  exit 1
fi
