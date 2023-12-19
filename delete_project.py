#!/opt/homebrew/bin/python3.12
import click
import subprocess


@click.command()
@click.argument("substring", type=str, required=True)
def delete_repos(substring):
    """
    Searches GitHub repositories for a substring and deletes all matching ones with confirmation.

    Args:
        substring: The substring to search for in repository names.
    """
    repos_to_delete = []

    # Search for repositories containing the substring
    search_process = subprocess.run("gh search repos " + substring, capture_output=True, text=True, shell=True)
    if search_process.returncode != 0:
        click.echo(f"Error searching for repositories: {search_process.stderr}")
        click.echo("Exiting...")
        return

    # Extract repository names from search results
    for line in search_process.stdout.splitlines():
        if "rinkaaan/" not in line:
            continue
        line = line.split()[0]
        repo_name = line.split("/")[1]
        repos_to_delete.append(repo_name)

    # Confirm deletion with the user
    message = f"Found {len(repos_to_delete)} repositories matching '{substring}':"
    for repo_name in repos_to_delete:
        message += f"\n\t{repo_name}"
    message += "\nAre you sure you want to delete them all?"
    if not click.confirm(message):
        return

    # Delete the repositories
    for repo_name in repos_to_delete:
        delete_process = subprocess.run(f"gh repo delete --yes {repo_name}", capture_output=True, text=True, shell=True)
        if delete_process.returncode != 0:
            click.echo(f"Error deleting repository {repo_name}: {delete_process.stderr}")
            continue
        click.echo(f"Successfully deleted repository {repo_name}")

    click.echo(f"Deleted {len(repos_to_delete)} repositories.")


if __name__ == "__main__":
    delete_repos()
