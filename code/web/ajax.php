<?php
ini_set('display_startup_errors',1);
ini_set('display_errors',1);
error_reporting(-1);

    $script = '../main.pl';
    $cmd = "perl $script -i ";
    $realFile = $_FILES['file']['tmp_name'];
    $fileName = $_FILES['file']['name'];
    //$symFile = sys_get_temp_dir() . "/" . $fileName;
    $symFile = "..//tmp/" . $fileName;
    symlink($realFile, $symFile);
    $output = shell_exec($cmd . $symFile );
    unlink($symFile);
//    echo $cmd . $symFile;
    
//    header("Content-type: text/xml");
    echo $output;
