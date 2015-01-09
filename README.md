# emet-formula
====
emet
====

This salt formula will install Microsoft Enhanced Mitigation Experience Toolkit
(EMET). Local Group Policy Object (LGPO) files will be updated so that EMET can
be managed from the Local Group Policy Editor (i.e. gpedit.msc).

Dependencies
============
  - Microsoft .NET 4 or greater.
  - Properly configured salt winrepo package manager, in a master or 
    masterless configuration.
  - Package definition for EMET from salt-winrepo must be available in the 
    winrepo database.
    - https://github.com/saltstack/salt-winrepo/blob/master/emet.sls

Available States
================

.. contents::
    :local:

``emet``
--------

Install Microsoft Enhanced Mitigation Experience Toolkit (EMET)

Configuration
=============
Every option available in the EMET formula can be set in pillar. The default
settings in pillar.example are the same as the default settings in the formula.
Below is an example pillar configuration.

..

    emet:
      lookup:
        emet_version: '5.1'
        emet_admx_source: 'salt://emet/emetfiles/EMET.admx'
        emet_adml_source: 'salt://emet/emetfiles/EMET.adml'

TODO
====
 - [ ] Write a .NET formula that can be included sanely, while avoiding 
       unnecessary downloads and installs, and accounting for the odd .NET 
       deltas across different versions of the Microsoft OS. For example, .NET 
       4.5.x will never show up in "installed software" on Windows 2012 R2, but
       it does on earlier versions. This largely breaks the salt winrepo 
       functionality.
