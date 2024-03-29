#!/Users/nguylinc/.pyenv/versions/3.12.0/bin/python
import os
import click
from nguylinc_python_utils.misc import rename_at_root


def rename_substring_in_files(root_dir, old_substring, new_substring):
    for root, dirs, files in os.walk(root_dir):
        if ".git" in root:
            continue

        for file in files:
            # Rename files
            new_filename = file.replace(old_substring, new_substring)
            rename_at_root(root, file, new_filename)

            with open(os.path.join(root, new_filename), "r") as f:
                try:
                    contents = f.read()
                    new_contents = contents.replace(old_substring, new_substring)
                    with open(os.path.join(root, new_filename), "w") as f2:
                        f2.write(new_contents)
                except:
                    pass

    for root, dirs, files in os.walk(root_dir):
        if ".git" in root:
            continue

        for directory in dirs:
            # Rename directories
            new_directory = directory.replace(old_substring, new_substring)
            rename_at_root(root, directory, new_directory)

    new_root_dir = root_dir.replace(old_substring, new_substring)
    rename_at_root(os.path.dirname(root_dir), os.path.basename(root_dir), os.path.basename(new_root_dir))


@click.command()
@click.argument('root_dir', type=click.Path(exists=True))
@click.argument('old_substring')
@click.argument('new_substring')
def main(root_dir, old_substring, new_substring):
    rename_substring_in_files(root_dir, old_substring, new_substring)
    click.echo("Substring renamed successfully!")


# rename.py {{ target_directory }} "{{ old_name }}" "{{ new_name }}"
# rename.py SakuinSeizoukiApiTests WebAppTemplate SakuinSeizouki
if __name__ == "__main__":
    main()
