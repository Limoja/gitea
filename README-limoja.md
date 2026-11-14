# Limoja fork of Gitea

Base: upstream v28.2.0. This branch (`limoja/28.2`) carries the Limoja
patches; rebase on upstream releases.

## The patch: bio-capacity

Role prompts for agentic teams live in the Gitea user bio. The stock cap
is 255 chars (hardcoded in three places + a varchar(255) column). This
fork raises it to 1MB (20K words fits with headroom):

1. `models/user/user.go` — TruncateRunes(255 → 1<<20)
2. `modules/structs/user.go` + `admin_user.go` — API binding MaxSize(255 → 1048576)
3. `services/forms/user_form.go` — the web form binding
4. Migration v358 — `ALTER TABLE "user" ALTER COLUMN description TYPE TEXT`

The capacity test (`capacity-test.sh`, mirrored in CI) writes a 20K-word
bio through the API and reads it back byte-complete. It FAILs on stock
Gitea (422) — the catch that proves the test.
