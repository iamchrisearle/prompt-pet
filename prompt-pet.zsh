# --- Prompt Pet Configuration (Zsh) ---

# Enable dynamic variable substitution in the PROMPT
setopt PROMPT_SUBST

# State Variables
# These track the "mood" of the prompt.
PROMPT_PET_FAILURE_COUNT=0
PROMPT_PET_DEFAULT_FACE="●‿●"
PROMPT_PET_HAD_FAILURE_STREAK=0
# This is the variable the prompt will actually display.
PROMPT_PET_CURRENT_FACE="●‿●"

# 'prompt-pet' command function
# This function lets users change the default face.
prompt-pet() {
    case "$1" in
        cat)
            PROMPT_PET_DEFAULT_FACE="=^..^="
            echo "Default face set to =^..^="
            ;;
        dog)
            PROMPT_PET_DEFAULT_FACE="ˁ˚ᴥ˚ˀ"
            echo "Default face set to ˁ˚ᴥ˚ˀ"
            ;;
        default)
            PROMPT_PET_DEFAULT_FACE="●‿●"
            echo "Default face set to ●‿●"
            ;;
        *)
            echo "Usage: prompt-pet <cat|dog|default>"
            return 1 # Zsh functions can return a non-zero status
            ;;
    esac
}

# Pre-command hook function
# This function runs just before the prompt is displayed.
_update_prompt_pet_face() {
    # Grab the exit status of the last command immediately.
    local last_status=$?

    if [[ $last_status -eq 0 ]]; then
        # --- Command Succeeded ---
        
        if [[ $PROMPT_PET_HAD_FAILURE_STREAK -eq 1 ]]; then
            # First success after a failure streak
            PROMPT_PET_CURRENT_FACE="ᕙ(⇀‸↼‶)ᕗ"
            # Reset streak flag
            PROMPT_PET_HAD_FAILURE_STREAK=0
        else
            # Normal success, or 2nd success after a streak
            PROMPT_PET_CURRENT_FACE="$PROMPT_PET_DEFAULT_FACE"
        fi
        # Reset failure count on any success
        PROMPT_PET_FAILURE_COUNT=0
    else
        # --- Command Failed ---
        
        # Check for specific exit codes
        case $last_status in
            126) # "Command invoked cannot execute"
                PROMPT_PET_CURRENT_FACE="ʕಠᴥಠʔ ಠ_ಠ ᶘಠᴥಠᶅ"
                PROMPT_PET_FAILURE_COUNT=0 
                PROMPT_PET_HAD_FAILURE_STREAK=0 
                ;;
            137) # 128 + 9 (SIGKILL / OOM Killer)
                PROMPT_PET_CURRENT_FACE="[¬º-°]¬"
                PROMPT_PET_FAILURE_COUNT=0 
                PROMPT_PET_HAD_FAILURE_STREAK=0
                ;;
            *) # --- All Other General Failures ---
               PROMPT_PET_FAILURE_COUNT=$((PROMPT_PET_FAILURE_COUNT + 1))
               PROMPT_PET_HAD_FAILURE_STREAK=1

               case $PROMPT_PET_FAILURE_COUNT in
                   1)  PROMPT_PET_CURRENT_FACE="( ಠ◡ಠ )" ;;
                   2)  PROMPT_PET_CURRENT_FACE="(>‘o’)>" ;;
                   3)  PROMPT_PET_CURRENT_FACE="(⋟﹏⋞)" ;;
                   4)  PROMPT_PET_CURRENT_FACE="ლ( \`Д’ ლ)" ;;
                   5|6|7|8|9)
                       PROMPT_PET_CURRENT_FACE="(╯°□°)╯︵ ┻━┻" ;;
                   *) # 10 or more
                       PROMPT_PET_CURRENT_FACE="┻━┻︵ \(°□°)/ ︵ ┻━┻" ;;
               esac
               ;;
        esac
    fi
}

# Register the hook function (Idempotent Check)
# This checks if the function is already in the array before adding it.
# This prevents it from being added multiple times if you source ~/.zshrc.
if [[ ! " ${precmd_functions[@]} " =~ " _update_prompt_pet_face " ]]; then
  precmd_functions+=(_update_prompt_pet_face)
fi

# Set your Prompt
#
# IMPORTANT: You must merge this with your existing PROMPT (or PS1) variable.
# The *single quotes* ('... ') are crucial. They prevent the variable
# from being expanded *once* and instead make Zsh re-evaluate it every time.
#
# '${PROMPT_PET_CURRENT_FACE}' is the magic part that will be updated.
# '%~' shows the current directory (e.g., ~/my/project).
# '%#' shows a '%' for normal users and a '#' for root.
#
# Example (feel free to customize)
# I prefer to keep the face on the right:
# PROMPT='🚀 %~ %# '
# RPROMPT='${PROMPT_PET_CURRENT_FACE}'

# --- End Prompt Pet ---