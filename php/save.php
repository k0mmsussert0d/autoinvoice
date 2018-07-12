<?php
    include_once( "var.php" );

    $conf_avaiable_dir = $APP_ROOT."/conf-available";
    $conf_avaiable_list = scandir( $conf_avaiable_dir );

    $conf_enabled_dir = $APP_ROOT."/conf-enabled";
    $conf_enabled_list = scandir( $conf_enabled_dir );
    
    if( $_GET ) {
        $to_enable = $_GET[ 'enabled' ];
        foreach( $conf_enabled_list as $V ) {
            if( !in_array( $V, $to_enable ) ) {
                exec( "cd ".$APP_ROOT."/conf-enabled && rm ".$V );
            }
        }
        
        foreach( $to_enable as $V ) {
            if( !in_array( $V, $conf_enabled_list ) ) {
                $output = array();
                //echo "cd ".$APP_ROOT."/conf-enabled && ln -s ../conf-available/".$V." ".$V;
                exec( "cd ".$APP_ROOT."/conf-enabled && ln -s ../conf-available/".$V." ".$V, $output );
            }
        }
    }
    header('Location: configs.php');
?>