#!/usr/bin/env bash
# Merges the branch a builder run just pushed into main, if it is safe to.
# Run from a fresh checkout of main, never from the folder the builder worked in.
#
# Needs: ISSUE_NUMBER, ISSUE_TITLE, BRANCH, GH_TOKEN, GITHUB_OUTPUT.
# Sets these step outputs only when it pushed to main: published=true, folder=<folder>.
#
# Exits 0 without publishing when the run pushed nothing, or when the safety
# guard stopped it. Any other failure exits non-zero, and the workflow tells the team.
set -euo pipefail

stop_for_teacher() {
  echo "NOT PUBLISHED: $1"
  gh issue comment "$ISSUE_NUMBER" --body "This build was not published to the live site. Mr. Riter needs to look at it before it can go up. $2"
  exit 0
}

# Prints the problem and returns 1 if the listed changes are not safe to publish.
# git quotes a path with unusual characters, and a quoted path fails the folder
# check, so an odd filename stops the publish rather than slipping past it.
check_changes() {
  local raw=$1 outside=0 meta path mode
  while IFS=$'\t' read -r meta path; do
    [ -n "$meta" ] || continue
    mode=$(echo "$meta" | cut -d' ' -f2)
    case "$path" in
      "$FOLDER"/*) ;;
      *) echo "Outside $FOLDER/: $path"; outside=1 ;;
    esac
    case "$mode" in
      120000|160000) echo "Link or submodule: $path"; outside=1 ;;
    esac
  done <<< "$raw"
  return "$outside"
}

raw_diff() {
  git -c core.quotepath=off diff --raw --no-abbrev --no-renames "$@"
}

# a. Find what this run pushed.
if [ -z "${BRANCH:-}" ]; then
  echo "This run did not report a branch. Nothing to publish."
  exit 0
fi
if ! git ls-remote --exit-code --heads origin "refs/heads/$BRANCH" > /dev/null; then
  echo "Branch $BRANCH was not pushed. Nothing to publish."
  exit 0
fi

# Which project is this? The issue title's [Project] prefix decides (table in CLAUDE.md).
case "$ISSUE_TITLE" in
  "[Fundraiser]"*)          FOLDER=fundraiser ;;
  "[Resource Website]"*)    FOLDER=resources ;;
  "[Client Check-in App]"*) FOLDER=client-checkin ;;
  *) stop_for_teacher "title has no known project prefix" "The request's title does not start with one of our three projects." ;;
esac

case "$BRANCH" in
  "claude/issue-$ISSUE_NUMBER-"*) ;;
  *) stop_for_teacher "unexpected branch $BRANCH" "The build landed somewhere unexpected." ;;
esac

git fetch --quiet origin main "+refs/heads/$BRANCH:refs/remotes/origin/$BRANCH"

changes=$(raw_diff "origin/main...origin/$BRANCH")
if [ -z "$changes" ]; then
  echo "Branch $BRANCH changes nothing compared with main. Nothing to publish."
  exit 0
fi

# b. Safety guard. Students' text drives the builder, so a build may only ever
# change its own project's folder.
if ! check_changes "$changes"; then
  stop_for_teacher "branch $BRANCH failed the safety guard" "It changed something outside the $FOLDER folder, which a build is not allowed to do. The work is saved on the branch $BRANCH."
fi

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

# c, d. Merge, add build.json to the merge commit, push. A push can lose a race
# with someone else's push to main, so a second try starts over from the new main.
for attempt in 1 2; do
  git fetch --quiet origin main
  git checkout --quiet --force --detach origin/main

  if ! git merge --quiet --no-ff --no-commit "origin/$BRANCH" > /dev/null; then
    git merge --abort || true
    stop_for_teacher "branch $BRANCH conflicts with main" "It clashes with a newer change on the site. The work is saved on the branch $BRANCH."
  fi

  # Check what would actually land, not only what the branch claimed to change.
  if ! check_changes "$(raw_diff --cached origin/main)"; then
    git merge --abort || true
    stop_for_teacher "merge of $BRANCH failed the safety guard" "It changed something outside the $FOLDER folder, which a build is not allowed to do. The work is saved on the branch $BRANCH."
  fi

  printf '{"build": %d, "builtAt": "%s"}\n' "$ISSUE_NUMBER" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$FOLDER/build.json"
  git add "$FOLDER/build.json"
  git commit --quiet --no-verify -m "Publish build #$ISSUE_NUMBER to /$FOLDER/"

  if git push --quiet origin HEAD:refs/heads/main; then
    echo "published=true" >> "$GITHUB_OUTPUT"
    echo "folder=$FOLDER" >> "$GITHUB_OUTPUT"
    echo "Merged $BRANCH into main."
    exit 0
  fi
  echo "Push to main failed on attempt $attempt."
done

echo "Could not push to main after two tries."
exit 1
