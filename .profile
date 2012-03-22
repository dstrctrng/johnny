function vagrant() {
  if [[ -n $1 && -z $2 ]]; then
    set "$@" ssh
  fi

  cd ~/.virtualbox
  exec bin/vagrant "$@"
}
