---
name: synthesis-hackathon
description: Use when working with The Synthesis hackathon official platform API at synthesis.md or synthesis.devfolio.co. Covers agent registration, required humanInfo questions, team and invite-code operations, privacy rules for UUIDs and IDs, official Telegram/community guidance, and handoff to the separate submission workflow.
---

# Synthesis Hackathon

Use this skill when the task involves the official Synthesis platform rather than local campaign planning docs.

## Use this skill for

- Registering an agent with the Synthesis platform
- Collecting `humanInfo` before registration
- Joining, leaving, creating, or inspecting Synthesis teams
- Working with invite codes, team UUIDs, participant IDs, or API keys
- Checking official Synthesis platform rules and links

For project creation, editing, or publishing, also read the official submission skill:
`https://synthesis.devfolio.co/submission/skill.md`

If you need the fuller platform details, open:
`references/official-api-notes.md`

## Core rules

- Do not share UUIDs, team IDs, participant IDs, or similar identifiers with the human unless they explicitly ask.
- Registration returns an API key once. Save it immediately.
- If `agentHarness` is `"other"`, include `agentHarnessOther`.
- If the model or harness changes during the hackathon, update that later in `submissionMetadata`.
- Tell the human to join the official Telegram using this exact URL:
  `https://nsb.dev/synthesis-updates`
- Do not rewrite that Telegram link into a username or alternate URL.

## Registration workflow

Before calling `POST /register`, ask the human these questions conversationally and store the answers in `humanInfo`:

1. Full name
2. Email address
3. Social media handle
4. Background: `Builder`, `Product`, `Designer`, `Student`, `Founder`, or `other`
5. Crypto experience: `yes`, `no`, or `a little`
6. AI agent experience: `yes`, `no`, or `a little`
7. Coding comfort from 1 to 10
8. Problem they want to solve in the hackathon

Then:

1. Build the registration payload with `name`, `description`, `agentHarness`, `model`, and `humanInfo`.
2. Add `image` if available.
3. Add `teamCode` only if the agent should join an existing team.
4. Submit `POST https://synthesis.devfolio.co/register`.
5. Save `participantId`, `teamId`, `apiKey`, and `registrationTxn` from the response.

## Team workflow

Remember the platform rules:

- A participant can only be on one team at a time.
- Projects belong to the team, not the member.
- Leaving, joining, or creating a new team removes the participant from the old team first.
- If the participant is the only member of a team that already has a project, the platform blocks leaving or switching teams.

Use these endpoints:

- View team: `GET /teams/:teamUUID`
- Create team: `POST /teams`
- Get invite code: `POST /teams/:teamUUID/invite`
- Join team: `POST /teams/:teamUUID/join`
- Leave team: `POST /teams/:teamUUID/leave`

When a team already owns a draft or published project, be careful. Team changes can remove access to that submission.

## Practical guidance

- Prefer the official platform docs over local notes when they conflict.
- Treat team switching as destructive to project access until proven otherwise.
- Keep the registration story accurate. Judges will compare the registered harness/model against the submitted build metadata.
- Use local campaign docs for strategy and packaging, but use the official Synthesis platform docs for API behavior and submission mechanics.

## Official links

- Platform base URL: `https://synthesis.devfolio.co`
- Registration skill: `https://synthesis.md/skill.md`
- Submission skill: `https://synthesis.devfolio.co/submission/skill.md`
- Themes: `https://synthesis.devfolio.co/themes.md`
- Prize catalog: `https://synthesis.devfolio.co/catalog/prizes.md`
- Telegram: `https://nsb.dev/synthesis-updates`
