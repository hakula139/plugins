#!/usr/bin/env nu

# ==================================================================================================
# Skill Check
# ==================================================================================================
# Checks what installers rely on: each `SKILL.md` names its directory and has a description within
# the Agent Skills limit, skill names are unique across plugins, and the marketplace entries, the
# `plugins/` directories, and each `plugin.json` name the same plugins.
# ==================================================================================================

const MAX_DESCRIPTION = 1024

def directories [dir: path]: nothing -> list<string> {
  ls --full-paths $dir
  | where type == dir
  | get name
  | path basename
  | sort
}

# The `SKILL.md` frontmatter as a record, or the reason it cannot be read.
def frontmatter [file: path]: nothing -> record {
  let lines = (open --raw $file | into string | lines)
  let end = ($lines | skip 1 | enumerate | where item == "---" | first)
  if ($lines | first) != "---" or $end == null {
    return {error: "no YAML frontmatter"}
  }
  let meta = try {
    $lines | skip 1 | first $end.index | str join "\n" | from yaml
  } catch {|err|
    return {error: $err.rendered}
  }
  if not ($meta | describe | str starts-with "record") {
    return {error: "frontmatter is not a mapping"}
  }
  {meta: $meta}
}

def skill-errors [skill: path]: nothing -> list<string> {
  let file = ($skill | path join "SKILL.md")
  if not ($file | path exists) {
    return [$"($skill): no SKILL.md"]
  }
  let parsed = (frontmatter $file)
  if "error" in $parsed {
    return [$"($file): ($parsed.error)"]
  }

  let name = ($skill | path basename)
  let description = $parsed.meta.description?
  [
    (if $parsed.meta.name? != $name {
      $"($file): name ($parsed.meta.name? | to nuon) differs from its directory ($name)"
    })
    (if ($description | describe) != "string" or ($description | str trim | is-empty) {
      $"($file): description is missing"
    } else if ($description | str length --chars) > $MAX_DESCRIPTION {
      $"($file): description is longer than ($MAX_DESCRIPTION) characters"
    })
  ]
  | compact
}

def plugin-errors [root: path, entry: record]: nothing -> list<string> {
  let source = $"./plugins/($entry.name)"
  let manifest = ($root | path join "plugins" $entry.name ".claude-plugin" "plugin.json")
  [
    (if $entry.source != $source {
      $"marketplace.json: ($entry.name) has source ($entry.source | to nuon), expected ($source)"
    })
    (if not ($manifest | path exists) {
      $"($manifest): missing"
    } else if (open $manifest).name? != $entry.name {
      $"($manifest): name differs from its marketplace entry ($entry.name)"
    })
  ]
  | compact
}

# Check the marketplace and skills under `root`, printing every error and exiting nonzero on any.
def main [
  root: path # Repository root holding `.claude-plugin/` and `plugins/`
] {
  let entries = (open ($root | path join ".claude-plugin/marketplace.json")).plugins
  let plugins = (directories ($root | path join "plugins"))
  let named = ($entries | get name | sort)
  let skill_dirs = ($plugins | each {|plugin| $root | path join "plugins" $plugin "skills" })
  let skills = (
    $skill_dirs
    | where {|dir| $dir | path exists }
    | each {|dir| directories $dir | each {|name| {name: $name, path: ($dir | path join $name)} } }
    | flatten
  )

  let errors = [
    (if $named != $plugins {
      [$"marketplace.json: entries ($named | to nuon) differ from plugins/ ($plugins | to nuon)"]
    })
    ($skill_dirs | where {|dir| not ($dir | path exists) } | each {|dir| $"($dir): missing" })
    ($entries | each {|entry| plugin-errors $root $entry } | flatten)
    ($skills | each {|skill| skill-errors $skill.path } | flatten)
    (
      $skills
      | group-by name
      | items {|name, group| if ($group | length) > 1 { $"skill ($name) is in several plugins" } }
      | compact
    )
  ]
  | compact
  | flatten

  for error in $errors { print -e $error }
  if ($errors | is-not-empty) {
    exit 1
  }
  print $"($skills | length) skills in ($plugins | length) plugins passed"
}
