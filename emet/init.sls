{% from "emet/map.jinja" import emet with context %}

# This sls file will install Microsoft Enhanced Mitigation Experience Toolkit
# (EMET). Local Group Policy Object (LGPO) files will be updated so that EMET
# can be managed from the Local Group Policy Editor (i.e. gpedit.msc).

#Dependencies:
#  - Microsoft .NET 4 or greater.
#  - Salt 2015.8.0 or greater (required for templating the winrepo package).
#  - Properly configured salt winrepo package manager, in a master or
#    masterless configuration.
#  - Package definition for EMET from salt-winrepo must be available in the
#    winrepo database.
#    - https://github.com/saltstack/salt-winrepo/blob/master/emet.sls

#Check whether .NET is installed and meets the compatibility requirement
emet_prereq_dotnet_{{ emet.dotnet_compatibility | join('_') }}:
  cmd.run:
    - name: '
      if (
        @(
          @( {{ emet.dotnet_compatibility | join(',') }} ) |
            where {
              ( ( Get-ChildItem
                    "HKLM:\\SOFTWARE\\Microsoft\\NET Framework Setup\\NDP"
                    -recurse |
                  Get-ItemProperty -name Version -EA 0 |
                  where { $_.PSChildName -match "^(?!S)\p{L}" } |
                  Select Version |
                  Sort -Unique
                ) |
                foreach-object { $_.Version.Substring(0,1) }
              )
              -contains
              $_
            }
        ).Count
      ) {
        echo ".NET requirement satisfied."; exit 0
      } else {
        echo "Failed .NET requirement."; exit 1
      }'
    - shell: 'powershell'

#Install EMET and update LGPO files
install_emet:
  pkg.installed:
    - name: 'emet'
    - version: {{ emet.version }}
    - allow_updates: True
    - require:
      - cmd: emet_prereq_dotnet_{{ emet.dotnet_compatibility | join('_') }}

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
