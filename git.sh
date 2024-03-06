# map.txt
# John Doe <new-email@example.com> <old-email@example.com>
# Lincoln Nguyen <137611486+rinkaaan@users.noreply.github.com> <old-email@example.com>
# < and > are required

reauthor-to-personal() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Reauthor $(basename "$PWD")"
    git filter-repo --mailmap ~/map.txt --force
    repo=$(basename "$PWD")
    git remote add origin "git@github.com:rinkaaan/$repo.git"
    git push --set-upstream origin main --force
  fi
}

reauthor-to-amazon() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Reauthor $(basename "$PWD")"
    git filter-repo --mailmap ~/map2.txt --force
    repo=$(basename "$PWD")
#    git remote add origin "git@github.com:rinkaaan/$repo.git"
#    git push --set-upstream origin main --force
  fi
}

reauthor-all() {
  # Reauthor the current directory as a repo
  reauthor-to-personal

  # Find and reauthor all subdirectories that are Git repositories
  find . -type d -maxdepth 1 ! -name ".*" | while read -r dir; do
    (
      cd "$dir" || exit
      if git rev-parse --is-inside-work-tree &>/dev/null; then
        reauthor-to-personal
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

get-git-config() {
  git config --global user.email
}

add-amzn-origin() {
  git remote add origin "ssh://git.amazon.com:2222/pkg/$1"
  git fetch origin
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
    git rm -rf "$repo"
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

# e.g. publish-repos <repo1> <repo2> <repo3>
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
  local force_check=false

  while getopts ":f" opt; do
    case "$opt" in
      f)
        force_check=true
        ;;
      *)
        echo "Invalid option: -$OPTARG"
        return
        ;;
    esac
  done

  if [ "$force_check" = false ] && [[ $(git status --porcelain) ]]; then
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

rsync-project() {
    local dir_name="$1"  # This captures the string argument passed to the function.

    # Ensure that a directory name has been provided
    if [[ -z "$dir_name" ]]; then
        echo "Error: No directory name provided."
        return 1  # Return with error status.
    fi

    # Define the local directory path.
    local local_dir_path="$HOME/workplace/${dir_name}"

    # Define the remote directory path. Adjust the path as necessary.
    local remote_dir_path="root@hetzner:/root/workplace/${dir_name}"

    # Use rsync to synchronize the directory. Adjust rsync options as necessary.
    # -a: Archive mode, preserves symbolic links, permissions, timestamps, group, and owner.
    # -v: Verbose mode, provides detailed output.
    # -z: Compress file data during the transfer.
    # --progress: Show progress during transfer.
    # You might want to add --delete to delete extraneous files from the destination directory.
    rsync --exclude='.git' --exclude='node_modules' --exclude='.DS_Store' --filter=':- .gitignore' -avz -e "ssh -i ~/.ssh/id_rsa_hetzner" --progress "${local_dir_path}/" "${remote_dir_path}/"

    # Check if rsync was successful
    if [[ $? -eq 0 ]]; then
        echo "Synchronization successful."
    else
        echo "Error during synchronization."
        return 1  # Return with error status.
    fi
}


rsync-project-hard() {
    local dir_name="$1"  # This captures the string argument passed to the function.

    # Ensure that a directory name has been provided
    if [[ -z "$dir_name" ]]; then
        echo "Error: No directory name provided."
        return 1  # Return with error status.
    fi

    # Define the local directory path.
    local local_dir_path="$HOME/workplace/${dir_name}"

    # Define the remote directory path. Adjust the path as necessary.
    local remote_dir_path="root@hetzner:/root/workplace/${dir_name}"

    # Use rsync to synchronize the directory. Adjust rsync options as necessary.
    # -a: Archive mode, preserves symbolic links, permissions, timestamps, group, and owner.
    # -v: Verbose mode, provides detailed output.
    # -z: Compress file data during the transfer.
    # --progress: Show progress during transfer.
    # You might want to add --delete to delete extraneous files from the destination directory.
    rsync --exclude='.git' --exclude='node_modules' --exclude='.DS_Store' --filter=':- .gitignore' -avz --delete -e "ssh -i ~/.ssh/id_rsa_hetzner" --progress "${local_dir_path}/" "${remote_dir_path}/"

    # Check if rsync was successful
    if [[ $? -eq 0 ]]; then
        echo "Synchronization successful."
    else
        echo "Error during synchronization."
        return 1  # Return with error status.
    fi
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

clear-git() {
  git rm -rf --cached .
  git add .
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
