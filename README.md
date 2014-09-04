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

`perl main.pl registerMap.xls`

Output generated to `registerMap.xml` (same name with input file)
