{% from "emet/map.jinja" import emet with context %}

#Get the latest installed version of .NET
{% set dotNET_version = salt['cmd.run'](
  '(Get-ChildItem "HKLM:\\SOFTWARE\\Microsoft\\NET Framework Setup\\NDP" -recurse | \
    Get-ItemProperty -name Version -EA 0 | \
    Where { $_.PSChildName -match "^(?!S)\p{L}"} | \
    Select Version | Sort -Descending Version | Select -First 1).Version', 
  shell='powershell') 
%}

#Make sure minimum required .NET version is available before installing EMET
{% if dotNET_version[:1] | int >= emet.min_dotNET_version | int %}
#Install EMET and update LGPO files
Emet:
  pkg.installed:
    - version: {{ emet.version }}

EMET.admx:
  file.managed:
    - name: {{ emet.admx_name }}
    - source: {{ emet.admx_source }}
    - require:
      - pkg: Emet

EMET.adml:
  file.managed:
    - name: {{ emet.adml_name }}
    - source: {{ emet.adml_source }}
    - require:
      - pkg: Emet

{% else %}
#Fail due to missing .NET prerequisite
prereq_dotNET_{{ emet.min_dotNET_version | string }}:
  test.configurable_test_state:
    - name: '.NET {{ emet.min_dotNET_version | string }} prerequisite'
    - changes: False
    - result: False
    - comment: 'EMET {{ emet.version | string }} requires .NET {{ emet.min_dotNET_version | string }} or later. Detected .NET version: {{ dotNET_version | string }}'
{% endif %}
