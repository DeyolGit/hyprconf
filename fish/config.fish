oh-my-posh init fish --config $HOME/.poshthemes/agnoster.omp.json | source
set -g fish_greeting ""
fastfetch --logo Arch
if status is-interactive
    # Commands to run in interactive sessions can go here
end
