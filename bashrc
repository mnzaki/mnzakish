# This file is meant to remain in the installation directory, and be sourced
# from ~/.bashrc either directly or via `msh bashrc`
export MSH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
export PATH="$MSH_DIR/bin:$PATH"

source "$MSH_DIR/lib/init.inc.sh"
source "$MSH_DIR/lib/color.inc.sh"
source "$MSH_DIR/concentration.inc.sh"
source "$MSH_DIR/intention.inc.sh"
source "$MSH_DIR/navigation.inc.sh"
source "$MSH_DIR/categorization.inc.sh"


nodebin () {
  export PATH="$PATH:$(yarn bin)"
}
