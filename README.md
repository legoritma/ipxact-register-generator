### Requirements
----------------
* No specific hardware necessary
* UNIX based operating system (tested on Ubuntu 12.04 or Mac OS 10.9)
* Perl 5.14+
* PHP web server for Web UI (tested on Apache 2.0 and PHP v5.5)
* Included libraries and their dependicies
    * Web
        * jQuery 1.1+
        * FileSaver.js
        * jQuery Treeview
    * Tool
        * Spreadsheet::Read
        * Spreadsheet::ParseExcel
        * Spreadsheet::XLSX
        * Template Toolkit 2

### Usage
----------------

Docker is the easiest way to run generator this generator
Clone repo and run following commands on root directory

```
docker build -t ipxact-register-generator ./code/
docker run -it --rm --name ipxact-register-generator-runner -v "${PWD}/sample/input:/usr/src/data" ipxact-register-generator
```

Outputs are generated to besides to input files

To using another input directory, change the `${PWD}/sample/input` part of second command