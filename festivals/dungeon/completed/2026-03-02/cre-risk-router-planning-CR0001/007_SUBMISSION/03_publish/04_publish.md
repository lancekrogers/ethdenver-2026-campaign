---
fest_type: task
fest_id: 01_publish.md
fest_name: publish
fest_parent: 03_publish
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:45:34.459814-07:00
fest_updated: 2026-03-02T01:20:25.338271-07:00
fest_tracking: true
---


# Task: publish

## Objective

Publish the finalized Moltbook post on the Chainlink Convergence hackathon platform and confirm the submission is live and accessible before the March 8, 2026 11:59 PM ET deadline.

## Requirements

- [ ] Moltbook post published on the hackathon platform (Req P0.23)
- [ ] Published post is publicly accessible and all sections render correctly
- [ ] GitHub repo link in the post is valid and accessible
- [ ] Block explorer evidence link works
- [ ] Submission confirmed before March 8, 2026 11:59 PM ET deadline

## Implementation

1. **Confirm all prerequisites are complete**:
   - [ ] `01_draft_post.md` -- Moltbook draft finalized
   - [ ] `02_registration_form.md` -- Registration form submitted
   - [ ] `03_final_review.md` -- Final review passed with no issues

2. **Publish the Moltbook post**:
   - Navigate to the Moltbook platform / hackathon submission portal
   - Copy the content from `submission/moltbook-draft.md`
   - Paste into the submission form, preserving formatting
   - Attach any required media (screenshots, diagrams)
   - Set the post to "public" / "published" status
   - Click publish/submit

3. **Verify the published post**:
   - Open the published URL in an incognito/private browser window
   - Verify all 10 sections render correctly with proper formatting
   - Click every link in the post to confirm they work:
     - [ ] GitHub repo link opens and shows the README
     - [ ] Block explorer link shows the transaction with DecisionRecorded event
     - [ ] Any other referenced URLs are accessible
   - Verify code blocks, tables, and diagrams display properly

4. **Save the published URL**:
   ```bash
   # Record the published URL for reference
   echo "Published URL: <paste-url-here>" >> projects/cre-risk-router/submission/published.txt
   echo "Published at: $(date -u)" >> projects/cre-risk-router/submission/published.txt
   ```

5. **Confirm timing**:
   - Verify the submission timestamp is before March 8, 2026 11:59 PM ET
   - Save a screenshot of the published post with visible timestamp

6. **Update the registration form** (if needed):
   - If the registration form has a field for the Moltbook post URL, ensure it is updated with the published URL

## Done When

- [ ] All requirements met
- [ ] Post is live and publicly accessible on the hackathon platform
- [ ] All links in the post verified working
- [ ] Submission timestamp confirmed before deadline
- [ ] Published URL recorded in `submission/published.txt`