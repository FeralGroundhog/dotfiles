# .bash_aliases

# Navigation
alias ..='cd ..'
alias ...='cd ../../'

# Overload
alias cp='cp -i'
alias mkdir='mkdir -pv'
alias mv='mv -i'
alias vi='nvim'
alias vim='nvim'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -lGFh'

# Sorted Size
alias ss='du -cks ./* | sort -rn'

# GPG 
alias decrypt='gpg -d'
#alias encrypt='gpg -e -u "tony@pulickal.net" -r "tony@pulickal.net"
vimdecrypt() { gpg -d "$1" | vim - -n -i "NONE" "+set filetype=$2"; }
alias vimd="vimdecrypt"

# Add an "alert" alias for long running commands.  Use like so:
# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Hostname to SSH Alias
alias machine_list="cat ~/.ssh/config | egrep '^Host' | grep -v '\*' | cut -d ' ' -f 2"
SSH=ssh
for MACHINE in `machine_list`
do
    alias $MACHINE="$SSH $MACHINE"
done

# get external IP address
alias whatismyip='wget http://ipinfo.io/ip -qO -'
alias copymyip="echo $(whatismyip) | pbcopy"

#
# get fingerprint for all keys in an authorized_keys file
fingerprint_keys() {
  if (( $# != 1 )); then
    echo "Usage: ${FUNCNAME} <authorized keys file>" >&2
    return 1
  fi
  local file="$1"
  if [ ! -r "$file" ]; then
    echo "${FUNCNAME}: File '${file}' does not exist or isn't readable." >&2
    return 1
  fi
  # Must be declared /before/ assignment, because of bash weirdness, in
  # order to get exit code in $?.
  local TMPFILE
  TEMPFILE=$(mktemp -q "$1.XXXXXXXXXX")
  if (( $? != 0 )); then
    echo "${FUNCNAME}: Can't create temporary file." >&2
    return 1
  fi

  while read line; do
    # Make sure line isn't a comment or blank.
    if [[ -n "$line" ]] && [ "${line###}" == "$line" ]; then
      # Insert key into temporary file (ignoring noclobber).
      echo "$line" >| "$TEMPFILE"
      # Grab comment from key to distinguish multiple keys
      comment=$(echo ${line} | awk 'BEGIN{FS=" "}; {print($(NF))}')
      echo -n "${comment}: "
      # Fingerprint time.
      ssh-keygen -l -f "$TEMPFILE"

      # Overwrite the file ASAP (ignoring noclobber) to not leave keys
      # sitting in temp files.
      >| "$TEMPFILE"
    fi
  done < "$file"

  rm -f "$TEMPFILE"
  if (( $? != 0 )); then
    echo "${FUNCNAME}: Failed to remove temporary file." >&2
    return 1
  fi
}
