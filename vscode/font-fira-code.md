# How to setup Fira Code font in VSCode

## Download Fonts:

1. [FiraCode](https://github.com/tonsky/FiraCode)
2. [Script12 BT](https://www.dafontfree.net/freefonts-script12-bt-f141942.htm)

## Extract Fonts & Install:

Only install .ttf fonts in extracted folder.

## Install VSCode Extension:

[Custom CSS and JS Loader Preview](https://marketplace.visualstudio.com/items?itemName=be5invis.vscode-custom-css)

## Place `styles.css` file:

* Copy & save this as file and get the absolute path to this: `Users/<nampdn>/styles.css`

```css
.type.storage,.type.storage.declaration, .storage.class.modifier {
  font-family: 'flottflott';
  font-size: 1.7em;
}

.type.storage.arrow.function {
  font-family: 'Fira Code'
}

.decorator.name, .decorator.punctuation:not(.block), .import.keyword {
    font-family: 'flottflott';
    font-size: 1.7em;
    color: #68f39b!important;
}
.attribute-name {
    font-family: 'flottflott';
    font-size: 1.5em;
}

.html.quoted.double {
    color: #a6f3a6!important;
}
.comment {
	color: #c5c5fd!important;
}
.comment:not(.punctuation) {
    font-family: flottflott;
    font-size: 1.5em;
}
```

## Update User Settings in VSCode:

```json
{
    "editor.fontFamily": "Fira Code",
    "editor.fontLigatures": true,   
    "vscode_custom_css.imports": ["file:///Users/<nampdn>/styles.css"]
}
```
