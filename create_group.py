#!/Users/lincolnnguyen/.pyenv/versions/3.12.0/bin/python
import os
import subprocess

import click
from jinja2 import Template
from nguylinc_python_utils.misc import run_command

GITHUB_USERNAME = "rinkaaan"


def validate_env(project_name):
    if os.path.exists(project_name):
        print("Directory " + project_name + " already exists.")
        exit()

    cmd = Template('gh repo view {{ github_username }}/{{ project_name }}')
    result = subprocess.run(cmd.render(project_name=project_name, github_username=GITHUB_USERNAME), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode == 0:
        print("Repository " + project_name + " already exists.")
        exit()


def clone_template(template_name, project_name):
    print("Cloning template...")
    cmd = Template('git clone "git@github.com:{{ github_username }}/{{ template_name }}.git" {{ project_name }}')
    run_command(cmd.render(template_name=template_name, project_name=project_name, github_username=GITHUB_USERNAME))
    cmd = Template('rm -rf {{ project_name }}/.git')
    run_command(cmd.render(project_name=project_name))


def prepare_submodules(project_name):
    submodules = []

    # Iterate over files and directories
    for root, dirs, files in os.walk(project_name):
        if ".git" in root:
            continue

        for file in files:
            # Rename files
            template = Template(file)
            new_file = template.render(project_name=project_name)
            os.rename(os.path.join(root, file), os.path.join(root, new_file))

            # Replace file contents
            with open(os.path.join(root, new_file), "r") as f:
                contents = f.read()
                template = Template(contents)
                new_contents = template.render(project_name=project_name)
                with open(os.path.join(root, new_file), "w") as f2:
                    f2.write(new_contents)

    for root, dirs, files in os.walk(project_name):
        if ".git" in root:
            continue

        for directory in dirs:
            # Rename directories
            template = Template(directory)
            new_directory = template.render(project_name=project_name)
            os.rename(os.path.join(root, directory), os.path.join(root, new_directory))

            # Initialize submodule git repositories
            current_depth = root[len(project_name):].count(os.path.sep)
            if project_name in new_directory and current_depth == 0:
                submodules.append(new_directory)

                current_location = os.getcwd()
                os.chdir(os.path.join(root, new_directory))
                run_command("git init")
                run_command("git add .")
                run_command('git commit -m "Created by Submodules CLI"')
                os.chdir(current_location)

    # Init git repository in root directory
    os.chdir(project_name)
    run_command("git init")

    return submodules


def add_submodules(submodules, project_name):
    for submodule in submodules:
        print("Setting up " + submodule + "...")
        cmd = Template('git submodule add "git@github.com:{{ github_username }}/{{ submodule }}.git" "{{ submodule }}"')
        run_command(cmd.render(submodule=submodule, github_username=GITHUB_USERNAME))
        run_command("git submodule update --init --recursive")

        current_location = os.getcwd()
        os.chdir(submodule)
        run_command("gh repo create --public --source=. --remote=origin")
        run_command("git push --set-upstream origin main")
        os.chdir(current_location)

    print("Setting up " + project_name + "...")
    run_command("git add .")
    run_command('git commit -m "Created by Submodules CLI"')
    run_command("gh repo create --public --source=. --remote=origin")
    run_command("git push --set-upstream origin main")

    print("Done!")


@click.command()
@click.argument('template_name')
@click.argument('project_name')
def main(template_name, project_name):
    validate_env(project_name)
    clone_template(template_name, project_name)
    submodules = prepare_submodules(project_name)
    add_submodules(submodules, project_name)
    run_command("add-submodules PythonUtils")


# create_group.py WebAppTemplate ConnexionFileUploadDemo
if __name__ == "__main__":
    main()
