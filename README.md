# Version Badge Extension For Quarto

`version-badge` is an extension for Quarto to provide a shortcode to display software version.

## Installing

```bash
quarto add mcanouil/quarto-version-badge
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

The shortcode `{{< v <version> style=<CSS style> >}}` will display a badge with the given version number.

If `<version>` matches `version-badge` from the YAML frontmatter, the badge will be displayed with `bg-success` CSS class from Bootstrap, otherwise it will be displayed with `bg-danger`.

Additional CSS styles can be provided with the `style` parameter which will be added to the badge as inline CSS.

The extension also provides two CSS classes: `.badge-release` and `.badge-prerelease` that can be used to style the badge.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).
