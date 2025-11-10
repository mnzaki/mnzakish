#!/bin/bash -
#===============================================================================
#
#          FILE: categorization.sh
#
#         USAGE: ./categorization.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki <mnzaki@gmail.com>
#  ORGANIZATION:
#       CREATED: 04.10.2021 16:57:27
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

PKB_TAGS_BASE="$HOME/pkb/tags"

#### Internal Functions
#

_msh_get_file_key () {
  # inodes change a lot because editors (vim) remove and add files
  # stat --printf %i -L "$1"
  local p="$(realpath "$1")"
  echo "${p//\//}"
}

let _msh_should_unset_glob=0
_globstar_maybe_old () {
  if (( _msh_should_unset_glob == 1 )); then
      shopt -u globstar
      _upvars -v _msh_should_unset_glob 0
  else
    if shopt -q globstar; then
      _upvars -v _msh_should_unset_glob 0
    else
      shopt -s globstar
      _upvars -v _msh_should_unset_glob 1
    fi
  fi
}
_globstar_maybe () {
  if (( _msh_should_unset_glob == 1 )); then
    shopt -u globstar
    _upvars -v _msh_should_unset_glob 0
  elif ! shopt -q globstar; then
    shopt -s globstar nullglob
    _upvars -v _msh_should_unset_glob 1
  fi
}

_in_tag_base () {
  _globstar_maybe
  pushd "$PKB_TAGS_BASE" &>/dev/null
}

_out_tag_base () {
  _globstar_maybe
  popd &>/dev/null
}

_taglsinode () {
  for t in **/"$1"; do
    echo "${t%%/$1}"
    #echo ${t%%"/$1"}
  done
}


#### External Functions
# These should manage cwd and globstar

function lstagsfull {
  echo "$PKB_TAGS_BASE/**/"
}

function lstags {
  _in_tag_base
    echo **/
  _out_tag_base
}

# list all tags a file is tagged with
tagls () {
  local file_name="${1-.}"
  local file_inodes=($(_msh_get_file_key "$file_name"))

  pushd . &>/dev/null
    if ! [ -d "$file_name" ]; then
      file_inodes+=($(_msh_get_file_key .))
    fi; while [ `pwd` != '/' ]; do
      cd ..
      file_inodes+=($(_msh_get_file_key .))
    done
  popd &>/dev/null

  _in_tag_base
    local f_inode
    for f_inode in ${file_inodes[@]}; do
      _taglsinode $f_inode
    done
  _out_tag_base
}

# $ tag FILE tag1 tag2 tag3
function tag {
  local FILE_NAME="$(realpath "$1")"
  shift
  local FILE_INODE=$(_msh_get_file_key "$FILE_NAME")

  _in_tag_base
    for t in "$@"; do
      ## TODO check tag exists
      ln -s $FILE_NAME "${t}/${FILE_INODE}"
    done
  _out_tag_base
}

function tagrm {
  local FILE_NAME="$(realpath "$1")"
  shift
  local FILE_INODE=$(_msh_get_file_key "$FILE_NAME")

  _in_tag_base
    for t in "$@"; do
      ## TODO check tag exists
      rm -f "${t}/${FILE_INODE}"
    done
  _out_tag_base
}


function tagged {
  local file_list local file_list_tag
  local t

  _in_tag_base
    for t in "$@"; do
      pushd "$t" &>/dev/null
      local cur_file_list=(**)
      popd &>/dev/null

      if ! [ -v file_list ]; then
        declare -n file_list=cur_file_list
        declare -n file_list_tag=t
      elif [ ${#cur_file_list[@]} -lt ${#file_list[@]} ]; then
        declare -n file_list=cur_file_list
        declare -n file_list_tag=t
      fi
    done

    # TODO is this expensive? use a for index loop?
    for f in "${file_list[@]}"; do
      let intersects=1
      for t in "$@"; do
        if ! [ -f "${t}/${f}" ]; then
          let intersects=0
          break
        fi
      done
      if [ $intersects -eq 1 ]; then
        realpath "$file_list_tag/$f"
      fi
    done
  _out_tag_base
}


### Completion
#

_comp_tag () {
    pushd "$PKB_TAGS_BASE" &>/dev/null
    _globstar_maybe

    # $2 is the word being completed
    local cur=$2

    # Loop over all files and directories in the current and all subdirectories
    local fname
    for fname in "$cur"*/**; do
        # Only add dirs
        if [[ -d "$fname" ]]; then
            COMPREPLY+=("$fname")
        fi
    done

    popd &>/dev/null
    _globstar_maybe

    return 0
}

_comp_file_tag () {
  # TODO
    pushd "$PKB_TAGS_BASE" &>/dev/null
    _globstar_maybe

    # $2 is the word being completed
    local cur=$2

    # Loop over all files and directories in the current and all subdirectories
    local fname
    for fname in "$cur"*/**; do
        # Only add dirs
        if [[ -d "$fname" ]]; then
            COMPREPLY+=("$fname")
        fi
    done

    popd &>/dev/null
    _globstar_maybe

    return 0
}


function _tag_completion {
  _get_comp_words_by_ref cur prev
  case $COMP_CWORD in
    1) COMPREPLY=($(compgen -f -d -- "$cur"))
      ;;
    *)
      _comp_tag "$1" "$2" "$3"
      ;;
  esac
}

function _tag_rm_completion {
  _get_comp_words_by_ref cur prev
  case $COMP_CWORD in
    1) COMPREPLY=($(compgen -f -d -- "$cur"))
      ;;
    *)
      _comp_file_tag "$1" "$2" "$3"
      ;;
  esac
}

complete -F _tag_completion tag
complete -F _tag_rm_completion tagged
complete -F _comp_tag tagged
#listtags
