#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  cd "$OWNER/foo"
  git subrepo clone --method rebase "$UPSTREAM/bar"
) &> /dev/null || die

{
  message=$(
    cd "$OWNER/foo"
    add-new-files bar/Bar1
    catch git subrepo push bar
  )

  # The first commit of the subrepo branch gets the upstream HEAD as its
  # parent. Passing that parent as one word ("-p <sha>") made git commit-tree
  # fail with "not a valid object name" before push fell back.
  is "$message" \
    "Subrepo 'bar' pushed to '$UPSTREAM/bar' (master)." \
    "Push with the rebase join method prints no git errors"
}

{
  (
    cd "$OWNER/bar"
    git pull --quiet
  ) &> /dev/null || die

  is "$(
    cd "$OWNER/bar"
    git ls-tree --name-only HEAD Bar1
  )" "Bar1" "Pushed file is upstream"
}

done_testing 2

teardown
