tranSMART 1.2.x
===============

This install is based on the install instructions contained in:

https://wiki.transmartfoundation.org/pages/viewpage.action?pageId=6619205

Description
===========
This Cookbook installs tranSMART.

is a knowledge management platform that enables scientists to develop and refine research hypotheses by investigating correlations between genetic and phenotypic data, and assessing their analytical results in the context of published literature and other work.

https://github.com/transmart 

Requirements
============

## Platform:

* Ubuntu 14.04 Trusty Tahir

Notes
=====
The REHL installs are now out of date and should not be used.

Usage
=====
Simply include the recipe wherever you would like it installed, such as a run list (recipe[tranSMART]) or a cookbook (include_recipe 'tranSMART')

## Testing
To test the recipe we use chef test kitchen:

kitchen converge default-centos65 

kitchen login default-centos65

kitchen verify default-centos65

kitchen destroy default-centos65

Attributes
==========
See attributes/default_transmart.rb for default values.

License and Authors
===================

* Authors:: Bart Ailey (<chef@eaglegenomics.com>)
* Authors:: Dan Barrell (<chef@eaglegenomics.com>)
* Authors:: Nick James (<chef@eaglegenomics.com>)
    

Copyright:: 2015, Eagle Genomics Ltd
    
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
    
ToDo
====

Update the RHEL installs. 

