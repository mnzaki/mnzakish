source /usr/share/mnzakish/lib/init.sh
source "$MSH_DIR/concentration.sh"
source "$MSH_DIR/intention.sh"
#source "$MSH_DIR/categorization.sh"

export PATH="$MSH_DIR/bin:$PATH"

nodebin () {
  export PATH="$PATH:$(yarn bin)"
}
