if status is-interactive
    # Commands to run in interactive sessions
    alias ls 'eza --icons'
end

# Initialize Starship prompt (NixOS-friendly)
if type -q starship
    eval (starship init fish)
end
