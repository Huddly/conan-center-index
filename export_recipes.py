from pathlib import Path
from argparse import ArgumentParser
import yaml
import os
import subprocess

def get_version_data(path: Path):
    with open(path.joinpath('config.yml')) as file:
        config = yaml.safe_load(file)
        version_data = config['versions']
        return version_data
    
def export_recipe(path: Path): 
    version_data = get_version_data(path)
    for version in version_data:
        recipe_folder = path.joinpath(version_data[version]['folder'])
        subprocess.run(['conan', 'export', recipe_folder, '--version', version])

def upload_recipe(package_name: str, remote: str, version='*', force = False):
    print(f"Uploading {package_name}/{version} to {remote}")
    cmd = ['conan', 'upload', '--only-recipe', '--confirm', '-r', remote]
    if force:
        cmd.append('--force')
    cmd.append('--dry-run')
    cmd.append(f"{package_name}/{version}")
    subprocess.run(cmd)

def export_all(root_path: Path, remote: str, force: bool):
    subfolders = [f.path for f in os.scandir(root_path) if f.is_dir()]
    for folder in subfolders:
        package_name = os.path.basename(folder)
        export_recipe(Path(folder))
        upload_recipe(package_name, remote, '*', force) 
    

def main():
    parser = ArgumentParser(prog="Export conancenter recipes")

    parser.add_argument('--remote', default='conan-center-local', help='Remote that recipes will be uploaded to')
    parser.add_argument('--recipe', default='', help='Export single recipe')
    parser.add_argument('--force', action='store_true', help='force reupload of recipe(s)')

    args = parser.parse_args()
    if args.recipe == '':
        #export all versions of all recipes
        export_all('./recipes', args.remote, args.force)
    else:
        export_recipe(Path(f'./recipes/{args.recipe}'))
        upload_recipe(args.recipe, args.remote, '*', args.force)

if __name__ == '__main__':
    main()
