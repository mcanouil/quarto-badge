# Badge Extension For Quarto

`badge` is an extension for Quarto to provide a shortcode to display software version.

## Installing

```bash
quarto add mcanouil/quarto-badge
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

The shortcode `{{< badge <key> <value> >}}` will display a badge with the given version number.

You can provide any number of badges by specifying an array under the `badge` key in the `_quarto.yml` file or in the front matter of the document.

```yaml
badge:
  - key: current
    colour: firebrick
  - key: future
    class: bg-danger
    href: https://github.com/mcanouil/quarto-version-badge
  - key: old
    class: bg-warning
    href: https://github.com/mcanouil/quarto-version-badge/releases/tag/{{value}}
```

- `{{value}}` will be replaced by the value of the badge.
- You can use `colour` or `color` to specify the colour of the badge.
- You can also use `class` to specify a class to add to the badge.

```markdown
{{< badge current 1.0.0 >}}
{{< badge future 2.0.0 >}}
{{< badge old 0.1.0 >}}
```

> [!CAUTION]
> The `href` attribute is optional and currently breaks the table of contents links when used in headers.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).
