#!/bin/bash
# Hook: block destructive commands before shell execution.
# Cursor passes JSON on stdin with a "command" field.

input=$(cat)
command=$(echo "$input" | jq -r '.command')

# --- DENY: recursive deletes ---
if [[ "$command" =~ rm[[:space:]]+-(r|rf|fr)[[:space:]] ]] || [[ "$command" =~ rm[[:space:]]+--recursive ]]; then
  echo '{"permission":"deny","user_message":"Blocked: recursive delete.","agent_message":"Recursive delete blocked by hook. Do not retry."}'
  exit 0
fi

# --- DENY: database destructive ops (SQL) ---
if echo "$command" | grep -qiE '\b(drop\s+(table|database|index|collection)|truncate\s+(table|collection)|delete\s+from)\b'; then
  echo '{"permission":"deny","user_message":"Blocked: destructive database operation.","agent_message":"Database mutation blocked. Use migrations instead."}'
  exit 0
fi

# --- DENY: DynamoDB destructive ops ---
if echo "$command" | grep -qiE '(aws\s+dynamodb\s+delete-table|deleteTable|deleteItem|BatchWriteItem)'; then
  echo '{"permission":"deny","user_message":"Blocked: DynamoDB destructive operation.","agent_message":"DynamoDB destructive operation blocked by hook."}'
  exit 0
fi

# --- DENY: AWS destructive ops ---
if echo "$command" | grep -qiE '(aws\s+s3\s+rb\b|aws\s+s3\s+rm\b)'; then
  echo '{"permission":"deny","user_message":"Blocked: AWS S3 destructive operation.","agent_message":"S3 bucket/object delete blocked by hook."}'
  exit 0
fi

# --- DENY: kubectl delete / terraform destroy ---
if echo "$command" | grep -qiE '\b(kubectl\s+delete|terraform\s+destroy)\b'; then
  echo '{"permission":"deny","user_message":"Blocked: infrastructure destructive operation.","agent_message":"Infrastructure destruction blocked. Requires manual execution."}'
  exit 0
fi

# --- DENY: destructive git ---
if echo "$command" | grep -qiE '(git\s+push\s+.*--force|git\s+reset\s+--hard|git\s+clean\s+-f)'; then
  echo '{"permission":"deny","user_message":"Blocked: destructive git operation.","agent_message":"Force push / hard reset / clean blocked. Use safe alternatives."}'
  exit 0
fi

# --- DENY: piped remote code execution ---
if echo "$command" | grep -qiE '(curl|wget)\s.*\|\s*(sh|bash)'; then
  echo '{"permission":"deny","user_message":"Blocked: piped remote execution.","agent_message":"Piping remote content to shell blocked by policy."}'
  exit 0
fi

# --- ALLOW: everything else ---
echo '{"permission":"allow"}'
