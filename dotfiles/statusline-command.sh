#!/usr/bin/env bash
# Homelab status line for Claude Code
# Shows: directory | git branch | model | context % | tokens | cost
#
# No jq dependency — parses JSON with grep/sed.

input=$(cat)

# Parse JSON fields
cwd=$(    echo "$input" | grep -o '"current_dir":"[^"]*"'    | head -1 | sed 's/^"current_dir":"//;s/"$//')
model=$(  echo "$input" | grep -o '"display_name":"[^"]*"'   | head -1 | sed 's/^"display_name":"//;s/"$//')
used=$(   echo "$input" | grep -o '"used_percentage":[0-9]*' | head -1 | sed 's/^"used_percentage"://')
in_tok=$( echo "$input" | grep -o '"total_input_tokens":[0-9]*'  | head -1 | sed 's/^"total_input_tokens"://')
out_tok=$(echo "$input" | grep -o '"total_output_tokens":[0-9]*' | head -1 | sed 's/^"total_output_tokens"://')
cost=$(   echo "$input" | grep -o '"total_cost_usd":[0-9.]*'     | head -1 | sed 's/^"total_cost_usd"://')

# Fallback for cwd
[ -z "$cwd" ] && cwd="$PWD"

# Git branch
git_branch=""
if [ -n "$cwd" ]; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
               || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Format token counts (e.g., 15234 -> 15k)
fmt_tok() {
  local n=$1
  if [ -z "$n" ]; then echo ""; return; fi
  if [ "$n" -ge 1000000 ]; then
    printf "%.1fM" "$(echo "$n / 1000000" | bc -l 2>/dev/null || echo "0")"
  elif [ "$n" -ge 1000 ]; then
    printf "%dk" "$(( n / 1000 ))"
  else
    printf "%d" "$n"
  fi
}

# Build coloured parts
dir_part=$(printf "\033[34m%s\033[0m" "$cwd")

branch_part=""
[ -n "$git_branch" ] && branch_part=$(printf " \033[35m(%s)\033[0m" "$git_branch")

model_part=""
[ -n "$model" ] && model_part=$(printf " \033[36m[%s]\033[0m" "$model")

context_part=""
[ -n "$used" ] && context_part=$(printf " \033[33mctx:%s%%\033[0m" "$used")

token_part=""
ctx_size=$(echo "$input" | grep -o '"context_window_size":[0-9]*' | head -1 | sed 's/^"context_window_size"://')
remaining=$(echo "$input" | grep -o '"remaining_percentage":[0-9]*' | head -1 | sed 's/^"remaining_percentage"://')
if [ -n "$ctx_size" ] && [ -n "$used" ] && [ -n "$remaining" ]; then
  used_tok=$(( ctx_size * used / 100 ))
  left_tok=$(( ctx_size * remaining / 100 ))
  token_part=$(printf " \033[32mused:%s left:%s\033[0m" "$(fmt_tok "$used_tok")" "$(fmt_tok "$left_tok")")
fi

cost_part=""
if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  cost_part=$(printf " \033[31m\$%s\033[0m" "$cost")
fi

printf "%s%s%s%s%s%s" "$dir_part" "$branch_part" "$model_part" "$context_part" "$token_part" "$cost_part"
