<?php
    session_start();
    if( $_POST && $_SESSION ) {
        $filename = $_SESSION[ "filename" ];
        file_put_contents( $filename, "" ); //clear file
        foreach( $_POST as $K => $V ) {
            $com = 0;
            $pos = strpos( $K, "&" );
            if( $K[ 0 ] == "^" ) {
                $com = 1;
            } else if( $pos ) {
                $K = substr( $K, 0, $pos );
            }
            if( !$com ) {
                $V = "\"".$V."\"";
                file_put_contents( $filename, $K."=".$V."\n", FILE_APPEND );
            } else {
                file_put_contents( $filename, $V."\n", FILE_APPEND );
            }
        }
    }
    session_abort();
?>