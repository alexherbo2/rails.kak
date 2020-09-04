# rails.kak

[Ruby on Rails] support for [Kakoune].

[Ruby on Rails]: https://rubyonrails.org
[Kakoune]: https://kakoune.org

## Features

- Easy navigation of the Rails directory structure.

## Dependencies

- [connect.kak]
- [fd]

[connect.kak]: https://github.com/alexherbo2/connect.kak
[fd]: https://github.com/sharkdp/fd

### Recommended plugins

- [kak-lsp]
- [snippets.kak]

[kak-lsp]: https://github.com/ul/kak-lsp
[snippets.kak]: https://github.com/alexherbo2/snippets.kak

## Installation

Add [`rails.kak`](rc/rails.kak) to your autoload or source it manually.

## Usage

Type `:rails-█` to discover the commands and their aliases.

All edit commands can be entered without argument.

Press `gf` to jump to relevant places.
For example, in a method definition, jump between the controller and its view.

## Configuration

**Example** – Map `gd` and `gD` to jump to the definition and implementation:

``` kak
# Go to definition and implementation
map global goto -docstring 'Definition' d '<esc>: lsp-definition<ret>'
map global goto -docstring 'Implementation' D '<esc>: lsp-implementation<ret>'
```
