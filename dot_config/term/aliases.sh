alias cmake_deb='cmake $@ -GNinja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=DEBUG'
alias cmake_rel='cmake $@ -GNinja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE'
alias cmake_gcc='cmake $@ -GNinja -DCMAKE_CXX_COMPILER=g++ -DCMAKE_C_COMPILER=gcc'
alias cmake_clang='CXXFLAGS="-I$LIBCPP_DIR" cmake $@ -GNinja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++'
alias cmake_clean='rm -rf CMakeCache.txt CMakeFiles' 
alias l='ls -lahG'
alias ls='ls -G'
alias n='ninja'
alias p='python'
alias pytest='python -m pytest'
alias pdb='python -u -m pdb -c continue'
alias pdflatex='pdflatex -interaction=nonstopmode -file-line-error -halt-on-error'
alias v='nvim'
alias vc='cd $HOME/.config && nvim .'
alias tn='tmux new -s zen'
alias ta='tmux attach -t zen'
alias cuda-select='export CUDA_VISIBLE_DEVICES=$(nvidia-smi --query-gpu=memory.free,index --format=csv,nounits,noheader | sort -nr | head -1 | awk "{ print \$NF }")'
alias hud='MTL_HUD_ENABLED=1'
alias hud-log='MTL_HUD_ENABLED=1 MTL_HUD_LOG_ENABLED=1 MTL_HUD_LOG_SHADER_ENABLED=1'
alias y='yazi'
#alias ns="nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history"

if [[ "$(uname)" == "Darwin" ]]; then
    alias vo='cd "$HOME/Proton/Vault" && nvim -c "set ft=markdown" -c "Obsidian today"'
    alias htop=macmon
else
    alias vo='cd "$HOME/gdrive/Vault" && nvim -c "set ft=markdown" -c "Obsidian today"'
    alias open='xdg-open'
fi

vpn() {
  local password totp_code
  password=$(pass-cli item view --vault-name Personal --item-title "TU Darmstadt" --field password)
  totp_code=$(pass-cli item totp --vault-name Personal --item-title "TU Darmstadt" --output human | awk '/^totp:/{print $2}')
  printf '%s\n%s\n' "$password" "$totp_code" | sudo openconnect vpn.hrz.tu-darmstadt.de \
    --user=bb77suko \
    --authgroup=extern \
    --useragent=AnyConnect \
    --no-external-auth \
    --passwd-on-stdin
}

ff() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)

# ripgrep->fzf->vim [QUERY]
rfv() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            nvim {1} +{2}     # No selection. Open the current line in Vim.
          else
            nvim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)
