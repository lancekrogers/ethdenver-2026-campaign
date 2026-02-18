---
fest_type: task
fest_id: 02_review_all_readmes.md
fest_name: review_all_readmes
fest_parent: 01_final_review
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Review All Project READMEs

**Task Number:** 02 | **Sequence:** 01_final_review | **Autonomy:** medium

## Objective

Review all six project READMEs against a completeness checklist. Every README must include: setup instructions, architecture overview, usage examples, bounty alignment, and demo link. Document any gaps for immediate remediation.

## Requirements

- [ ] All six READMEs reviewed against the completeness checklist
- [ ] Gaps documented with specific remediation actions
- [ ] All links in all READMEs verified valid (no 404s)
- [ ] Review results saved to `results/readme_review.md` in this sequence directory

## Implementation

### Step 1: Define the completeness checklist

Every README must have:

| Section | Required Content |
|---------|-----------------|
| Project Overview | What the project does, 3-5 sentences |
| Architecture | Diagram (Mermaid/ASCII) showing key components |
| Setup Instructions | Step-by-step, copy-pasteable commands |
| Usage Examples | At least one example of running/using the project |
| Bounty Alignment | Table mapping features to bounty requirements |
| Demo Link | Link to demo video (if applicable to this project) |
| Links | All internal and external links valid |

### Step 2: Review each README

For each of the six projects, read the README and check every item on the checklist:

**Project 1: agent-coordinator**

```bash
cat /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator/README.md
```

- [ ] Project Overview present and clear
- [ ] Architecture diagram present and renders correctly
- [ ] Setup instructions present and complete
- [ ] Usage examples present
- [ ] Bounty alignment (Hedera Track 3) present
- [ ] Demo link present
- [ ] All links valid

**Project 2: agent-inference**

```bash
cat /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference/README.md
```

- [ ] Project Overview present and clear
- [ ] Architecture diagram present and renders correctly
- [ ] Setup instructions present and complete
- [ ] Usage examples present
- [ ] Bounty alignment (0G Track 2, Track 3) present
- [ ] Demo link present
- [ ] All links valid

**Project 3: agent-defi**

```bash
cat /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi/README.md
```

- [ ] Project Overview present and clear
- [ ] Architecture diagram present
- [ ] Setup instructions present and complete
- [ ] Usage examples present
- [ ] Bounty alignment (Base) present
- [ ] Demo link present
- [ ] All links valid

**Project 4: hiero-plugin**

```bash
cat /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/hiero-plugin/README.md
```

- [ ] Project Overview present and clear
- [ ] Architecture/design present
- [ ] Setup/installation instructions present and complete
- [ ] Usage examples (command documentation) present
- [ ] Bounty alignment (Hedera Track 4) present
- [ ] All links valid

**Project 5: dashboard**

```bash
cat /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/dashboard/README.md
```

- [ ] Project Overview present and clear
- [ ] Architecture present
- [ ] Setup instructions present
- [ ] Live URL included
- [ ] All links valid

**Project 6: contracts**

```bash
cat /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/contracts/README.md
```

- [ ] Project Overview present
- [ ] Contract addresses documented
- [ ] Deployment instructions present
- [ ] All links valid

### Step 3: Verify all links

For each README, test every link:

- Anchor links within the same document
- Links to other files in the repo (docs/, etc.)
- External links (block explorers, demo video, documentation)

### Step 4: Write the review report

Create `results/readme_review.md`:

```markdown
# README Review Report

## Summary
| Project | Status | Gaps |
|---------|--------|------|
| agent-coordinator | [Pass/Fail] | [list gaps] |
| agent-inference | [Pass/Fail] | [list gaps] |
| agent-defi | [Pass/Fail] | [list gaps] |
| hiero-plugin | [Pass/Fail] | [list gaps] |
| dashboard | [Pass/Fail] | [list gaps] |
| contracts | [Pass/Fail] | [list gaps] |

## Detailed Findings
[Per-project details of any gaps found]

## Broken Links
[List any broken links with the README they appear in]

## Remediation Actions
[Specific actions needed to fix each gap]
```

## Done When

- [ ] All six READMEs reviewed against completeness checklist
- [ ] All links tested
- [ ] Review report written with gaps and remediation actions
- [ ] Report saved to `results/readme_review.md`
