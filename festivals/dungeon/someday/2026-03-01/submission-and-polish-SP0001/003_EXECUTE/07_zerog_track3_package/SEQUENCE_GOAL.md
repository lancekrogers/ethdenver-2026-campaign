---
fest_type: sequence
fest_id: 07_zerog_track3_package
fest_name: zerog_track3_package
fest_parent: 003_EXECUTE
fest_order: 7
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 07_zerog_track3_package

**Sequence:** 07_zerog_track3_package | **Phase:** 003_EXECUTE | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Create iNFT showcase documentation with on-chain evidence and write demo notes for the 0G Track 3 ($7k) ERC-7857 iNFT bounty submission.

**Contribution to Phase Goal:** This sequence produces the documentation and evidence package for 0G Track 3, which requires demonstrating ERC-7857 iNFT implementation with encrypted metadata. The iNFT showcase document with on-chain screenshots is the key submission artifact.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **iNFT Showcase Document**: `docs/inft-showcase.md` showing the minted iNFT, explaining encrypted metadata, describing the ERC-7857 implementation, with screenshots of on-chain data
- [ ] **Demo Notes**: `docs/demo-notes-0g-track3.md` with talking points for judges about the iNFT, how to verify on-chain, and key differentiators

### Quality Standards

- [ ] iNFT showcase includes actual on-chain transaction hashes and contract addresses
- [ ] Screenshots clearly show minted NFT data on a block explorer
- [ ] ERC-7857 compliance is explicitly documented with references to the standard
- [ ] Encrypted metadata flow is explained step-by-step

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_inft_showcase.md | Create iNFT showcase documentation | Primary evidence document for 0G Track 3 |
| 02_demo_notes.md | Write demo notes for 0G Track 3 | Structured talking points for the demo |
| 03_testing_and_verify.md | Quality gate: testing | Verifies on-chain evidence accuracy |
| 04_code_review.md | Quality gate: code review | Reviews documentation quality |
| 05_review_results_iterate.md | Quality gate: iterate | Addresses findings and confirms readiness |

## Dependencies

### Prerequisites (from other sequences)

- 03_zerog_track2_package: Same project (agent-inference) is already linked; iNFT is part of the inference agent

### Provides (to other sequences)

- **iNFT Showcase**: Referenced by 08_demo_video and used in 0G Track 3 submission form
