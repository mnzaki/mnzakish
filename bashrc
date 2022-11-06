MSH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source "$MSH_DIR/lib/init.sh"
source "$MSH_DIR/lib/color.sh"
source "$MSH_DIR/concentration.sh"
source "$MSH_DIR/intention.sh"
source "$MSH_DIR/navigation.sh"
source "$MSH_DIR/categorization.sh"

export PATH="$MSH_DIR/bin:$PATH"

nodebin () {
  export PATH="$PATH:$(yarn bin)"
}
