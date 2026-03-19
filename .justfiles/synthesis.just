set dotenv-load

root := justfile_directory() / ".."

[private]
@default:
    just --list --justfile {{source_file()}}

# View current project status
view:
    curl -s "https://synthesis.devfolio.co/projects/${SYNTH_PROJECT_UUID}" \
      -H "Authorization: Bearer ${SYNTH_API_KEY}" | python3 -m json.tool

# Update project video URL
video url:
    curl -s -X POST "https://synthesis.devfolio.co/projects/${SYNTH_PROJECT_UUID}" \
      -H "Authorization: Bearer ${SYNTH_API_KEY}" \
      -H "Content-Type: application/json" \
      -d '{"videoURL": "{{url}}"}' | python3 -m json.tool

# Update project with moltbook post URL
moltbook url:
    curl -s -X POST "https://synthesis.devfolio.co/projects/${SYNTH_PROJECT_UUID}" \
      -H "Authorization: Bearer ${SYNTH_API_KEY}" \
      -H "Content-Type: application/json" \
      -d '{"submissionMetadata": {"moltbookPostURL": "{{url}}"}}' | python3 -m json.tool

# Update project description
description desc:
    curl -s -X POST "https://synthesis.devfolio.co/projects/${SYNTH_PROJECT_UUID}" \
      -H "Authorization: Bearer ${SYNTH_API_KEY}" \
      -H "Content-Type: application/json" \
      -d '{"description": "{{desc}}"}' | python3 -m json.tool

# Update project with deployed dashboard URL
deployed-url url:
    curl -s -X POST "https://synthesis.devfolio.co/projects/${SYNTH_PROJECT_UUID}" \
      -H "Authorization: Bearer ${SYNTH_API_KEY}" \
      -H "Content-Type: application/json" \
      -d '{"deployedURL": "{{url}}"}' | python3 -m json.tool

# Update conversation log from conversationLog.json
update-conversation-log:
    #!/usr/bin/env python3
    import json, subprocess
    with open("{{root}}/conversationLog.json") as f:
        log = json.dumps(json.load(f))
    payload = json.dumps({"conversationLog": log})
    result = subprocess.run([
        "curl", "-s", "-X", "POST",
        f"https://synthesis.devfolio.co/projects/{__import__('os').environ['SYNTH_PROJECT_UUID']}",
        "-H", f"Authorization: Bearer {__import__('os').environ['SYNTH_API_KEY']}",
        "-H", "Content-Type: application/json",
        "-d", payload
    ], capture_output=True, text=True)
    print(result.stdout)

# Update project from full payload file
update-from-payload file="docs/2026_requirements/synthesis/submission-payload.json":
    curl -s -X POST "https://synthesis.devfolio.co/projects/${SYNTH_PROJECT_UUID}" \
      -H "Authorization: Bearer ${SYNTH_API_KEY}" \
      -H "Content-Type: application/json" \
      -d @{{root}}/{{file}} | python3 -m json.tool

# View team info
team:
    curl -s "https://synthesis.devfolio.co/teams/${SYNTH_TEAM_UUID}" \
      -H "Authorization: Bearer ${SYNTH_API_KEY}" | python3 -m json.tool
