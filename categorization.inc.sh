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

PKB_META_BASE="$HOME/pkb/meta"
# The $PKB_META_BASE directory contains all data about tags, file hashes, and
# file paths

HASH_FN="sha256"
# This is the hash function used to hash files for content identification
# Current options: sha256

################################################################################
# Below this line should generally not need configuration
################################################################################

PKB_TAGS_BASE="$PKB_META_BASE/tags"
# Tags are stored as nested directories under the $PKB_TAGS_BASE root

PKB_HASHES_BASE="$PKB_META_BASE/hashes"
# A hash of a specific file can be cached as the content of a file called
# `_hash` as $PKB_HASHES_BASE/$FULL_FILE_PATH/_hash

PKB_HASHES_PATHS_BASE="$PKB_META_BASE/paths"
# All known paths of a certain hash are stored as contents of a file named by
# the `$PKB_HASHES_PATHS/$HASH_FN-$hash` template

#### Internal Functions

# File keys
# Each file is identified by a key
# If the ID function is content-based then the storage can be content-addressed.
# The current ID method is file content hashing (sha256 by defaul)
# and the hashes are cached in the $PKB_HASHES_BASE and $PKB_HASHES_PATHS_BASE
# directories

# Other options
# Using inodes
# inodes change a lot because editors (vim) remove and add files
# _msh_get_file_key () {
#   stat --printf %i -L "${1-}"
# }

# Using realpath without forward slashes
# can cause conflicts, and unreliable because of moves
# _msh_get_file_key () {
#   local p="$(realpath "${1-}")"
#   echo "${p//\//}"
# }


_msh_get_file_key() {
  local full_path="$(realpath "${1-}")"
  local p="$PKB_HASHES_BASE${1-}/_hash"
  local hash_val
  if [ -e "$p" ]; then
    hash_val=$(cat "$p")
  else
    hash_val=$(_msh_compute_file_key "$full_path")
    mkdir -p "$(dirname "$p")" &> /dev/null
    # TODO split hash_val into several parts and mkdir -p
    # to alleviate file system pressure
    echo -n $hash_val > "$p"
  fi
  echo -n $hash_val
}

_msh_get_file_key_paths_file() {
  echo -n "$PKB_HASHES_PATHS_BASE/${1-}"
}

_msh_get_file_key_paths() {
  local paths_file="$(_msh_get_file_key_paths_file "${1-}")"
  cat $paths_file 2>/dev/null
}

_msh_compute_file_key() {
  local hash_val
  case "$HASH_FN" in
    sha256)
      local hash_out=($(sha256sum "${1-}"))
      hash_val=${hash_out[0]}
      ;;
  esac

  echo -n "$HASH_FN-$hash_val"
}

_msh_ensure_file_key_uptodate () {
  local f_key="${1-}" f_path="${2-}"
  # TODO
  # - if hash has tags, it should rehash the file to ensure freshness of hash
  # - and fix up the caches if needed
}


_msh_ensure_file_key_paths_uptodate () {
  local f_key="${1-}" f_path="${2-}"
  local f_paths_file="$(_msh_get_file_key_paths_file $f_key)"
  if [ ! -e "$f_paths_file" ]; then
    touch "$f_paths_file"
  fi
  if ! grep -q $f_path "$f_paths_file"; then
    ( cat $f_paths_file; echo $f_path ) | sort > "$f_paths_file"
  fi
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
    _upvars -v _msh_should_unset_glob 0 &> /dev/null
  elif ! shopt -q globstar; then
    shopt -s globstar nullglob
    _upvars -v _msh_should_unset_glob 1 &> /dev/null
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
  if [ "${#@}" -gt 1 ]; then
    local f_name
    for f_name in "$@"; do
      tagls "$f_name"
    done
    return 0
  fi

  local file_name="$(realpath "${1:-.}")"
  local file_keys=($(_msh_get_file_key "$file_name"))
  _msh_ensure_file_key_paths_uptodate "${file_keys[0]}" "$file_name"
  _msh_ensure_file_key_uptodate "${file_keys[0]}" "$file_name"

  # TODO
  # - list_tags_for_path $path
  #   - check $hash = hashes[$path]:
  #   - if exists
  #     - check validity (date modified)
  #       - if invalid
  #         - $hash = compute_hash
  #         - update_hash_cache $hash $path
  #   - if does not exist
  #     - $hash = compute_hash $path
  #     - update_hash_cache $hash $path
  #   - list_tags_for_hash $hash

  # - update_hash_cache $hash $path:
  #   - check path = paths[$hash]
  #     - if path not empty and path != $path
  #       - if file at path
  #         - hash2 = compute_hash path
  #         - paths[hash2] = path
  #         - hashes[path] = hash2
  #     - paths[$hash] = $path
  #   - check hash = hashes[$path]
  #     - if hash not empty and hash != $hash
  #         - if file at path = paths[$hash]
  #           - hash2 = compute_hash path
  #           - paths[hash2] = paths[$hash]
  #           - hashes[path] = hash2
  #       - tags[$hash] += tags[hash]
  #       - tags[hash]
  #     - hashes[$path] = $hash

  # not needed as can't tag dirs right now
  # pushd . &>/dev/null
  #   if ! [ -d "$file_name" ]; then
  #     file_keys+=($(_msh_get_file_key .))
  #   fi; while [ `pwd` != '/' ]; do
  #     cd ..
  #     file_keys+=($(_msh_get_file_key .))
  #   done
  # popd &>/dev/null

  _in_tag_base
    local f_key
    for f_key in ${file_keys[@]}; do
      local ts=(**/"$f_key")
      if [ ${#ts} -eq 0 ]; then
        continue
      fi
      echo -n "${1-} "
      for t in "${ts[@]}"; do
        echo -n "${t%%/$f_key} "
        #echo ${t%%"/${1-}"}
      done
      echo
    done
  _out_tag_base
}

# $ tag FILE tag1 tag2 tag3
function tag {
  local FILE_NAME="$(realpath "${1-}")"
  shift
  local FILE_KEY=$(_msh_get_file_key "$FILE_NAME")

  _in_tag_base
    for t in "$@"; do
      if [ ! -d "$t" ]; then
        mkdir -p "$t" &>/dev/null
      fi
      ln -sf "$FILE_NAME" "${t}/${FILE_KEY}"
    done
  _out_tag_base
}

function tagrm {
  local FILE_NAME="$(realpath "${1-}")"
  shift
  local FILE_KEY=$(_msh_get_file_key "$FILE_NAME")

  _in_tag_base
    for t in "$@"; do
      ## TODO check tag exists
      rm -f "${t}/${FILE_KEY}"
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

_msh_comp_tag () {
  _in_tag_base
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

  _out_tag_base
  return 0
}

_msh_comp_file_tag () {
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


function _msh_tag_completion {
  _get_comp_words_by_ref cur prev
  case $COMP_CWORD in
    1) COMPREPLY=($(compgen -f -d -- "$cur"))
      ;;
    *)
      _msh_comp_tag "${1-}" "${2-}" "${3-}"
      ;;
  esac
}

function _msh_tag_rm_completion {
  _get_comp_words_by_ref cur prev
  case $COMP_CWORD in
    1) COMPREPLY=($(compgen -f -d -- "$cur"))
      ;;
    *)
      _comp_file_tag "${1-}" "${2-}" "${3-}"
      ;;
  esac
}

complete -F _msh_tag_completion tag
complete -F _msh_tag_rm_completion tagged
complete -F _msh_comp_tag tagged

if [ ! "${1-}" ]; then
  $@
fi
