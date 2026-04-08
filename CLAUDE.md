# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

nvim-treesitter is a Neovim plugin that manages tree-sitter parsers and provides a curated collection of queries (highlights, indents, folds, injections, locals) for 240+ languages. Requires Neovim 0.12+ and tree-sitter-cli 0.26.1+.

## Common Commands

All tools are auto-downloaded to `.test-deps/` on first use.

```bash
make all                          # format, lint, docs, and tests
make lua                          # format + lint Lua (stylua + emmylua_check)
make formatlua                    # auto-format Lua with stylua
make checklua                     # lint Lua with EmmyLua analyzer (warnings-as-errors)
make query                        # format + lint + check query files
make tests                        # run full test suite
make tests TESTS=indent           # run only indent tests
make tests TESTS=query            # run only query tests
make docs                         # regenerate SUPPORTED_LANGUAGES.md from parsers.lua
```

Tests use plentest.nvim (busted-based) with Neovim running headless. Highlight tests use the highlight-assertions tool.

## Architecture

### Core Modules (`lua/nvim-treesitter/`)

- **`init.lua`** - Public API: `setup()`, `install()`, `uninstall()`, `update()`, `indentexpr()`
- **`parsers.lua`** - Registry of all supported parsers with metadata (URL, revision, tier, maintainers, dependencies). This is the largest file (~2700 lines) and is the source of truth for supported languages.
- **`install.lua`** - Async parser download, compilation, and path management
- **`config.lua`** - Configuration state, install directory, language normalization
- **`indent.lua`** - Tree-sitter-based indentation engine with memoization and query processing
- **`async.lua`** - Coroutine-based async/await framework used by install
- **`health.lua`** - `:checkhealth` integration (Neovim version, ABI compat, tool availability)

### Plugin Entry Points (`plugin/`)

- **`nvim-treesitter.lua`** - Registers user commands: `TSInstall`, `TSUpdate`, `TSUninstall`, `TSInstallFromGrammar`, `TSLog`
- **`filetypes.lua`** - Maps parser names to Neovim filetypes when they differ
- **`query_predicates.lua`** - Custom tree-sitter query predicates (`kind-eq`, `any-kind-eq`)

### Queries (`runtime/queries/<language>/`)

Query types: `highlights.scm`, `indents.scm`, `injections.scm`, `folds.scm`, `locals.scm`. Validated by `ts_query_ls` with captures/predicates defined in `.tsqueryrc.json`.

### Tests (`tests/`)

- `tests/indent/` - Per-language indentation specs
- `tests/query/` - Highlight and injection assertion tests
- `tests/common.lua` - Shared test utilities (`Runner` helper class)
- `scripts/minimal_init.lua` - Test initialization script

## Parser Tiers

- **Tier 1** (stable): Track semver releases, provide WASM artifacts
- **Tier 2** (unstable): Track HEAD commits
- **Tier 3** (unmaintained): No active query maintainer
- **Tier 4** (unsupported): Deprecated or broken

## Adding a New Parser

1. Add entry to `lua/nvim-treesitter/parsers.lua`
2. If parser name differs from Vim filetype, add mapping in `plugin/filetypes.lua`
3. Run `make docs` to update SUPPORTED_LANGUAGES.md
4. Add query files in `runtime/queries/<language>/`
5. Test with `:TSInstall <lang>` and `:TSInstallFromGrammar <lang>`

## Style

- Lua: 2-space indent, 100 column width, single quotes, always use call parentheses (enforced by stylua)
- Queries: formatted/validated by `ts_query_ls`
- All files: Unix line endings, UTF-8
