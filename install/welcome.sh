#!/usr/bin/env zsh
# Inline welcome display — no Python, no dependencies needed.

RESET=$'\x1b[0m'
BOLD=$'\x1b[1m'
WHITE=$'\x1b[97m'
CYAN=$'\x1b[96m'

# アートの幅をランタイムで計測してセンタリング
ART_LINE="██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
ART_WIDTH=$(( ${#ART_LINE} + 2 ))  # +2 はインデントの空白

center() {
  local text="$1"
  local len=${#text}
  local pad=$(( (ART_WIDTH - len) / 2 ))
  printf "%${pad}s${BOLD}${CYAN}%s${RESET}\n" "" "$text"
}

printf "\n"
printf "  ${BOLD}${WHITE}${ART_LINE}${RESET}\n"
printf "  ${BOLD}${WHITE}██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝${RESET}\n"
printf "  ${BOLD}${WHITE}██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗${RESET}\n"
printf "  ${BOLD}${WHITE}██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║${RESET}\n"
printf "  ${BOLD}${WHITE}██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║${RESET}\n"
printf "  ${BOLD}${WHITE}╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝${RESET}\n"
printf "\n"
center "Setup complete."
center "Open a new terminal window to bring everything to life."
printf "\n"
