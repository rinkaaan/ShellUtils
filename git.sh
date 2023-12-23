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

config-git-personal() {
  git config --global user.name "Lincoln Nguyen"
  git config --global user.email "137611486+rinkaaan@users.noreply.github.com"
}

config-git-amazon() {
  git config --global user.name "Lincoln Nguyen"
  git config --global user.email "nguylinc@amazon.com"
}

add-submodules() {
  for repo in "$@"; do
    echo "Adding submodule $repo"
    git submodule add "git@github.com:rinkaaan/$repo.git" "$repo"
    git submodule update --init --recursive "$repo"
  done
}

add-submodules-no-init() {
  for repo in "$@"; do
    echo "Adding submodule $repo"
    git submodule add "git@github.com:rinkaaan/$repo.git" "$repo"
  done
}

remove-submodules() {
  for repo in "$@"; do
    echo "Removing submodule $repo"
    git submodule deinit -f "$repo"
    git rm -f "$repo"
    rm -rf .git/modules/"$repo"
  done
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
  find . -maxdepth 1 -type d ! -name ".*" | while read -r dir; do
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

publish-repos() {
  for dir in "$@"; do
    echo "Publishing $dir"
    (
      cd "$dir" || exit
      publish-repo
    )
  done
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

clone() {
  git clone "git@github.com:rinkaaan/$1.git" $1
}

clone-project() {
  if [ $# -eq 1 ]; then
    git clone "git@github.com:rinkaaan/$1.git" ~/workplace/"$1"
  else
    git clone "git@github.com:rinkaaan/$1.git" ~/workplace/"$2"
  fi

  (
    if [ $# -eq 1 ]; then
      cd ~/workplace/"$1" || exit
    else
      cd ~/workplace/"$2" || exit
    fi
    git submodule update --init --recursive
    git submodule foreach git checkout main
    pycharm .
  )
}

sync-project() {
  if [[ $(git status --porcelain) ]]; then
    echo "There are uncommitted changes"
    return
  fi
  git submodule update --init --recursive
  git submodule foreach git checkout main
  git submodule foreach --recursive git fetch
  git submodule foreach --recursive git reset --hard origin/main
  git fetch
  git reset --hard origin/main
}

fetch-project() {
  git submodule foreach git fetch
  git fetch
}

reset-project() {
  git submodule foreach git rm --cached -r .
  git submodule foreach git clean -f
  git submodule foreach git reset --hard
  git rm --cached -r .
  git clean -f
  git reset --hard
}


publish-project() {
  find . -type d -maxdepth 1 ! -name ".*" | while read -r dir; do
    (
      cd "$dir" || exit
      if git rev-parse --is-inside-work-tree &>/dev/null; then
        publish-repo
      fi
    )
  done

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    publish-repo
  fi
}

reset-git() {
  cd "$1" || exit
  rm -rf .git
  git init
  git add .
  git commit -m "Init"
  cd ..
}

rm-git() {
  for dir in "$@"; do
    echo "Removing git from $dir"
    (
      cd "$dir" || exit
      rm -rf .git
      cd ..
    )
  done
}

init-git() {
  for dir in "$@"; do
    echo "Creating git in $dir"
    (
      cd "$dir" || exit
      git init
      git add .
      git commit -m "Init"
      cd ..
    )
  done
}

alias git-hashes="git ls-tree HEAD"
