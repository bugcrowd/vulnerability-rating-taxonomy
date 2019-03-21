<p align="center">
  <img src="https://user-images.githubusercontent.com/1854876/28642569-b44a823a-7207-11e7-8f26-af023adc5d22.png" />
</p>

<p align="center">
  <img src="https://badge.buildkite.com/c1825a6d2bed24dfa8d4b65bd43bab7502979ef0d7b4399e04.svg?branch=master" />
</p>

# Bugcrowd VRT
The current VRT release is located at [https://bugcrowd.com/vrt](https://bugcrowd.com/vulnerability-rating-taxonomy) as both a searchable page and downloadable PDF.

The VRT is also available via our API. Documentation and examples of VRT API usage may be found [here](https://docs.bugcrowd.com/reference#vulnerability-rating-taxonomy).

## Background
At the beginning 2016, we released the Bugcrowd Vulnerability Rating Taxonomy (VRT) to provide a baseline vulnerability priority scale for bug hunters and organizations. Over the past year and a half this document has evolved to be a dynamic and valuable resource for the bug bounty community.

In April 2017 we decided to open source our taxonomy and published formal contributor guidelines for the VRT, allowing us to gain additional insight from the public and transparently communicate about any feedback.

## VRT Council
Each week several members of the Bugcrowd team hold a meeting where they discuss vulnerability edge cases, improving vulnerability classification and all external VRT feedback. When the team comes to a consensus regarding each change proposed to the VRT, it is committed to this repository. We have decided to publish minutes from the VRT Council meeting to allow even more transparency and will be sharing those [here](https://github.com/bugcrowd/vulnerability-rating-taxonomy/wiki/VRT-Council-minutes).

## Description
Bugcrowd's VRT outlines Bugcrowd's baseline technical severity rating – taking into account potential differences among edge cases – for common vulnerability classes. To arrive at this baseline technical severity rating for a given vulnerability, Bugcrowd's application security engineers started with the generally-accepted industry guideline and further considered the vulnerability's average acceptance rate, average priority, and frequency on business use case specific exclusions lists across all of Bugcrowd's programs.

It is important to remember that while the recommended priority, from P1 to P5 might apply without context, it’s possible that application complexity, bounty brief restrictions or unusual impact could result in a different rating.

Bugcrowd welcomes community feedback and direct contributions to the Bugcrowd VRT. We accept comments for public discussion via GitHub Issues, but can also accommodate comments made via email to [vrt@bugcrowd.com](mailto:vrt@bugcrowd.com). For more details see [CONTRIBUTING](.github/CONTRIBUTING.md).

## Anatomy of VRT Entries
Each top-level category entry contains one or more subcategory entries, and each subcategory entry may contain one or more variant entries used to differentiate subcases with different priority values. Some entries may have a `null` priority value – this represents that the priority varies based on context information.

### Types of VRT Entries
A VRT entry can be classified at up to three levels, including `Category`, `Sub-Category`, and `Variant`. Each classification level is nested within its parent and contains a set of definitions exclusive to its level.

#### Category
These comprise the top level of the VRT. They describe entire classes of vulnerabilities.

example: `Server-Side Injection`

#### Sub-Categories
Many Sub-Categories are nested within a Category. They describe individual vulnerabilities.

example: `Server-Side Injection > Remote Code Execution (RCE)`

#### Variants
Many Variants are nested within a Sub-Category. They describe specific sub-cases of an individual vulnerability.

example: `Server-Side Injection > SQL Injection > Blind`

### Data within an Entry
Within each entry is a set of data outlined below.

#### ID
Each ID – often the lowercase version of its name joined by `_` –  is unique among the children of its own parent. This is how VRT ID's can map between versions, such that an ID is only changed if it should not be identified with previous versions of that entry.

#### Name
The human-readable name of the vulnerability.

#### Priority
The priority represents Bugcrowd's suggested baseline technical severity of the vulnerability on a P1 (Critical) to P5 (Informational) scale.

- **P1**: Critical
- **P2**: High
- **P3**: Medium
- **P4**: Low
- **P5**: Informational

The technical severity of some vulnerabilities – as denoted in the taxonomy as "Varies" – is context-dependent. For example, the technical severity of an `Insecure Direct Object Reference` vulnerability is heavily dependent on the capabilities of the vulnerable function and other context information. Valid `Insecure Direct Object Reference` vulnerabilities can vary in priority from P4 to P1.

#### Children
Entries that are nested within another Entry. Only Categories or Sub-Categories can have children.

### Example
```json
{
  "id": "server_security_misconfiguration",
  "name": "Server Security Misconfiguration",
  "type": "category",
  "children": [
    {
      "id": "directory_listing_enabled",
      "name": "Directory Listing Enabled",
      "type": "subcategory",
      "children": [
        {
          "id": "non_sensitive_data_exposure",
          "name": "Non-Sensitive Data Exposure",
          "type": "variant",
          "priority": 5
        }
      ]
    }
  ]
}
```

### Deprecated Node Mapping
When breaking changes such as deletion/collapsing of IDs or moving to a different parent occur, the [`deprecated-node-mapping.json`](deprecated-node-mapping.json) will serve as a reference to find the latest mapped ids so that deprecated nodes are not lost.

#### Example
_2 nodes being collapsed into 1_
```json
{
  "unvalidated_redirects_and_forwards.open_redirect.get_based_all_users": {
    "2.1": "unvalidated_redirects_and_forwards.open_redirect.get_based"
  },
  "unvalidated_redirects_and_forwards.open_redirect.get_based_authenticated": {
    "2.1": "unvalidated_redirects_and_forwards.open_redirect.get_based"
  }
}
```

### Mapping to Other Systems
Sometimes it is useful to convert VRT IDs to other vulnerability classification systems, eg CVSS.
Such mappings are supported by adding a mapping folder/files to the [mappings](mappings) directory.
These files have a similar structure to the main VRT file but only include the `id` and `children` attributes,
plus an additional mapping attribute with the same name as the file.

For example, suppose we wish to map to a traffic light system which maps all vulnerabilities to red, green or yellow.
We would add a mapping file called `mappings/traffic_light/traffic_light.json` with contents like:

```
{
  "metadata": {
    "default": "green"
  },
  "content": [
    ...
    {
      "id": "server_side_injection",
      "traffic_light": "red",
      "children": [
        {
          "id": "content_spoofing",
          "children": [
            {
              "id": "iframe_injection",
              "traffic_light": "yellow"
            }
          ]
        }
      ]
    },
    ...
  ]
}
```

This would map the `other` category and any unknown IDs to the `metadata.default` value of `green`.
All VRT IDs nested below `server_side_injection` would map to `red`, except for
`server_side_injection.content_spoofing.iframe_injection` which would map to `yellow`.

Each mapping should be setup in the following structure:

    .
    ├── ...
    ├── mappings
    │   ├── new_mapping
    |   |     ├── new_mapping.schema.json # Following JSON Schema (https://json-schema.org/), to be run in CI
    |   |     ├── new_mapping.json        # Actual VRT mapping file as described above
    │   └── ...              
    └── ...

#### Supported Mappings
- [CVSS v3](mappings/cvss_v3/cvss_v3.json)
- [CWE](mappings/cwe/cwe.json)
- [Remediation Advice](mappings/remediation_advice/remediation_advice.json)

## Supported Libraries
- [Ruby](https://github.com/bugcrowd/vrt-ruby)

## License
Copyright 2017 Bugcrowd, Inc.
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
