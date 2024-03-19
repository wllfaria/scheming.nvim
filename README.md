<div align="center">

<h1>Scheming</h1>

<img src="./.github/logo.png" alt="Scheming Logo" height="350px">

<p>Not all schemes are plots... Some are just pretty!</p>

</div>

---

## 󰏔 Installation
Install the plugin with your package manager of choice.

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{ 
    "wllfaria/scheming.nvim",
    config = function()
        require("scheming").setup({
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        })
    end
}
```

##  Preview

![A gif preview of the plugin](./.github/preview.gif)


##  Configuration
you can configure the plugin by passing a table to the `setup` function. 
The default values are shown below.

```lua
{
    layout = "bottom", -- "bottom" or "float"
    enable_preview = true, -- enable/disable previewing themes
    persist_scheme = true, -- persist selected scheme cross sessions
    window = {
        height = 12, -- window height in lines
        width = 80, -- window width in columns (only for "float" layout)
        border = "single", -- "single", "double" or "rounded"
        show_border = true, -- show/hide border
        title = "Scheming", -- window title
        show_title = true, -- show/hide title
        title_align = "center", -- "left", "center" or "right"
    },
    mappings = {
        cancel = { "q", "<C-c>" }, -- mappings to close the window
        select = { "<CR>" }, -- mappings to select a scheme
        toggle = { } -- mappings to toggle the window
        -- by default theres no mappings to toggle the window
        -- you can add your own here or use the `SchemingToggle` command
        -- more info in the usage section below
    },
    schemes = {
        -- list of schemes to be displayed
        -- refer to the usage section below
    },
    sorting = {
        by = "name" -- "name" or "tag" (sort by name or tag)
        order = "none", -- "asc", "desc", or "none" (no sorting)
    },
    override_hl = {
        -- override highlight groups
        -- refer to the advanced usage section
    }
}
```

##  Usage

You can use the `SchemingToggle` command to open/close the selection window,
or you can add your own mappings to the `mappings.toggle` table in the 
configuration.

You can add your schemes to the `schemes` table in the configuration in the
following ways.

```lua
{
    schemes = {
        "radium", -- just the name of the scheme
        catppuccin = {}, -- the name of the scheme and a configuration table
        gruvbox = {
            tag = "dark", -- a tag to sort the schemas
            config = {} -- a configuration table
        }
    }
}
```

> NOTE: you can provide a configuration table for the schemes, and scheming
will call `setup()` for the scheme with the provided configuration.

##  Overriding highlight groups
You can use the `override_hl` table to override neovim highlight groups.

```lua
{
    override_hl = {
        -- You can use the same options as the `highlight` command,
        -- refer to `:h highlight` for more information
        Normal = { fg = "#ffffff", bg = "#000000" },
        Comment = { fg = "#ff0000" },
        CursorLine = { bold = true },
    }
}
```
