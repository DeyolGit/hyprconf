oh-my-posh init fish --config $HOME/.config/fish/completions/amro.omp.json | source
set -g fish_greeting ""
fastfetch --logo-type kitty-direct --logo ~/tux.png --logo-width 33 --logo-height 15
if status is-interactive
    # Commands to run in interactive sessions can go here
end
