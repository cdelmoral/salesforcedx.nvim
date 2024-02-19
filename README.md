# salesforcedx.nvim

[Neovim](https://neovim.io/) plugin that allows you to use the Salesforce CLI,
similar to the
[Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode-core)
plugin, but for your favorite code editor.

## Prerequisites

- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) with
  [apex](https://github.com/aheber/tree-sitter-sfapex) support

## Installation

You can install salesforcedx.nvim with any plugin manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "cdelmoral/salesforcedx.nvim",
  config = function()
    require("salesforcedx").setup()
  end,
}
```

## Commands

> [!WARNING]
> Command names will probably change in a future release.

salesforcedx.nvim provides the following commands:

| Command      | Description                                               |
| ------------ | --------------------------------------------------------- |
| `Deploy`     | Deploy source code to the configured default scratch org  |
| `TestClass`  | Run apex tests for the currently selected apex test class |
| `TestMethod` | Run the currently selected apex test method               |

## Status Line Integration

salesforcedx.nvim provides the `require"salesforcedx".get_default_target_org`
function that can be used to display the configured default scratch org
in the status line.

For example, for [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
add this to your configuration:

```lua
{
  require("salesforcedx").get_default_target_org,
  cond = require("salesforcedx").is_salesforce_project_directory,
}
```

## Roadmap

This roadmap is a personal wishlist of features that I would like to eventually
incorporate into salesforcedx.nvim when I have time. Pull requests are always
welcome!

### High Priority

- [x] Run apex class/method test
- [x] Deploy local changes to org
- [x] Status line function for scratch org user
- [ ] Create apex class/apex trigger/apex unit test class/lwc
- [ ] Display default org details
- [ ] Open default org
- [ ] Set default org
- [ ] Validate sf/sfdx is installed
- [ ] Validate it is apex file
- [ ] Add documentation and types

### Low Priority

- [ ] Run apex test suite
- [ ] Retrieve remote changes from org
