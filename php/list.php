<?php
    include_once( "var.php" );

    $conf_avaiable_dir = $APP_ROOT."/conf-available";
    $conf_avaiable_list = dir( $conf_avaiable_dir );

    $conf_enabled_dir = $APP_ROOT."/conf-enabled";
    $conf_enabled_list = dir( $conf_enabled_dir );

    while( false !== ( $entry = $conf_avaiable_list->read() ) ) {
        if( substr( $entry, 0, 1 ) === "." ) {
            continue;
        }
        echo $entry."\n";
    }
?>