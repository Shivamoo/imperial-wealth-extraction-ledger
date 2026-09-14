#!/usr/bin/env bash
# One-shot deployment: create the public GitHub repo, push the feature branch,
# and open a Pull Request for review.
#
# Prerequisites (one-time):
#   1. Install GitHub CLI:  https://cli.github.com/
#   2. Authenticate:        gh auth login
#
# Then run:  bash deploy.sh

set -euo pipefail

REPO="imperial-wealth-extraction-ledger"
BASE="main"
FEATURE="feature/imperial-defense-modules"

# --- 1. gh CLI present & authenticated? --------------------------------
if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: GitHub CLI (gh) is not installed."
  echo "Install it from https://cli.github.com/ then run:  gh auth login"
  exit 1
fi
gh auth status || { echo "ERROR: not authenticated — run: gh auth login"; exit 1; }

USER="$(gh api user -q .login)"

# --- 2. Create the public repository (idempotent) ----------------------
if gh repo view "$USER/$REPO" >/dev/null 2>&1; then
  echo "Repo already exists: $USER/$REPO"
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$USER/$REPO.git"
else
  echo "Creating public repo: $USER/$REPO"
  gh repo create "$REPO" --public --source=. --remote=origin
fi

# --- 3. Push main + feature branch -------------------------------------
git push -u origin "$BASE" "$FEATURE"

# --- 4. Open the Pull Request ------------------------------------------
gh pr create \
  --base "$BASE" \
  --head "$FEATURE" \
  --title "Imperial Wealth Extraction Ledger: EIC artifact tracker + imperial defense modules" \
  --body "$(cat <<'EOF'
## Summary
Single-file dashboard (index.html) covering:
- Three East India Company corporate-legal case studies (Royal Charter/Regulating Act, Diwani wealth extraction, artifact plunder)
- Wealth Drain & Artifact Ledger — with the $45T Utsa Patnaik drain figure and the British Museum Act 1963 sub-card
- The Imperial Defense: three justification modules (Civilizing Mission, Legal Pluralism, Manufactured Sovereignty)
- Two-faces-of-legality comparison (Formal Domestic Legality vs. Substantive Rule of Law / Ethics)

## Notes
- Fully self-contained (inline CSS + JS) — opens from file:// with no build step.
EOF
)"

echo ""
echo "Done. PR opened for $FEATURE -> $BASE."
