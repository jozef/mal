# Name

mal - memory and language command-line tool

# Synopsis

    mal init
    mal add -f README.md -f lib/App/mal.pm 'scaffolding new project'
    mal prompt 'describe this software'
    mal prompt -t 0.9 -p 0.3 'describe this software'
    mal patch 'check if README.md is up to date with mal.pm'
    mal show
    mal clean
    mal config

# Description

`mal` is a command-line program to update/patch local files based on
user prompt. It operates on the current folder and its subfolders
and stores context associated with it.

## Configuration

`.mal` folder contains:

    - config.ini
    - context.md

### config.ini

Here are `config.ini` sections and configuration options:

    - general
        - llm_api: ollama
        - mapreduce_chunksize: 8192
        - auto_apply_patches: false
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

Current folder, all parent folders, and `$HOME` are scanned for a `.mal`
folder, based on information inside.

All `config.ini` files are merged and duplicates are replaced. If a value is empty,
the key is also removed when parsing.

Following rules apply for merging of `context.md` files:

    - merging begins from parent to child (ex. from `$HOME` to `.`)
    - all sections and subsections without text are removed
        - if (sub)section of sibling has text, then it is completely
      replaced
    - if (sub)section of a sibling has more (sub)subsections then they
      are either replaced or appended at the end. parent section text
      is kept

Context is summarized automatically when exceeding limits.

# Command-line syntax

Here are the subcommands and their arguments:

## init

Will create `.mal` folder and populate it with a basic context markdown
file.

On first run on the computer it will also create `.mal` in the `$HOME` folder
and notify the user that this base context file should be edited.

## add

Will add more context that will be stored for future prompts. First
argument can be a context path (ex. `/constraints/must`), otherwise
text will be added to `/context/description`

With `-f`, a file reference can be added.

## prompt

Will build current context (see section "How context is built") and
prompt the LLM to generate a response.

Options:

    - `-t` temperature
    - `-p` top_p

## patch

Will build current context (see section "How context is built") and
prompt the LLM to generate a response so that it generates unified diff
patches to files in current folder.

    - `-y` will auto apply all patches.
    - `-n` will not apply patches if auto apply on in `config.ini`


## show

Will build current context (see section "How context is built") and
print it out.

With `-v` it will also include file content, otherwise file content is
skipped.

## clean

Will take current context, built context, and prompt the LLM to consolidate
the file so that only relevant information is kept. Removing duplicates
or inconsistencies.

## config

Will show configuration as merged from all `config.ini` files.

With `-v` will add file reference in front of all Text blocks to indicate
where does the information comes from.
