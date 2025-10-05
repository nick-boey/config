-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.filetype.add({
  extension = {
    sunset = "sunset",
  },
})

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.sunset = {
  install_info = {
    url = "https://github.com/sunset-lang/tree-sitter-sunset",
    branch = "dev",
  },
}
