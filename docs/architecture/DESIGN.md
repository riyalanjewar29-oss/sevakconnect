# SevakConnect Design System (DESIGN.md)

## Brand Identity & Core Philosophy
SevakConnect is an operational coordination platform for the Pandharpur Wari pilgrimage. The design system is grounded in **Seva** (selfless service): humble, authoritative, calm under pressure, high-contrast, and deeply reliable in harsh outdoor conditions.

---

## 1. Color Palette

### Core Brand Colors
- **`primary` (#3F6B4A)**: Tulsi Green. Used for primary buttons, active navigation states, and core branding.
- **`secondary` (#26365C)**: Vitthal Indigo. Used for headers, dashboard chrome, cards, and grounding elements.
- **`tertiary` (#D9622B)**: Saffron Accent. Used ONLY as a minimal accent — a small icon or single highlight — never as a button background or dominant surface color.

### Surfaces & Backgrounds
- `surface`: `#FCF9F8` (Warm Canvas)
- `surfaceContainerLowest`: `#FFFFFF` (Card Background)
- `surfaceContainerLow`: `#F6F3F2`
- `surfaceContainer`: `#F0EDED`
- `surfaceContainerHigh`: `#EAE7E7`
- `surfaceContainerHighest`: `#E5E2E1`
- `onSurface`: `#1B1C1C` (High-contrast text)
- `onSurfaceVariant`: `#554336` (Muted secondary text)

### Four-Tier Functional Status Colors
Do not substitute the brand palette for status indicators:
- **Normal**: `#2E6B27` | Container: `#E2F4E0` | OnContainer: `#11420C`
- **Moderate**: `#E69500` | Container: `#FEF3C7` | OnContainer: `#92400E`
- **High**: `#D9622B` | Container: `#FFEDD5` | OnContainer: `#9A3412`
- **Critical**: `#BA1A1A` | Container: `#FFDAD6` | OnContainer: `#93000A`

### Elevation & Ambient Shadows
- **Level 1** (Standard Cards): `0 2px 8px rgba(38, 54, 92, 0.12)` (12% opacity Navy-tinted shadow)
- **Level 2** (Emergency Overlays / SOS Alerts): `0 4px 16px rgba(186, 26, 26, 0.20)` (20% opacity Alert shadow)

---

## 2. Typography Scale (Inter Font Family)
- **Display**: 32px / 40px line-height / Weight 700 / -0.02em letter spacing
- **Headline-Lg**: 24px / 32px line-height / Weight 600 (Mobile: 22px / 28px)
- **Headline-Md**: 20px / 28px line-height / Weight 600
- **Body-Lg**: 18px / 28px line-height / Weight 400
- **Body-Md**: 16px / 24px line-height / Weight 400
- **Label-Lg**: 14px / 20px line-height / Weight 600 / +0.01em letter spacing
- **Label-Sm**: 12px / 16px line-height / Weight 500 / +0.02em letter spacing

---

## 3. Shapes & Spacing
- **Corner Radius**: 8px (0.5rem) for standard cards, input fields, and action buttons.
- **Pill Shape**: Fully rounded for status badges, live chips, and tag indicators.
- **Spacing Scale**: Strict 8px rhythm (4px unit grid). 16px lateral margins on mobile, 1200px max-width container on larger screens.
- **Touch Target / Form Inputs**: 56px minimum height for input fields and action buttons with 16px text. Labels always visible above input fields.

---

## 4. Key Component Guidelines
- **Buttons**: Primary buttons use Tulsi-green background (`#3F6B4A`) with white text. Secondary buttons use Vitthal-indigo outline (`#26365C`), not filled.
- **Offline-First Banner**: Persistent slot below header. Deep Navy (`#26365C`) when Online, shifts to Moderate Yellow (`#E69500`) when Working Offline.
- **Status Badges**: High-contrast pill shape including a simulation-honest last-updated timestamp.
