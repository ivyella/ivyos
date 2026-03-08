# Only run these in interactive shells
if status is-interactive
    # Aliases
    alias ls='eza --icons'
    alias syncdots='stow -R'
    alias fetch='fastfetch'
end

set -g fish_greeting ""

# Starship
if type -q starship
    eval (starship init fish)
end
