# Name

mal - memory and language command-line tool

# Synopsis

    mal init
    mal add -f README.md -f lib/App/mal.pm 'scaffolding new project'
    mal prompt 'describe this software'
    mal prompt -t 0.9 -p 0.3 'describe this software'
    mal patch 'check if README.md is up to date with mal.pm'
    mal explain README.md
    mal test
    mal proofread README.md
    mal todo
    mal show
    mal clean
    mal config

# Description

`mal` is a command-line program to update or patch local files based on
a user prompt. It operates on the current folder and its subfolders
and stores context associated with them.

The tool builds structured prompts from Markdown context files and
executes LLM-assisted actions such as explaining code, generating patches,
testing programs, or proofreading documentation.

# Configuration

`.mal` folder contains:

    - config.ini
    - context.md

### config.ini

Here are `config.ini` sections and configuration options:

    - general
        - llm_api: ollama
        - mapreduce_chunksize: 8192
        - auto_apply_patches: false
        - chat_history_days: 30
    - ollama
        - url: http://localhost:8080/v1
        - model: gemma3n:e2b

### context.md

Here are the `context.md` sections and subsections:

    - roles
        - assistant
        - user
    - goal
        - todo
        - non-goals
    - task
        - long-term
        - current
    - context
        - description
        - domain
        - date-and-time
    - timeline
    - input
        - overview
        - important-files
    - constraints
        - must
        - must-not
        - should
        - should-not
        - recommended
        - not-recommended
        - may
    - output
        - style
        - format
    - examples
        - good
        - bad
    - evaluation
        - tests

## How context is built

The current folder, all parent folders, and `$HOME` are scanned for a `.mal`
folder, based on the information inside them.

All `config.ini` files are merged and duplicate values are replaced. If a value is empty,
the key is removed during parsing.

The following rules apply when merging `context.md` files:

    - merging begins from parent to child (e.g. from `$HOME` to `.`)
    - all sections and subsections without text are removed
        - if a (sub)section of a sibling has text, it is completely replaced
    - if a (sub)section of a sibling has additional (sub)subsections, they
      are either replaced or appended at the end; the parent section text
      is kept

The context is summarized automatically when exceeding limits.

# Command Context Files

Each subcommand may have its own prompt template stored as Markdown.

Examples:

    explain.md
    patch.md
    test.md
    proofread.md
    todo.md

These files define how the LLM should behave for a specific command.

When a command is executed, the prompt is constructed from:

1. global `context.md`
2. parent folder contexts
3. command-specific context file (e.g. `explain.md`)
4. timeline entries
5. user prompt
6. current date and time

Example prompt hierarchy:

    $HOME/.mal/context.md
    project/.mal/context.md
    project/.mal/explain.md
    user prompt

This allows commands to specialize behaviour without modifying the
global prompt context.

Each subcommand can pre-process the prompt and post-process the response.

# Command Permissions

Some commands may execute local tools in order to collect information.

For security reasons, every command has a list of **allowed CLI tools**.

Example configuration:

    [commands.explain]
    allowed_tools = grep, rg

    [commands.test]
    allowed_tools = perl, make, prove

    [commands.todo]
    allowed_tools = grep

Example behaviour:

`mal explain`

May execute:

    grep -r something .

to search the code base.

`mal test`

May run tests or programs in order to analyse output.

This design prevents arbitrary shell execution by the LLM.

# Safety Model

`mal` will only modify files that are explicitly part of the working
directory and that were provided as context.

Recommended restrictions:

    - only modify files inside the current project
    - auto-patching only when the current project is a git repository
    - prefer patch-based changes (unified diff)

All changes should be shown as patches unless explicitly auto-applied.

# Command-line syntax

Here are the subcommands and their arguments:

## init

Creates a `.mal` folder and populates it with a basic context Markdown
file.

On the first run on a computer it will also create `.mal` in the `$HOME` folder
and notify the user that this base context file should be edited.

## add

Adds more context that will be stored for future prompts.

Each entry is automatically timestamped with the current date and time
and appended to `timeline.md`.

Example:

    mal add 'initial project scaffolding'

Result in timeline:

    2026-03-15 10:21 initial project scaffolding

## prompt

Builds the current context (see section "How context is built") and
prompts the LLM to generate a response.

Options:

    - `-t` temperature
    - `-p` top_p

## patch

Builds the current context (see section "How context is built") and
prompts the LLM to generate a response that produces unified diff
patches for files in the current folder.

    - `-y` will auto-apply all patches
    - `-n` will not apply patches even if auto-apply is enabled in `config.ini`

## explain

Explains files or code inside the current project.

Typical behaviour:

    - search the repository using tools like `grep`
    - collect relevant files
    - generate a technical explanation

Example:

    mal explain lib/App/mal.pm

## test

Runs project tests and lets the LLM analyse the results.

Typical workflow:

    1. run test command (e.g. `prove`, `make test`)
    2. capture output
    3. ask the LLM to interpret failures
    4. optionally propose patches

Example:

    mal test

## proofread

Reads documentation or source files and improves:

    - grammar
    - wording
    - readability
    - documentation clarity

The command generates patches that fix spelling, wording, and
documentation inconsistencies.

Example:

    mal proofread README.md

## todo

Maintains a project TODO list.

Workflow:

    1. read `todo.md` in the project root
    2. search the repository for markers:

        TODO
        FIXME

    3. update the TODO list
    4. mark completed tasks

Completed tasks will be checked off so the user can review history.

Example:

    mal todo

## show

Builds the current context (see section "How context is built") and
prints it.

With `-v` it will also include file content; otherwise file content is
skipped.

## clean

Takes the current context, the built context, and prompts the LLM to consolidate
the file so that only relevant information is kept, removing duplicates
or inconsistencies.

It will also delete old conversation history older than `general.chat_history_days`.

## config

Shows configuration as merged from all `config.ini` files.

With `-v` it will add file references in front of all text blocks to indicate
where the information comes from.

# Design Goals

    - structured prompting via Markdown
    - hierarchical context inheritance
    - command-specific prompting
    - safe interaction with local files
    - LLM-assisted file management
