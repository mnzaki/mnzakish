BASE="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" &> /dev/null && pwd )"

source "$BASE/concentration.sh"
source "$BASE/intention.sh"
# source "$BASE/categorization.sh"

source "$BASE/vendor/complete-alias/complete_alias"

export PATH="$BASE/bin:$PATH"

nodebin () {
  export PATH="$PATH:`yarn bin`"
}
