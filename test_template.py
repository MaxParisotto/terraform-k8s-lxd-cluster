from jinja2 import Environment, FileSystemLoader
import json
import yaml

# Load the template
env = Environment(loader=FileSystemLoader('.'))
template = env.get_template('bundle.yaml.j2')

# Sample data based on the structure we've seen
machines = {
    '0': {'constraints': 'cores=4 mem=4G root-disk=16G', 'id': 'wp8qcw'},
    '1': {'constraints': 'cores=4 mem=8G root-disk=16G', 'id': 'pmc3yy'},
    '5': {'constraints': 'cores=4 mem=8G root-disk=20G', 'id': 'xhtkyw'},
    '6': {'constraints': 'cores=4 mem=8G root-disk=20G', 'id': 'b4f74t'},
    '7': {'constraints': 'cores=4 mem=8G root-disk=20G', 'id': 'hgkeax'},
    '8': {'constraints': 'cores=8 mem=8G root-disk=15G', 'id': 'adqb4b'},
    '9': {'constraints': 'cores=16 mem=32G root-disk=64G', 'id': 't7fahr'},
    '10': {'constraints': 'cores=16 mem=32G root-disk=64G', 'id': 'xaeacs'},
    '11': {'constraints': 'cores=16 mem=32G root-disk=64G', 'id': 'cmskcm'},
    '12': {'constraints': 'cores=16 mem=32G root-disk=64G', 'id': 'rak7fg'},
    '13': {'constraints': 'cores=4 mem=8G root-disk=64G', 'id': 'xq7tpq'},
    '14': {'constraints': 'cores=4 mem=8G root-disk=64G', 'id': '7b6tdk'},
    '15': {'constraints': 'cores=4 mem=8G root-disk=64G', 'id': 'ksc6sn'},
    '16': {'constraints': 'cores=6 mem=16G root-disk=32G', 'id': 'paxs78'}
}

applications = {
    'easyrsa': {
        'annotations': {'gui-x': '90', 'gui-y': '420'},
        'channel': '1.31/stable',
        'charm': 'easyrsa',
        'constraints': 'cores=4 mem=4G root-disk=16G',
        'num_units': 1,
        'to': ['0']
    },
    'etcd': {
        'annotations': {'gui-x': '800', 'gui-y': '420'},
        'channel': '1.31/stable',
        'charm': 'etcd',
        'constraints': 'cores=4 mem=8G root-disk=20G',
        'num_units': 3,
        'options': {'channel': '3.4/stable'},
        'to': ['5', '6', '7']
    },
    'kubeapi-load-balancer': {
        'annotations': {'gui-x': '450', 'gui-y': '250'},
        'channel': '1.31/stable',
        'charm': 'kubeapi-load-balancer',
        'constraints': 'cores=8 mem=8G root-disk=15G',
        'expose': True,
        'num_units': 1,
        'to': ['8']
    },
    'kubernetes-control-plane': {
        'annotations': {'gui-x': '800', 'gui-y': '850'},
        'channel': '1.31/stable',
        'charm': 'kubernetes-control-plane',
        'constraints': 'cores=4 mem=8G root-disk=16G',
        'num_units': 4,
        'options': {'channel': '1.31/stable'},
        'to': ['1', '2', '3', '4']
    },
    'kubernetes-worker': {
        'annotations': {'gui-x': '90', 'gui-y': '850'},
        'charm': 'kubernetes-worker',
        'constraints': 'cores=16 mem=32G root-disk=64G',
        'expose': True,
        'num_units': 4,
        'options': {'channel': '1.31/stable'},
        'to': ['9', '10', '11', '12']
    }
}

# Render the template
rendered = template.render(machines=machines, applications=applications)

# Print the rendered output
print("Rendered bundle.yaml.j2:")
print(rendered)

# Save to a file for inspection
with open('rendered_bundle.yaml', 'w') as f:
    f.write(rendered)

print("\nOutput saved to rendered_bundle.yaml")