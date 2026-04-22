import boto3
import argparse
import os
import re
import json

def get_clean_name(sg):
    """Determines the directory name and strips the _sg-[digits] suffix."""
    name = sg.get('GroupName', 'unknown_sg')
    if 'Tags' in sg:
        for tag in sg['Tags']:
            if tag['Key'] == 'Name':
                name = tag['Value']
                break
    return re.sub(r'(_sg)-\d+', r'\1', name)

def transform_rules(permissions):
    """
    Transforms Boto3 IpPermissions into the list of maps format 
    expected by the terraform-aws-modules SG module.
    """
    rules = []
    for perm in permissions:
        # Normalize protocol and ports
        proto = perm.get('IpProtocol')
        if proto == "-1":
            proto = "all"
            from_port = 0
            to_port = 0
        else:
            from_port = perm.get('FromPort', 0)
            to_port = perm.get('ToPort', 0)

        # Iterate through CIDR ranges to create a rule for each
        for ip_range in perm.get('IpRanges', []):
            rules.append({
                'from_port': from_port,
                'to_port': to_port,
                'protocol': proto,
                'description': ip_range.get('Description', 'Imported rule'),
                'cidr_blocks': ip_range['CidrIp']
            })
    return rules

def format_hcl_list(data_list):
    """Converts a Python list of dicts to a clean HCL-style string."""
    if not data_list:
        return "[]"
    
    # We use json.dumps for the structure, then clean up the formatting for HCL
    formatted = json.dumps(data_list, indent=4)
    # Removing quotes from keys to make it look like native HCL
    formatted = re.sub(r'"(\w+)":', r'\1 =', formatted)
    return formatted

def create_terragrunt_file(path, sg, vpc_id):
    """Writes the terragrunt.hcl with dynamic ingress/egress inputs."""
    
    ingress_rules = transform_rules(sg.get('IpPermissions', []))
    egress_rules = transform_rules(sg.get('IpPermissionsEgress', []))

    ingress_hcl = format_hcl_list(ingress_rules)
    egress_hcl = format_hcl_list(egress_rules)

    content = f'''terraform {{
  source = "tfr:///terraform-aws-modules/security-group/aws?version=${{include.root.locals.terraform_module_versions.security_group}}"
}}

include "root" {{
  path = find_in_parent_folders("root.hcl")
  expose = true
}}

# easy reading of variables
locals {{
  cidr_block = include.root.locals.def.cidr[include.root.locals.def.env][include.root.locals.def.region][basename(get_terragrunt_dir())]
  region     = include.root.locals.def.region
  rgn        = include.root.locals.def.rgn
  env        = include.root.locals.def.env
  name       = basename(get_terragrunt_dir())
  azs        = include.root.locals.def.azs[include.root.locals.def.rgn]
}}

inputs = {{
  name        = "{os.path.basename(path)}"
  vpc_id      = "{vpc_id}"
  description = "{sg.get('Description', 'Security group managed by Terragrunt')}"

  ingress_with_cidr_blocks = {ingress_hcl}

  egress_with_cidr_blocks = {egress_hcl}
}}
'''
    with open(os.path.join(path, "terragrunt.hcl"), "w") as f:
        f.write(content)

def main():
    parser = argparse.ArgumentParser(description='Generate Terragrunt files from VPC Security Groups.')
    parser.add_argument('--vpc', required=True, help='The VPC ID to search in')
    parser.add_argument('--region', required=True, help='The AWS region (e.g., us-east-1)')
    args = parser.parse_args()

    # Initialize client with specified region
    ec2 = boto3.client('ec2', region_name=args.region)

    try:
        print(f"🔍 Searching region {args.region} for VPC: {args.vpc}...")
        response = ec2.describe_security_groups(
            Filters=[{'Name': 'vpc-id', 'Values': [args.vpc]}]
        )
        
        sgs = response.get('SecurityGroups', [])
        print(f"✅ Found {len(sgs)} Security Groups.")

        for sg in sgs:
            folder_name = get_clean_name(sg)
            if not os.path.exists(folder_name):
                os.makedirs(folder_name)
            
            create_terragrunt_file(folder_name, sg, args.vpc)
            print(f"📄 Generated {folder_name}/terragrunt.hcl")

    except Exception as e:
        print(f"❌ Error: {str(e)}")

if __name__ == "__main__":
    main()
