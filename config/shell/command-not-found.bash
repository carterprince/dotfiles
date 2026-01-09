command_not_found_handle () {
  local pkgs cmd=$1
  local FUNCNEST=10

  set +o verbose

  mapfile -t pkgs < <(pkgfile -bv -- "$cmd" 2>/dev/null)

  # 1. If no packages found, exit early
  if (( ${#pkgs[*]} == 0 )); then
    printf "bash: %s: command not found\n" "$cmd" >&2
    return 127
  fi

  # 2. Print the found packages (Always happens first now)
  printf "'%s' may be found in the following packages:\n" "$cmd"
  for line in "${pkgs[@]}"; do
      read -r pkg_full version path <<< "$line"
      
      repo=${pkg_full%%/*}
      name=${pkg_full#*/}

      printf '  \e[1;35m%s/\e[0m\e[1m%s\e[0m \e[1;32m%s\e[0m %s\n' "$repo" "$name" "$version" "$path"
  done

  # 3. Prompt for installation with Color
  if [[ ${#pkgs[*]} -eq 1 && -n $PKGFILE_PROMPT_INSTALL_MISSING ]]; then
    # Extract the full package string "repo/name"
    local pkg_full=${pkgs[0]%% *}
    
    # Split it again for the prompt colors
    local repo=${pkg_full%%/*}
    local name=${pkg_full#*/}
    local response

    # Use printf for the colored prompt, then read input
    printf 'Install \e[1;35m%s/\e[0m\e[1m%s\e[0m? [Y/n] ' "$repo" "$name"
    read -r response

    if [[ -z $response || $response = [Yy] ]]; then
        printf '\n'
        sudo pacman -S --noconfirm -- "$pkg_full"
        return 0
    fi
  fi

  return 127
}
