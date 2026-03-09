root := justfile_directory() / ".."
creds := env('MOLTBOOK_CREDENTIALS', home_directory() / ".config/moltbook/credentials.json")
api := "https://www.moltbook.com/api/v1"

[private]
@default:
    just --list --justfile {{source_file()}}

# Show agent profile (karma, unread notifications)
profile:
    #!/usr/bin/env bash
    set -euo pipefail
    KEY=$(jq -r '.api_key' "{{creds}}")
    curl -s "{{api}}/home" -H "Authorization: Bearer $KEY" | jq '.your_account'

# List recent posts by this agent
posts:
    #!/usr/bin/env bash
    set -euo pipefail
    KEY=$(jq -r '.api_key' "{{creds}}")
    AGENT=$(jq -r '.agent_name' "{{creds}}")
    curl -s "{{api}}/posts?author=$AGENT" -H "Authorization: Bearer $KEY" | jq '[.posts[] | {
      id: .id[:8],
      submolt: .submolt.name,
      title: (.title[:60]),
      spam: .is_spam,
      verified: .verification_status,
      score: .score,
      comments: .comment_count,
      created: .created_at[:16]
    }]'

# Check all comments across all posts
comments:
    #!/usr/bin/env bash
    set -euo pipefail
    KEY=$(jq -r '.api_key' "{{creds}}")
    AGENT=$(jq -r '.agent_name' "{{creds}}")
    POSTS=$(curl -s "{{api}}/posts?author=$AGENT" -H "Authorization: Bearer $KEY" | jq -r '.posts[].id')
    for post_id in $POSTS; do
        COMMENTS=$(curl -s "{{api}}/posts/$post_id/comments" -H "Authorization: Bearer $KEY")
        COUNT=$(echo "$COMMENTS" | jq '.count')
        if [ "$COUNT" -gt 0 ]; then
            TITLE=$(echo "$COMMENTS" | jq -r '.comments[0].post_id' | head -c 8)
            echo "=== Post $post_id ==="
            echo "$COMMENTS" | jq '[.comments[] | {
              author: .author.name,
              karma: .author.karma,
              content: (.content[:120]),
              created: .created_at[:16]
            }]'
            echo ""
        fi
    done

# Check notifications and home feed
home:
    #!/usr/bin/env bash
    set -euo pipefail
    KEY=$(jq -r '.api_key' "{{creds}}")
    curl -s "{{api}}/home" -H "Authorization: Bearer $KEY" | jq '{
      account: .your_account,
      activity: .activity_on_your_posts,
      dms: .your_direct_messages,
      next: .what_to_do_next
    }'

# Post to a submolt: just moltbook post <submolt> <title> <content-file>
post submolt title file:
    #!/usr/bin/env bash
    set -euo pipefail
    KEY=$(jq -r '.api_key' "{{creds}}")
    CONTENT=$(cat "{{file}}")
    PAYLOAD=$(jq -n --arg title "{{title}}" --arg content "$CONTENT" --arg submolt "{{submolt}}" \
      '{title: $title, content: $content, submolt: $submolt}')
    RESULT=$(curl -s -X POST "{{api}}/posts" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $KEY" \
      -d "$PAYLOAD")
    echo "$RESULT" | jq '{
      success: .success,
      post_id: .post.id,
      submolt: .post.submolt.name,
      verification_code: .post.verification.verification_code,
      challenge: .post.verification.challenge_text
    }'
    echo ""
    echo "Solve the challenge above, then run:"
    echo "  just moltbook verify $(echo "$RESULT" | jq -r '.post.verification.verification_code') <answer>"

# Reply to a post: just moltbook reply <post-id> <content-file>
reply post_id file:
    #!/usr/bin/env bash
    set -euo pipefail
    KEY=$(jq -r '.api_key' "{{creds}}")
    CONTENT=$(cat "{{file}}")
    RESULT=$(curl -s -X POST "{{api}}/posts/{{post_id}}/comments" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $KEY" \
      -d "$(jq -n --arg content "$CONTENT" '{content: $content}')")
    echo "$RESULT" | jq '{
      success: .success,
      comment_id: .comment.id,
      verification_code: .comment.verification.verification_code,
      challenge: .comment.verification.challenge_text
    }'
    echo ""
    echo "Solve the challenge above, then run:"
    echo "  just moltbook verify $(echo "$RESULT" | jq -r '.comment.verification.verification_code') <answer>"

# Verify a post or comment: just moltbook verify <code> <answer>
verify code answer:
    #!/usr/bin/env bash
    set -euo pipefail
    KEY=$(jq -r '.api_key' "{{creds}}")
    curl -s -X POST "{{api}}/verify" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $KEY" \
      -d "$(jq -n --arg code "{{code}}" --arg answer "{{answer}}" \
        '{verification_code: $code, answer: $answer}')" | jq '.'

# List available submolts
submolts:
    #!/usr/bin/env bash
    set -euo pipefail
    KEY=$(jq -r '.api_key' "{{creds}}")
    curl -s "{{api}}/submolts?limit=50" -H "Authorization: Bearer $KEY" | jq '[.submolts[] | {
      name,
      posts: (.post_count // 0),
      crypto: (.crypto_policy // "unknown")
    }] | sort_by(-.posts) | .[:20]'

# View a specific post with its comments
view post_id:
    #!/usr/bin/env bash
    set -euo pipefail
    KEY=$(jq -r '.api_key' "{{creds}}")
    echo "=== Post ==="
    curl -s "{{api}}/posts/{{post_id}}" -H "Authorization: Bearer $KEY" | jq '{
      title: .post.title,
      submolt: .post.submolt.name,
      score: .post.score,
      comments: .post.comment_count,
      spam: .post.is_spam,
      verified: .post.verification_status
    }'
    echo ""
    echo "=== Comments ==="
    curl -s "{{api}}/posts/{{post_id}}/comments" -H "Authorization: Bearer $KEY" | jq '[.comments[] | {
      author: .author.name,
      karma: .author.karma,
      content: (.content[:200]),
      replies: .reply_count
    }]'

# Delete a post
delete post_id:
    #!/usr/bin/env bash
    set -euo pipefail
    KEY=$(jq -r '.api_key' "{{creds}}")
    curl -s -X DELETE "{{api}}/posts/{{post_id}}" \
      -H "Authorization: Bearer $KEY" | jq '.'
