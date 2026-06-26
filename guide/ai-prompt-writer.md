# SocialBox — AI Prompt Writer Guide

How the AI Writer works, how to use **multiple prompt versions**, what happens when you edit or break the prompt, and how to reset.

**Related:** [`post-writing-prompt.md`](../post-writing-prompt.md) (developer reference) · [`features.md`](../features.md) (feature status)

---

## 1. Two layers (template vs config)

| Layer | What it is | Stored where | Multiple versions today? |
|-------|------------|--------------|---------------------------|
| **Template** | Long system prompt (instructions to the AI) | SharedPreferences, or built-in default | **One active template** per device |
| **Config** | Topic, keywords, platform, audience, style fields | SharedPreferences (`last config`) | **Many via Presets** |

When you tap **Copy**, the app runs `PromptBuilder`: it takes the **active template** and replaces fixed configuration lines (e.g. `- TOPIC: …`) with values from **config**.

**Important:** Editing `post-writing-prompt.md` in the repo does **not** change the installed app. The app uses:

1. Your saved custom template (if you tapped **Save Template**), else  
2. `kDefaultPostWritingPrompt` bundled in the app build.

---

## 2. How to use multiple versions of prompts

SocialBox does not yet have “template presets” (multiple saved master prompts). Use the workflows below for what you need.

### A. Multiple **parameter** versions (recommended — built-in)

Use **Presets** for different post types that share the same template.

**Good for:** LinkedIn tutorial vs X hot take vs Facebook story — same instructions, different topic/audience/goal.

**Steps:**

1. Open **AI Post Writer Studio** (Home → tune icon, or route `/ai-writer`).
2. On **Configure**, set topic, platform, audience, archetype, goals, etc.
3. Tap **Save preset** (bookmark+ icon) → name it (e.g. `LinkedIn — tutorial`, `X — contrarian`).
4. To switch version: **Load preset** → pick name → confirm.

Presets also appear as chips on the **Home AI Writer** card (up to 5 shown).

| Preset name idea | Typical config focus |
|------------------|----------------------|
| `LI — thought leadership` | LinkedIn, Mentor, long word limit |
| `X — quick take` | X, Rebel, under 160 words |
| `FB — story` | Facebook, Everyman, Empath mode |
| `Tutorial post` | Practitioner mode, code pillar |

**Limitation:** Presets save **config only**, not the template text.

---

### B. Multiple **template** versions (manual — one active at a time)

Use when you have completely different system prompts (e.g. “sales prompt” vs “tutorial prompt” vs “short X prompt”).

**Workflow:**

1. Keep master copies **outside the app** (Notes, Google Doc, or files in this repo like `post-writing-prompt.md`).
2. Open Studio → **Template** tab.
3. Paste the version you want → **Save Template**.
4. To switch version: paste another file → **Save Template** again.
5. To go back to the app default: **Reset Default** (does not delete your external copies).

**Tip:** Name files clearly, e.g. `prompt-linkedin-long.md`, `prompt-x-short.md`, `prompt-facebook-warm.md`.

**Limitation:** Only **one** template is stored on the device at a time. Switching means paste + save (or reset to factory default).

---

### C. Hybrid (best for power users)

| Use case | Tool |
|----------|------|
| Same instructions, different posts | **Presets** (config) |
| Different instruction sets | **External template files** + Template tab paste |
| Factory baseline | **Reset Default** |
| Quick topic-only posts from Home | Dashboard card (uses last config + active template) |

**Example routine:**

- Maintain 2–3 template files on your PC.
- Keep 5–10 **presets** in the app for common post shapes.
- Before a writing session: paste the right template once, then load the right preset per post.

---

### D. Single template with “modes” (no file swapping)

If you do not want multiple files, keep **one** rich template and steer behavior with:

- **Content mode** (Empath, Practitioner, Contrarian, …) — appended to the built prompt when not “Auto”.
- **Content pillar** — appended as a focus line.
- **Presets** — different platform/audience/goal combinations.

This is one template, many behavioral variants — not separate prompt documents.

---

## 3. Configure tab — fixed fields (UI does not auto-expand)

These fields are **hardcoded**. Adding new lines to the template does **not** create new form fields.

