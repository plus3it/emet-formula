[![license](https://img.shields.io/github/license/plus3it/emet-formula.svg)](./LICENSE)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/plus3it/emet-formula?branch=master&svg=true)](https://ci.appveyor.com/project/plus3it/emet-formula)

# emet

This salt formula will install Microsoft Enhanced Mitigation Experience Toolkit
(EMET). Local Group Policy Object (LGPO) files will be updated so that EMET can
be managed from the Local Group Policy Editor (i.e. gpedit.msc).

## Dependencies
- Microsoft .NET 4 or greater.
- Salt 2015.8.0 or greater (required for templating the winrepo package).
- Properly configured salt winrepo package manager, in a master or
masterless configuration.
- Package definition for EMET from salt-winrepo must be available in the
winrepo database.
    - https://github.com/saltstack/salt-winrepo/blob/master/emet.sls

## Available States

### emet

Install Microsoft Enhanced Mitigation Experience Toolkit (EMET)

## Configuration
Every option available in the EMET formula can be set in pillar. The default
settings in pillar.example are the same as the default settings in the formula.
Below is an example pillar configuration.

```
    emet:
      lookup:
        version: '5.2'
        admx_source: 'salt://emet/emetfiles/EMET.admx'
        adml_source: 'salt://emet/emetfiles/EMET.adml'
```
