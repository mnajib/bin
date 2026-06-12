#!/usr/bin/env bash

# Define the target configuration file
GITCONFIG="$HOME/.gitconfig"

echo "Adding aliases to $GITCONFIG..."

# Check if the [alias] section already exists to avoid duplication
if grep -q "^\[alias\]" "$GITCONFIG" 2>/dev/null; then
    echo "Warning: [alias] section already exists in $GITCONFIG."
    echo "Appending new aliases under the existing section might cause formatting issues."
    echo "It is highly recommended to inspect your file afterward."
fi

# Append the alias block to the file
cat << 'EOF' >> "$GITCONFIG"

[alias]
    # Listing aliases
    aliases          = config --get-regexp ^alias\\.
    aliases-local    = config --local --get-regexp ^alias\\.
    aliases-user     = config --global --get-regexp ^alias\\.

    # Shortcuts
    br               = branch
    st               = status
    ci               = commit
    co               = checkout

    # Inspection & Diagnostics
    type             = cat-file -t
    dump             = cat-file -p
    tracked          = ls-tree --full-tree -r --name-only HEAD
    branchall        = branch -a -vv

    # Rich Visual History (Logs)
    log1             = log --pretty=format:'%C(yellow)%h%Cred%d%Creset - %C(cyan)%an %Creset: %s %Cgreen(%cd)' --graph --date=short --all
    log2             = log --pretty=format:'%C(yellow)%h%Cred%d%Creset - %C(cyan)%an %Creset: %s %Cgreen(%cd)' --graph --date=short --all --simplify-by-decoration
    hist             = log --pretty=format:'%C(yellow)%h%Cred%d%Creset - %C(cyan)%an %Creset: %s %Cgreen(%cd)' --graph --date=short --all
    histp            = log --pretty=format:'%C(yellow)%h%Cred%d%Creset - %C(cyan)%an %Creset: %s %Cgreen(%cd)' --graph --date=short --all -p
    hist2            = log --pretty=format:'%C(yellow)%h%Cred%d%Creset - %C(cyan)%an %Creset: %s %Cgreen(%cd)' --graph --date=short --all --simplify-by-decoration
    hist25           = log --pretty=format:'%C(yellow)%h%Cred%d%Creset - %C(cyan)%an %Creset: %s %Cgreen(%cd)' --graph --date=short --all --simplify-by-decoration --oneline
    hist3            = log --graph --oneline --decorate --all
    hist4            = log --stat --graph --pretty=format:'%h - %an: %s (%cd)' --all
    hist5            = log --graph --pretty=format:'%h - %an: %s (%cd)' --numstat --all
    hist6            = log --graph --pretty=format:'%C(yellow)%h%Creset - %C(cyan)%an%Creset: %s %Cgreen(%cd)' --stat --all
    hist7            = log --graph --pretty=format:'%C(yellow)%h%Creset - %C(cyan)%an%Creset: %s %Cgreen(%cd)' -p --all
    hist24           = log --graph --oneline --simplify-by-decoration --all

    # Shell Complex Filtering
    hist22           = "!sh -c 'git log --graph --pretty=format:\"%C(auto)%h %d %s\" --simplify-by-decoration --all --color=always | grep --color=always -v \"tag:\"'"
    hist23           = "!sh -c 'git log --graph --pretty=format:\"%C(auto)%h %d %s\" --simplify-by-decoration --all --color=always | grep --color=always \"tag:\"'"

    # Merge & Rebase Utilities
    merge-diff       = !git diff HEAD $1
    merge-preview    = !git log HEAD..$1 --oneline --graph --decorate
    rebase-diff      = !git diff $1 HEAD
    rebase-preview   = !git log $1..HEAD --oneline --graph --decorate
EOF

echo "Aliases successfully appended!"
