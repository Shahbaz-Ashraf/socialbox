# SocialBox — UI/UX Redesign Session Prompt

Copy everything below into a **new Cursor/Grok session** to continue modern UI work.

---

## Prompt (paste this)

```
You are working on SocialBox — a Flutter social media manager (Features-First Clean Architecture + BLoC/Cubit).

READ FIRST (in order): CLAUDE.md, agents.md, STATUS.md, features.md

## Goal
Complete a **modern, polished UI/UX pass** across the app. The home screen was redesigned for compact layout but needs further visual refinement. Fix all overflow/layout bugs. Do NOT remove features (expansion policy).

## Environment (Windows, project on I:)
$env:PUB_CACHE = "I:\.pub-cache"
Set-Location I:\Posts\socialbox
flutter pub get
flutter analyze
flutter test
flutter run -d 1154137434000432   # Infinix X6853

## Known bugs to fix
1. ~~"Open in AI" bottom sheet RenderFlex overflow~~ — FIXED with DraggableScrollableSheet + scrollable ListView in `ai_app_picker_sheet.dart`. Verify on 320px-wide devices.
2. `PostListBloc._subscribe` — `emit` called after event handler completed (~line 113). Fix with `emit.forEach` or stream subscription in bloc constructor.
3. Test all bottom sheets and forms on narrow screens (320–360px).

## Home screen — current state (after compact redesign)
- `lib/features/dashboard/presentation/pages/dashboard_page.dart` — AI Writer first, horizontal metrics strip, tonal action chips, tabbed feed (Schedule / Reminders / Activity).
- `lib/features/dashboard/presentation/widgets/dashboard_feed_tabs.dart` — tabbed content, max 3 items per tab.
- `lib/features/dashboard/presentation/widgets/dashboard_stats_row.dart` — horizontal scrolling metric pills.
- `lib/features/ai_prompts/presentation/widgets/dashboard_ai_writer_card.dart` — single-line topic field, SegmentedButton platforms, Copy/Paste/Open-in-AI actions.

## Design direction (modern, NOT childish, NOT Windows-98 flat)
Target: **Buffer / Notion / Linear** quality — professional SaaS mobile app.

### Visual system
- Material 3 with subtle depth: soft shadows (`AppThemeTokens.cardShadow`), 16px radius, `surfaceContainer` hierarchy.
- One accent color (indigo primary) used sparingly; muted neutrals for text.
- Typography: 14px body, 13px section labels, 18–22px metric numbers. No ALL-CAPS shouting.
- Spacing: 8/12/16 grid. Minimize vertical scroll on home — fit AI writer + metrics + tabs in ~1.5 screens.

### Components to polish
| Area | File(s) | Tasks |
|------|---------|-------|
| Home | `dashboard_page.dart`, widgets/* | Skeleton loading, empty-state illustrations, pull-to-refresh polish |
| AI Writer | `dashboard_ai_writer_card.dart`, `ai_prompt_studio_page.dart` | Form validation hints, focus states, keyboard-safe sheets |
| Calendar | `calendar_page.dart` | Match home visual system |
| Posts | `posts_page.dart`, `create_edit_post_page.dart` | Modern cards, better form fields |
| Settings | `settings_page.dart` | Grouped list tiles, less clutter |
| Bottom nav | `main_shell.dart` | Optional: floating nav with blur (iOS-style) if it fits brand |
| Theme | `app_theme.dart`, `app_colors.dart`, `app_decorations.dart` | Unify `modernCard`, input decoration, button styles app-wide |

### UX requirements
- All text fields: clear labels, hints, error text, `isDense` where appropriate, no overflow.
- Bottom sheets: always `isScrollControlled: true`, scrollable content, safe area insets.
- Tap targets ≥ 48dp. Haptic on primary actions.
- Dark mode parity for every changed widget.

### Architecture rules (non-negotiable)
- Views → Bloc/Cubit only. No `getIt` in widgets.
- No feature deletion to fix errors.
- Register new deps in `injection_container.dart`.
- Update `features.md` when shipping UI changes.

## Verification checklist
- [ ] `flutter analyze` — 0 issues
- [ ] `flutter test` — all pass
- [ ] Run on Infinix X6853, capture screenshots to `screenshots/`
- [ ] Tap "Open in AI" — no yellow/black overflow stripes
- [ ] Home screen: minimal scroll to reach all primary actions
- [ ] Create post form usable on small screen

## Deliverables
1. Modern UI across home + at least posts create/edit + settings
2. All overflow bugs fixed
3. Tests updated
4. Commit with descriptive message + push to `origin main`
5. Update STATUS.md and features.md

Start by running `flutter analyze` and reading the dashboard files listed above. Then implement highest-impact visual fixes first.
```

---

## Files changed in prior session (reference)

| File | Change |
|------|--------|
| `ai_app_picker_sheet.dart` | DraggableScrollableSheet fixes overflow |
| `dashboard_page.dart` | Compact layout, AI writer top, tabbed feed |
| `dashboard_feed_tabs.dart` | Schedule/Reminders/Activity tabs |
| `dashboard_stats_row.dart` | Horizontal metric pills |
| `dashboard_ai_writer_card.dart` | Modern compact form |
| `ai_platform_chip_row.dart` | SegmentedButton for platforms |
| `app_decorations.dart` | `modernCard`, `accentHeader` |
| `stat_card.dart` | Compact horizontal variant |

---

*Created: 2026-06-26*