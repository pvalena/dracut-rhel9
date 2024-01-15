#!/usr/bin/zsh
#
# ./fix.sh [options] RHEL_VERSION BUG_NR DRACUT_PR [COMMIT_COUNT]
#

set -xe
zsh -n "$0"

: "OPT: Continue after solving cherry-pick conflict"
[[ "$1" == "-c" ]] && {
  {
    shift ||:
  } 2>/dev/null
  CON=y
  :
} || CON=

: 'RHEL version #'
rv="${1}"
{
  [[ -n "$rv" ]]
  shift
} 2>/dev/null

: 'Jira issue #'
bn="${1}"
{
  [[ -n "$bn" ]]
  shift ||:
} 2>/dev/null

: 'Dracut pull request # (on dracutdevs/dracut)'
pr="${1}"
{
  [[ -n "$pr" ]]
  shift ||:
} 2>/dev/null

: 'Commit count (default: 1)'
cc="${1:-1}"
{
  [[ -n "$cc" ]]
  shift ||:
} 2>/dev/null

{
  [[ -z "$1" ]]
} 2>/dev/null

{ echo ; } 2>/dev/null

remote="plumbers-${rv}"
fork="rhel-${rv}"

[[ -z "$CON" ]] && {
  read '?continue?'

  gitf "${remote}"

  gitcb "rhel-${rv}-fix-${bn}"

  gitt
  gitrh "${remote}/main"

  gitf origin "refs/pull/$pr/head:pr$pr"
}

: "List Commits"
cis="$(gitl1 "pr$pr" "-${cc}" --reverse | cut -d' ' -f1)"
[[ -n "$cis" ]]

com=''
[[ ${cc} -gt 1 ]] && com="${com}\n(Cherry-picked commits:"

echo "$cis" \
| while read ci; do
    [[ -n "$ci" ]] || continue

    [[ -z "$CON" ]] && gity "${ci}"

    [[ ${cc} -gt 1 ]] \
      && com="${com}\n  ${ci}" \
      || com="${com}\n(Cherry-picked commit: ${ci})\n"

  done

[[ ${cc} -gt 1 ]] && com="${com})\n"

com="${com}\nResolves: RHEL-${bn}\n"


[[ ${cc} -gt 1 ]] && gitei HEAD~${cc}

echo -e "$com"
read '?continue?'

[[ -z "$CON" ]] && {
  gitia --amend
  :
} || {
  gits | grep -q '^\s*both modified: ' \
    && gita `gits | grep '^\s*both modified: ' | tr -s ' ' | cut -d' ' -f3`

  gityc
}

gith

gituu "${fork}"

gh pr create -f -l bug -a '@me' -R "redhat-plumbers/dracut-rhel${rv}"
