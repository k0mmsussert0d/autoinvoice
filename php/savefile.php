<?php
    session_start();
    if( $_POST && $_SESSION ) {
        $filename = $_SESSION[ "filename" ];
        file_put_contents( $filename, "" ); //clear file
        foreach( $_POST as $K => $V ) {
            echo $K."=>".$V."\n";
            if( substr( $K, 0, 6 ) === "hidden" ) {
                continue;
            } else {
                file_put_contents( $filename, $K."="."\"".$V."\"\n", FILE_APPEND );
            }
        }
    }
    session_abort();
?>