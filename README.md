# Badge Extension For Quarto

`badge` is an extension for Quarto to provide a shortcode to display styled badges for software versions, feature status, or any other categorised information.

Define each kind of badge once under `extensions.badge`, then write `{{< badge key value >}}` wherever the label belongs, including inside a heading.

## Installation

```bash
quarto add mcanouil/quarto-badge@2.5.2
```

This will install the extension under the `_extensions` subdirectory.

If you're using version control, you will want to check in this directory.

## Documentation

The full documentation lives at <https://m.canouil.dev/quarto-badge/>: every option, the validation rules, and each feature rendered.

[`example.qmd`](example.qmd) is a short, standalone starting point you can copy.

## Licence

[MIT](https://github.com/mcanouil/quarto-badge?tab=MIT-1-ov-file#readme).