| Field | Injected into template as |
|-------|---------------------------|
| Topic | `- TOPIC:` |
| Primary keyword | `- PRIMARY KEYWORD:` |
| Secondary keywords | `- SECONDARY KEYWORDS:` |
| Platform | `- PLATFORM:` |
| Target audience | `- TARGET_AUDIENCE:` |
| Brand archetype | `- BRAND_ARCHETYPE:` |
| Post goal | `- POST_GOAL:` |
| Word limit | `- WORD_LIMIT:` |
| Emoji range | `- EMOJIS:` |
| Hashtag range | `- HASHTAGS:` |
| Content mode | Appended section (if set) |
| Content pillar | Appended section (if set) |

`PromptBuilder` only replaces lines that still match the **exact** placeholder format from the default template. If you rename keys or remove the configuration panel, injection stops for those keys — the app still runs.

To add a **new** parameter with UI support requires a code change (`PromptConfig`, Configure tab, `PromptBuilder`).

---

## 4. If you delete or break the prompt

| Problem | App behavior | Fix |
|---------|--------------|-----|
| Template cleared or nonsense | Copy still works; output = your template + optional ACTIVE TOPIC | **Reset Default** or paste a good template |
| Config lines removed from template | Configure values not injected | Restore configuration panel lines or use template as-is |
| Never saved custom template | Uses built-in default | Nothing to fix |
| Corrupt saved config JSON | Falls back to empty/default config | Re-fill Configure or load a preset |
| Corrupt presets JSON | Presets list empty | Re-save presets |
| Invalid dropdown values | Snapped to allowed options via sanitizer | Automatic |

The app **does not crash** from a bad prompt. Worst case: copied text is incomplete or still has placeholders.

---

## 5. Reset and recovery (in the app)

### Reset template to factory default

1. **AI Post Writer Studio** → **Template** tab  
2. **Reset Default** → confirm  
3. Removes custom template from storage; loads `kDefaultPostWritingPrompt` from the current app build  

### Reset config (parameters)

There is **no** “Reset all configure fields” button.

| Method | Effect |
|--------|--------|
| **Load preset** | Replaces config with a saved preset |
| Manual edit | Change fields on Configure tab (auto-saved ~400 ms) |
| Clear app data / reinstall | Wipes template, config, and all presets |

### Reset does not affect

- Presets (unless you delete them individually when loading preset list)  
- Posts, comments, or other app data  

---

## 6. Where data is stored (local only)

| Key (SharedPreferences) | Content |
|-------------------------|---------|
| `socialbox_prompt_template` | Custom master template (optional) |
| `socialbox_prompt_last_config` | Last used Configure values |
| `socialbox_prompt_presets` | Saved presets (name + config JSON) |

Nothing is synced to cloud or GitHub from the app.

---

## 7. Home card vs Studio

| Location | What you can do |
|----------|-----------------|
| **Home — AI Writer card** | Topic, platform chips, preset chips, Copy / Paste / Open in AI, open Studio |
| **Studio — Configure** | All parameter fields, preview, save/load presets |
| **Studio — Template** | Edit master prompt, Save Template, Reset Default |

After Studio, returning to Home reloads last config so the card stays in sync.

---

## 8. Copy / preview flow

1. Set config (and optionally edit template).  
2. **Copy** (Home or Studio) builds: `PromptBuilder(template + config)`.  
3. Paste into ChatGPT, Gemini, Claude, etc. (**Open in AI** copies then opens browser).  
4. **Paste** sheet on Home helps pull AI output into a new post.

**Ready to copy:** topic must be non-empty (`isReady`). Other fields are optional but improve output.

---

## 9. Developer: ship a new default for all users

1. Edit [`post-writing-prompt.md`](../post-writing-prompt.md).  
2. Sync [`lib/features/ai_prompts/data/constants/default_post_writing_prompt.dart`](../lib/features/ai_prompts/data/constants/default_post_writing_prompt.dart).  
3. Ship a new build.  
4. Users with a **saved** custom template keep it until they tap **Reset Default**.

---

## 10. Future improvement (not in app yet)

| Feature | Would enable |
|---------|----------------|
| **Template presets** | Multiple saved master prompts by name (true template versions in-app) |
| **Reset config** button | One tap to factory Configure defaults |
| **Import/export** | Backup presets + template to file |
| **Dynamic form fields** | UI generated from template variables |

Track in [`features.md`](../features.md).

---

## Quick reference — multiple versions cheat sheet

```
Parameter variants (many)     →  Presets (Save / Load in Studio)
Template variants (many)      →  External files + paste + Save Template
One active template on device →  Only the last saved template (or default)
Back to factory template      →  Template tab → Reset Default
Back to factory config        →  Load a preset you saved as "defaults", or manual
```

---

*Last updated: 2026-06-26*