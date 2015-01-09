{% from "emet/map.jinja" import emet with context %}

# This sls file will install Microsoft Enhanced Mitigation Experience Toolkit 
# (EMET). Local Group Policy Object (LGPO) files will be updated so that EMET 
# can be managed from the Local Group Policy Editor (i.e. gpedit.msc).

#Dependencies:
#  - Microsoft .NET 4 or greater.
#  - Properly configured salt winrepo package manager, in a master or 
#    masterless configuration.
#  - Package definition for EMET from salt-winrepo must be available in the 
#    winrepo database.
#    - https://github.com/saltstack/salt-winrepo/blob/master/emet.sls

#TODO:
# - Write a .NET formula that can be included sanely, while avoiding 
#   unnecessary downloads and installs, and accounting for the odd .NET deltas 
#   across different versions of the Microsoft OS. For example, .NET 4.5.x will 
#   never show up in "installed software" on Windows 2012 R2, but it does on 
#   earlier versions. This largely breaks the salt winrepo functionality.

#Get the latest installed version of .NET
{% set dotNET_version = salt['cmd.run'](
  '(Get-ChildItem "HKLM:\\SOFTWARE\\Microsoft\\NET Framework Setup\\NDP" -recurse | \
    Get-ItemProperty -name Version -EA 0 | \
    Where { $_.PSChildName -match "^(?!S)\p{L}"} | \
    Select Version | Sort -Descending Version | Select -First 1).Version', 
  shell='powershell') 
%}

#Check if minimum required .NET version is available
{% if dotNET_version[:1] | int < emet.min_dotNET_version | int %}
#Fail due to missing .NET prerequisite
prereq_dotNET_{{ emet.min_dotNET_version | string }}:
  test.configurable_test_state:
    - name: '.NET {{ emet.min_dotNET_version | string }} prerequisite'
    - changes: False
    - result: False
    - comment: 'EMET {{ emet.version | string }} requires .NET {{ emet.min_dotNET_version | string }} or later. Detected .NET version: {{ dotNET_version | string }}'

{% else %}
#Passed prereqs, Install EMET and update LGPO files
install_emet:
  pkg.installed:
    - name: 'Emet'
    - version: {{ emet.version }}

EMET.admx:
  file.managed:
    - name: {{ emet.admx_name }}
    - source: {{ emet.admx_source }}
    - require:
      - pkg: install_emet

EMET.adml:
  file.managed:
    - name: {{ emet.adml_name }}
    - source: {{ emet.adml_source }}
    - require:
      - pkg: install_emet

{% endif %}
