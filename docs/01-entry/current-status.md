# Current Status / 当前状态

> 本文件为 CURRENT_STATUS.md 迁移实体，归属 docs/01-entry/current-status.md，原始行数 90，已按 ≤120 wrap。
> 当前迭代 315，与 changelog 同步。

Last verified: 2026-08-12 (Godot `4.6.3.stable.official.7d41c59c4`)

## Product state

Voxglass is a feature-rich playable vertical slice, not the old 60-second prototype described by the historical 
iteration ledger. The current build contains a Hub, five playable archive rooms, six sound verbs, five save slots, a 
six-item shop catalog, 15 achievements, procedural SFX/BGM, death/respawn, and settings.

It is still **not a release candidate**. The current pass established a coherent five-room route, a green modern 
runtime gate, reproducible Windows exports, and real viewport evidence. It did not establish a complete player-driven 
desktop/gamepad playthrough, signing, installer/depot packaging, or store-submission readiness.

## Authoritative playable route

1. **New Game** always starts a fresh run in `archive_01` (`src/scenes/main.tscn`).
2. Completing `archive_01` returns the player to the Hub.
3. The Hub routes to `archive_02`, `archive_03`, and `archive_04`; each completed room returns to its matching Hub 
entrance. These three may be tackled from the Hub without pretending the old linear prototype route is authoritative.
4. The `archive_05` Hub door remains locked until `archive_01` through `archive_04` are complete in the current run.
5. Completing `archive_05` reaches `GAME_OVER_SUCCESS`. Success Retry starts a clean `archive_01` run; failure Retry 
reloads the failed room; quit-to-title followed by New Game also rebuilds a clean start scene.

## Verified in the second-stage recovery pass

- The modern release-oriented strict runtime gate is **11/11 PASS**: fresh import, project validation, and nine 
selected SceneTree/runtime regressions.
- The runtime regressions cover New Game, real scene changes, Hub/archive doors and spawn points, Continue, restart, 
failure/success retry, quit-to-title then New Game, final-room gating, progression de-duplication, save/runtime state, 
JSON child names, and Echo smoke behavior.
- The five-room route above is implemented and runtime-covered, including the locked `archive_05` capstone and real 
`GAME_OVER_SUCCESS` transition.
- Five save slots map room ids to real scenes. Hub/legacy-Hub aliases use the Hub safe spawn. PlayerStats, achievement 
progress, permanent perks, and perk-boosted vitals survive the tested save/load round-trips.
- Windows release and debug exports complete with separate non-empty EXE/PCK files. Exported debug/release executables 
and an independently unpacked release ZIP start headlessly and exit 0.
- Six real 1920x1080 OpenGL viewport captures pass strict log/PNG checks. The final batch was visually inspected after 
the legibility/layout and high-frequency art refresh; Saya, the Silent Merchant, Whisper, Silence Mote, and Voice Bell 
replacements are visible in the runtime frames.
- The art regression stage loads the imported Godot textures, checks the 20-frame Saya contract and transparent cutouts,
 and currently passes **64/64 assertions**.
- The Chinese UI now uses grayscale font anti-aliasing and stronger type hierarchy; the Hub has brighter five-archive 
wayfinding; the shop is an opaque scrollable modal that hides the gameplay HUD/tutorial/Hub labels while open.

## Test boundary: modern gate versus historical inventory

Use the modern runtime gate for release-oriented local/CI evidence:

```powershell
python tools/run_tests_strict.py `
  --godot C:\develop\godot\Godot_v4.6.3-stable_win64_console.exe `
  --suite runtime
```

Do **not** summarize the repository as “all tests pass.” The historical RefCounted aggregate was also measured with:

```powershell
python tools/run_tests_strict.py `
  --godot C:\develop\godot\Godot_v4.6.3-stable_win64_console.exe `
  --suite all --match _test_refcounted_runner
```

That legacy aggregate is currently red: `underlying_exit=1`, internal summary `passed=1885 failed=8`, additional 
`SCRIPT ERROR` output in the T334–T347-era group, and strict summary **0/1 PASS**. It is an unmaintained collection of 
historical source-grep and documentation-fragility checks, not the green release gate. Its failures must be 
rehabilitated or retired explicitly; they must not be hidden behind old README/REVIEW_LOG “100% PASS” claims.

## Capture and export commands

```powershell
python tools/capture_screenshots.py `
  --godot C:\develop\godot\Godot_v4.6.3-stable_win64_console.exe `
  --out-dir $env:TEMP\voxglass-runtime-captures

& C:\develop\godot\Godot_v4.6.3-stable_win64_console.exe `
  --headless --path . --export-release "Windows Desktop" `
  build/windows-release/Voxglass.exe
```

## Current local artifacts

- `build/Voxglass-Windows-x86_64.zip` — release EXE + PCK, **67,215,926 bytes**.
- SHA-256: `32C214BA2ADC85AE6FECCBAB46FD8267451A3D36702C0A98A1AA70530DB2093A`.
- `build/windows-debug/` — local diagnostic build, including the console wrapper.
- Latest strict real-capture evidence: `C:\Users\20655\AppData\Local\Temp\voxglass-art-batch2-final2-20260812` — **6/6 
PASS**, all 1920x1080, strict log scan clean; generated Warden states, HUD health bells, and repeated platform/water 
tiles visually inspected.
- Final ZIP extraction/startup evidence: `C:\Users\20655\AppData\Local\Temp\voxglass-package-art-batch2-20260813` — 
exactly one EXE plus one PCK; unpacked EXE headless startup exits 0.

`build/` and the temporary capture directory are local evidence/output, not repository history or signed distribution 
artifacts. Existing `docs/screenshots` remain asset-composited marketing mockups and were intentionally not overwritten.

## Remaining release blockers and risks

1. No complete player-driven keyboard playthrough of all five rooms has been recorded after the final integration; the 
runtime gate proves contracts and lifecycle edges, not human playability or balance.
2. Physical gamepad labels/indices, rebinding, and a full gamepad playthrough remain unverified. “Steam Deck verified” 
must not be claimed from this pass.
3. Windows signing, installer/updater behavior, Steam depot packaging, store upload, pricing/release-date decisions, 
and submission review have not been performed.
4. CI configuration exists but has not been proven by a remote Actions run in this uncommitted/unpushed recovery pass.
5. The repository has no license file. The owner must choose a license before public distribution.
6. The legacy RefCounted/source-grep aggregate remains red as documented above. It is not a release gate, but leaving 8 
failed assertions and T334–T347-era script errors unresolved is continuing maintenance debt.
7. Chinese legibility improved using Godot's default grayscale anti-aliasing, but the repository still has no bundled 
CJK font asset; cross-machine glyph consistency has not been demonstrated.
8. The six real captures live only in a temporary evidence directory. Store-ready screenshot selection/copy, trailer, 
system requirements, and final marketing review remain open.
9. Migration behavior for arbitrary older user save files has not been exhaustively tested beyond the covered aliases 
and round-trips; preserve backups before treating this as a public upgrade.

## Next product work

1. Perform and record a fresh five-room keyboard playthrough, then repeat on a physical gamepad/Steam Deck-class device.
2. Decide whether to repair, split, or retire the historical RefCounted/source-grep inventory; keep the modern runtime 
suite as the explicit release gate.
3. Run CI remotely from a reviewable branch and retain the build/test artifacts.
4. Curate real store screenshots without overwriting the historical mockups, then complete system requirements and 
trailer/store copy review.
5. Choose a license and add signing, installer/depot packaging, and release provenance before calling any ZIP a release 
candidate.
