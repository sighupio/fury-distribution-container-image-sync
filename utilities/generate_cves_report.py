import os
import threading
import subprocess
import json
import csv
from datetime import datetime
import sys

# Number of threads
num_threads = 8

# Dictionary to hold scan results
scan_results = {}

def trivy_scan(image):
    try:
        print("Starting Trivy scan for image " + image)
        result = subprocess.run(['trivy', 'image', '--no-progress', '--format', 'json', image], capture_output=True, text=True, check=True)
        scan_results[image] = json.loads(result.stdout)
        print("Successfully completed Trivy scan for image " + image)
    except subprocess.CalledProcessError as e:
        print(f"Error scanning {image}: {e}")
        scan_results[image] = {"error": str(e)}

def get_image_list():
    script_path = os.path.join(os.path.dirname(__file__), 'image_list_json.py')
    try:
        result = subprocess.run(['python3', script_path], capture_output=True, text=True, check=True, cwd=os.path.dirname(script_path))
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error getting image list: {e}")
        return []

# Obtain list of images
images = get_image_list()
# For rapid, local test comment the previous line and uncomment the following piece of code:
# images = [
#     "registry.sighup.io/fury/acid/postgres-operator:v1.6.3",
#     "registry.sighup.io/fury/acid/spilo-13:2.0-p7",
#     "registry.sighup.io/fury/acid/pgbouncer:master-16",
#     "registry.sighup.io/fury/acid/logical-backup:v1.6.3"
# ]

# print(f"Image list: {images}")

# Check if '--report-secured' argument is provided
if '--report-secured' in sys.argv:
    # Modify image names to add 'secured' after 'fury'
    print('Generating CVEs report for secured images...')
    images = [image.replace('fury/', 'fury/secured/') for image in images]

# Split images into chunks for parallel processing
image_chunks = [images[i:i + num_threads] for i in range(0, len(images), num_threads)]

# Create threads for scanning images
threads = []
for chunk in image_chunks:
    for image in chunk:
        thread = threading.Thread(target=trivy_scan, args=(image,))
        threads.append(thread)
        thread.start()

# Record start time
start_time = datetime.now()

# Wait for all threads to finish
for thread in threads:
    thread.join()

# Generate timestamp
timestamp = datetime.now().strftime("%d-%m-%y-%H-%M-%S")

# Aggregate scan results
aggregate_report = {}
for image, result in scan_results.items():
    aggregate_report[image] = result

# Write aggregate report to JSON
json_filename = f"reports/images_cve_report_{timestamp}.json"
with open(json_filename, "w") as jsonfile:
    json.dump(scan_results, jsonfile, indent=4)

print(f"Aggregate report saved to {json_filename}")

# Write aggregate report to CSV
csv_filename = f"reports/images_cve_report_{timestamp}.csv"
with open(csv_filename, "w", newline='') as csvfile:
    fieldnames = ['image_name', 'vulnerability_id', 'package_name', 'installed_version', 'fixed_version', 'severity', 'cvss_v3']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()

    for image, result in scan_results.items():
        try:
            for vuln in result['Results']:
                for vulnerability in vuln['Vulnerabilities']:
                    writer.writerow({
                        'image_name': image,
                        'vulnerability_id': vulnerability['VulnerabilityID'],
                        'package_name': vulnerability['PkgName'],
                        'installed_version': vulnerability['InstalledVersion'],
                        'fixed_version': vulnerability['FixedVersion'],
                        'severity': vulnerability['Severity'],
                        'cvss_v3': vulnerability['CVSS']['nvd']['V3Score'] if 'CVSS' in vulnerability and 'nvd' in vulnerability['CVSS'] else ''
                    })
        except Exception as e:
            print("")

print(f"Scan completed. Aggregate report saved to {csv_filename}")
# Record end time
end_time = datetime.now()

# Calculate and print total runtime
total_runtime = end_time - start_time
print(f"\nTotal runtime: {total_runtime}\n")
