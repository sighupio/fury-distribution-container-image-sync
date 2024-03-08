# USAGE python3 images_list_python.py --retrieve-last-3-tags (OPTIONAL)

# OUTPUT SAMPLE:
# [
#   "registry.sighup.io/fury/acid/postgres-operator:v1.6.3",
#   "registry.sighup.io/fury/acid/spilo-13:2.0-p7",
#   "registry.sighup.io/fury/acid/pgbouncer:master-16",
#   "registry.sighup.io/fury/acid/logical-backup:v1.6.3",
#   "registry.sighup.io/fury/wrouesnel/postgres_exporter:v0.8.0",
#   "registry.sighup.io/fury/grafana/tempo:2.3.1",
#   "registry.sighup.io/fury/memcached:1.5.17-alpine",
#   "registry.sighup.io/fury/velero/velero:v1.13.0"
# ]

import os
import yaml
import json
import argparse
import sys

def get_images_and_tags(directory, include_last_3_tags=False):
    image_list = []

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file == 'images.yml':
                file_path = os.path.join(root, file)
                with open(file_path, 'r') as f:
                    data = yaml.safe_load(f)
                    for image_data in data.get('images', []):
                        image_name = image_data.get('destinations', [''])[0]
                        if image_name:
                            tags = image_data.get('tag', [])
                            if include_last_3_tags and len(tags) >= 3:
                                tags = tags[-3:]
                            elif len(tags) >= 1:
                                tags = tags[-1:]  # Only the last tag
                            else:
                                print(f"WARNING: the {image_name} does not have tags defined", file=sys.stderr)
                            image_list.extend([f"{image_name}:{tag}" for tag in tags])

    return image_list

def main():
    parser = argparse.ArgumentParser(description='Process images YAML files.')
    parser.add_argument('--retrieve-last-3-tags', action='store_true', help='Include the last 3 tags for each image')
    args = parser.parse_args()

    parent_folder = os.path.dirname(os.getcwd())
    image_list = get_images_and_tags(parent_folder, include_last_3_tags=args.retrieve_last_3_tags)
    json.dump(image_list, sys.stdout, indent=2)

if __name__ == "__main__":
    main()
