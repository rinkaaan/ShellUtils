#!/Users/nguylinc/.pyenv/versions/3.12.0/bin/python
import os
import subprocess

import click
from nguylinc_python_utils.misc import run_command


def get_repos():
    if not os.path.exists(".git"):
        print("Not a git repository")
        exit()

    result = subprocess.run("git config --file .gitmodules --get-regexp path | awk '{ print $2 }'", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode != 0:
        print("No submodules found")
        exit()

    print("Repositories found: ")
    repos = []
    group_name = os.path.basename(os.getcwd())
    repos.append(group_name)
    print('   ' + group_name)

    submodules = result.stdout.decode("utf-8").split("\n")
    submodules = list(filter(lambda x: x != "", submodules))
    for submodule in submodules:
        repos.append(submodule)
        print('   ' + submodule)

    return repos


def delete_repos(repos):
    confirmation = click.confirm("Are you sure you want to proceed?")

    if confirmation:
        click.echo("Deleting repos...")
        for repo in repos:
            run_command("gh repo delete " + repo + " --confirm")
    else:
        click.echo("Exiting...")


@click.command()
def main():
    repos = get_repos()
    delete_repos(repos)


if __name__ == "__main__":
    main()
