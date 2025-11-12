from pathlib import Path
import configparser
import fnmatch
import os
import shutil

def deploy(graph, output_folder: str, **kwargs):
    config = configparser.ConfigParser(allow_no_value=True)
    config.read(graph.root.path)
    imports = list(config['imports'].keys()) if 'imports' in config else []

    out = Path(output_folder)
    out.mkdir(parents=True, exist_ok=True)

    root = graph.root.conanfile
    for _, dep in root.dependencies.items():
        pkg_folder = Path(str(dep.folders.package_folder))
        print(f"Deploy {dep}: {pkg_folder} ...")

        for item in imports:
            src_dir = Path(pkg_folder, item.split(',')[0].replace(' ', ''))
            if not src_dir.exists():
                continue

            dst_dir = Path(out, item.split('->')[-1].replace(' ', ''))
            pattern = item.split('->')[0].split(',')[-1].replace(' ', '')
            dst_dir.mkdir(parents=True, exist_ok=True)

            for root, _, files in os.walk(src_dir):
                for name in files:
                    if fnmatch.fnmatch(name, pattern):
                        src_path = os.path.join(root, name)
                        rel_path = os.path.relpath(src_path, src_dir)
                        dst_path = os.path.join(dst_dir, rel_path)
                        os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                        try:
                            shutil.copy(src_path, dst_path, follow_symlinks=False)
                        except FileExistsError:
                            pass
