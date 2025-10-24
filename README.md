# Badge Extension For Quarto

`badge` is an extension for Quarto to provide a shortcode to display styled badges for software versions, feature status, or any other categorised information.

## Installation

```bash
quarto add mcanouil/quarto-badge
```

This will install the extension under the `_extensions` subdirectory.

If you're using version control, you will want to check in this directory.

## Usage

### Basic Usage

The shortcode `{{< badge <key> <value> >}}` displays a badge with the specified key and value.

```markdown
{{< badge current 1.0.0 >}}
{{< badge future 2.0.0 >}}
{{< badge old 0.1.0 >}}
```

### Configuration

Define badge configurations in the `_quarto.yml` file or in the front matter of individual documents under the `extensions.badge` key:

```yaml
extensions:
  badge:
    - key: current
      colour: springgreen
    - key: future
      class: bg-danger
      href: https://github.com/mcanouil/quarto-badge
    - key: old
      class: bg-warning
      href: https://github.com/mcanouil/quarto-badge/releases/tag/{{value}}
```

### Configuration Options

Each badge configuration supports the following properties:

- **`key`** (required): The identifier used in the shortcode to reference this badge configuration.
- **`colour`** or **`color`** (optional): A CSS colour value (e.g., `firebrick`, `#ff0000`, `rgb(255, 0, 0)`).
- **`class`** (optional): CSS class(es) to apply to the badge (e.g., Bootstrap classes like `bg-danger`, `bg-warning`).
- **`href`** (optional): URL to link the badge to. Use `{{value}}` as a placeholder to insert the badge value into the URL.

### Examples

#### Simple Colour Badge

```yaml
extensions:
  badge:
    - key: stable
      colour: green
```

```markdown
{{< badge stable 3.2.1 >}}
```

#### Badge with Bootstrap Class

```yaml
extensions:
  badge:
    - key: experimental
      class: bg-warning text-dark
```

```markdown
{{< badge experimental beta >}}
```

#### Badge with Dynamic Link

```yaml
extensions:
  badge:
    - key: release
      colour: blue
      href: https://github.com/user/repo/releases/tag/v{{value}}
```

```markdown
{{< badge release 1.5.0 >}}
```

This creates a badge linking to `https://github.com/user/repo/releases/tag/v1.5.0`.

### Using Badges in Headers

Badges can be used in section headers to indicate feature status or version information:

```markdown
## {{< badge current 1.1 >}} Existing Feature

## {{< badge future 2.0 >}} Upcoming Feature

## {{< badge old 0.9 >}} Legacy Feature
```

> [!CAUTION]
> The `href` attribute is optional and currently breaks the table of contents links when used in headers.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

Output of `example.qmd`:

- [HTML](https://m.canouil.dev/quarto-badge/)

## Notes

- The extension only works with HTML output formats.
- The deprecated top-level `badge` configuration (instead of `extensions.badge`) is still supported but will show a warning.
