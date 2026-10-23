# Design system

`packages/nalum_ui`: tokens, theme and shared widgets. The visual source of
truth is the website's `design.md` ("Academic Prestige"). Cited as
`docs/DESIGN_SYSTEM.md §N`.

## §1 Rules

- Screens take colors and text styles from `Theme.of(context)` and
  `context.nalum` (the theme extension). No hex values or font sizes in
  feature code.
- New tokens are added to the website's `design.md` first, then mirrored
  here, so web and app stay one brand.
- Material 3 on both platforms, with platform conventions where users expect
  them: iOS back-swipe, adaptive switches/date pickers, the native share
  sheet. No separate Cupertino UI.
- `nalum_ui` widgets take already-localized strings and callbacks. They don't
  know about routes, providers or the API.

## §2 Color

### §2.1 Light scheme

`design.md` uses Material 3 role names, so `NalumColorSchemes.light` maps
each token 1:1 onto `ColorScheme` (`primary #6E0000`,
`primaryContainer #990000`, `surface #F8F9FA`, …). Filled buttons use the
brand crimson `#990000` with white text, as `design.md` specifies for
primary actions. Card/input borders are `#E2E8F0`.

### §2.2 Dark scheme (provisional)

`design.md` has no dark tokens. Until design delivers them,
`NalumColorSchemes.dark` is generated from the brand seed with
`ColorScheme.fromSeed`. Before launch: get dark tokens designed, add them
to `design.md`, replace the generated scheme, and re-check contrast.

## §3 Typography

`design.md` uses Hanken Grotesk for everything. Mapping onto the M3 text
theme:

| design.md | Size / line / weight | M3 role |
|---|---|---|
| headline-xl | 36 / 44 / 700 | `headlineLarge` |
| headline-lg | 28 / 36 / 600 | `headlineMedium` |
| headline-lg-mobile | 24 / 32 / 600 | `headlineSmall` |
| headline-md | 20 / 28 / 600 | `titleLarge` |
| body-lg / md / sm | 18/28, 16/24, 14/20 / 400 | `bodyLarge/Medium/Small` |
| label-md | 14 / 16 / 600, +0.02em | `labelLarge` |
| label-sm | 12 / 14 / 500 | `labelSmall` |

### §3.1 Bundling the font

The font is bundled, not fetched at runtime (no network dependency, no font
flash). To add it:

1. Download Hanken Grotesk (SIL Open Font License) from Google Fonts.
2. Put the weights in use (400, 500, 600, 700) in
   `apps/mobile/assets/fonts/HankenGrotesk/` together with `OFL.txt`.
3. Declare them under `flutter: fonts:` in `apps/mobile/pubspec.yaml` with
   family `HankenGrotesk`.

Until then Flutter falls back to the platform font.

## §4 Spacing and shape

- Spacing: 4 px base, 8 px rhythm: `NalumSpacing.xs 4`, `sm 8`, `md 16`,
  `lg 24`, `xl 32`. Phone side margin 16.
- Radii: controls 8, cards 16, pills fully rounded (`NalumRadii`).
- Elevation: cards are white on the off-white surface with
  `0 4 20 rgba(0,0,0,.04)`; overlays use `0 12 32 rgba(0,0,0,.08)`
  (`NalumThemeExtension`).
- Touch targets are at least 48×48.

## §5 Components

Available: `NalumCard`, `EmptyState`, `ErrorState`.

Planned (add when a second screen needs them): `UserAvatar`,
`VerifiedBadge`, `FilterChipBar`, `SegmentedToggle`, `ConfirmDialog`,
`ReportSheet`, `MarkdownView`, `MentionTextField`, skeleton loaders.

A widget moves into `nalum_ui` when two features need it. Until then it
stays in the feature's `presentation/widgets/`.

## §6 Accessibility

- Layouts work at 200 % text scale without clipping; test it ([TESTING.md §7](TESTING.md)).
- Every icon-only button has a `tooltip` (it doubles as the screen-reader label).
- Text contrast meets WCAG AA in both themes. Check crimson on dark surfaces
  in particular.
- Don't convey state by color alone (e.g. unread dots get a semantic label).
- Respect "reduce motion": no decorative animations when
  `MediaQuery.disableAnimations` is true.
