#!/Users/nguylinc/.pyenv/versions/3.12.0/bin/python
import click
import subprocess
from pathlib import Path


@click.command()
@click.argument("submodules", nargs=-1)
def restore_submodules(submodules):
    """Checkout submodules based on their SHAs from git ls-tree HEAD."""

    if not submodules:
        click.echo("No submodules provided.")
        return

    for submodule in submodules:
        # Get submodule SHAs from git ls-tree HEAD
        submodule_shas = {}
        for line in subprocess.check_output(["git", "ls-tree", "HEAD"]).decode().splitlines():
            parts = line.split()
            if parts[1] == "commit" and parts[3] == submodule:
                submodule_shas[submodule] = parts[2]

        # Checkout each submodule
        for submodule, sha in submodule_shas.items():
            submodule_path = Path(submodule)

            # Check for uncommitted changes
            # Do this by cd into the submodule
            uncommitted_changes = subprocess.check_output(["git", "status", "--porcelain"], cwd=submodule_path).decode()

            if uncommitted_changes:
                print(f"Submodule {submodule} has uncommitted changes: {uncommitted_changes}")
                continue

            # Checkout the SHA
            subprocess.check_call(["git", "reset", "--hard", sha], cwd=submodule_path)
            print(f"Submodule {submodule} checked out successfully.")


if __name__ == "__main__":
    restore_submodules()
