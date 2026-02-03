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
alias open='xdg-open'
#alias ns="nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history"

if [[ "$(uname)" == "Darwin" ]]; then
    alias vo='cd "$HOME/Google Drive/My Drive/Vault" && nvim -c "set ft=markdown" -c "Obsidian today"'
else
    alias vo='cd "$HOME/gdrive/Vault" && nvim -c "set ft=markdown" -c "Obsidian today"'
fi
