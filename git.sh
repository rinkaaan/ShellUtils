# map.txt
# John Doe <new-email@example.com> <old-email@example.com>

reauthor() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Reauthor $(basename "$PWD")"
    git filter-repo --mailmap ~/map.txt --force
    repo=$(basename "$PWD")
    git remote add origin "git@github.com:rinkaaan/$repo.git"
    git push --set-upstream origin main --force
  fi
}

reauthor-all() {
  # Reauthor the current directory as a repo
  reauthor

  # Find and reauthor all subdirectories that are Git repositories
  find . -type d -maxdepth 1 ! -name ".*" | while read -r dir; do
    (
      cd "$dir" || exit
      if git rev-parse --is-inside-work-tree &>/dev/null; then
        reauthor
      fi
    )
  done
}

add-submodules() {
  for repo in "$@"; do
    echo "Adding submodule $repo"
    git submodule add "git@github.com:rinkaaan/$repo.git" "$repo"
  done
  git submodule update --init --recursive
}

# create function to init repo in current directory and all subdirectories as submodules
init-version-set() {
  # Init the current directory as a repo
  git init

  # Find and init all subdirectories that are Git repositories (run add-submodules with names of all subdirectories that are Git repositories)
  find . -type d -maxdepth 1 ! -name ".*" | while read -r dir; do
    (
      repo=$(basename "$dir")
      add-submodules "$repo"
    )
  done
}

force-push() {
  find . -type d -maxdepth 1 ! -name ".*" | while read -r dir; do
    (
      cd "$dir" || exit
      if git rev-parse --is-inside-work-tree &>/dev/null; then
        git push --force
      fi
    )
  done

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    git push --force
  fi
}

publish-repo() {
  gh repo create --public --source=. --remote=origin
  git push --set-upstream origin main
}

set-upstream() {
  git push --set-upstream origin main
}

add-remote() {
  repo=$(basename "$PWD")
  git remote add origin "git@github.com:rinkaaan/$repo.git"
  git push --set-upstream origin main
}

remove-all-remotes() {
  git remote | xargs -L1 git remote remove
}
