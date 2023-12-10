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

You can provide any number of badges by specifying an array under the `quarto-badge` key in the `_quarto.yml` file or in the front matter of the document.

```yaml
badge:
  - key: "current"
    class: "bg-success"
  - key: "future"
    class: "bg-danger"
    href: "https://github.com/mcanouil/quarto-version-badge"
  - key: "old"
    class: bg-warning
    href: "https://github.com/mcanouil/quarto-version-badge/releases/tag/{{value}}"
```

`{{value}}` will be replaced by the value of the badge.

> [!NOTE]
> The `href` attribute is optional and currently breaks the table of contents links when used in headers.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).
