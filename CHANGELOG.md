# Changelog

## Unreleased

## 2.5.0 (2026-05-28)

### New Features

- feat: Add `icon` configuration option for a Bootstrap icon prefix shown before the badge value.
- feat: Add `target` configuration option for the link target attribute, automatically setting `rel="noopener noreferrer"` for `_blank`.
- feat: Add `title` configuration option for a hover tooltip, with `{{value}}` placeholder support.
- feat: Validate `colour` against CSS named colours, hex, `rgb`/`rgba`, `hsl`/`hsla`, `hwb`, `lab`, `lch`, `oklab`, `oklch`, and `color()` values; invalid values are warned and ignored.
- feat: Validate `href` (after `{{value}}` substitution) and reject malformed or disallowed-scheme URLs with a warning.
- feat: Support per-document badge overrides via the `badge-overrides` metadata key; entries override matching `key` values from the base configuration and new keys are appended.

### Bug Fixes

- fix: Warn when the badge shortcode is invoked with a key that is not configured (previously rendered an empty element silently).
- fix: HTML-escape the badge value, `href` attribute, `{{value}}` substitution result, and `class`/`title` attributes to prevent attribute injection.

### Refactoring

- refactor: Synchronise shared modules (`string.lua`, `logging.lua`, `metadata.lua`, `pandoc-helpers.lua`) with the canonical source and add `colour.lua` for colour validation.

### Documentation

- docs: Document new configuration options, validation behaviour, and document-level overrides in README and example.
- docs: Extend `_schema.yml` with the new properties and the `badge-overrides` key.

## 2.4.1 (2026-04-15)

### Refactoring

- refactor: Synchronise shared module (`logging.lua`) with canonical version.

### Documentation

- docs: Remove version pinning from example URLs in README and example.

## 2.4.0 (2026-03-23)

### Refactoring

- refactor: Replace monolithic `utils.lua` with focused modules (`string.lua`, `logging.lua`, `metadata.lua`, `pandoc-helpers.lua`, `html.lua`, `paths.lua`, `colour.lua`).

## 2.3.0 (2026-02-21)

### New Features

- feat: Add _schema.yml for configuration validation and IDE support (#24).

## 2.2.2 (2026-02-11)

### Bug Fixes

- fix: Update copyright year.

## 2.2.1 (2025-12-03)

### Bug Fixes

- fix: Use british english spelling.

## 2.2.0 (2025-10-25)

### Documentation

- docs: Update author information in example.qmd.
- docs: Add output section for example.qmd in README.
- docs: Update installation section and enhance usage examples.
- docs: Update installation and usage sections in README and example.

## 2.1.0 (2025-10-24)

### Refactoring

- refactor: Use module and enhance logging utilities (#19).

## 2.0.2 (2025-04-05)

### Bug Fixes

- fix: Add output-file option.

## 2.0.1 (2025-04-05)

### New Features

- feat: Add CITATION file for project citation.

### Bug Fixes

- fix: Switch to deploy from GitHub Actions (#14).

### Documentation

- docs: Change note to caution.

## 2.0.0 (2023-12-10)

### Refactoring

- refactor: Rewrite the whole API (#10).

## 1.2.0 (2023-10-19)

### Bug Fixes

- fix: "v" no longer hardcoded (#5).

## 1.1.0 (2023-08-06)

### New Features

- feat: Make badge clickable to access changelog (#3).

## 1.0.0 (2023-06-22)

### New Features

- feat: Add new parameters to control badges.

## 0.2.1 (2023-06-20)

### Bug Fixes

- fix: Better alignment of the badge with the text.

## 0.2.0 (2023-06-20)

### Bug Fixes

- fix: Default when no version provided in yaml.
- fix: Hide badges from TOC.
- fix: Add toc.

## 0.1.0 (2023-06-20)

### Bug Fixes

- fix: Remove prefix.
