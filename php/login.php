<?php
// Initialize empty variables
$username = $password = "";
$username_err = $password_err = "";

if( $_SERVER[ "REQUEST_METHOD" ] == "POST" ) {
    // Check if crenedtials are empty
    $username = trim( $_POST[ "username" ] );
    if( empty( $username ) ) {
        $username_err = "Please enter your username.";
    }

    $password = trim( $_POST[ "password" ] );
    if( empty( $password ) ) {
        $password_err = "Please enter your password.";
    }

    if( empty( $username_err ) && empty( $password_err ) ) {
        if( $username === "testuser" && $password === "testpass" ) {
            session_start();
            $_SESSION[ "username" ] = $username;
            header("location: control.html");
        } else {
            $password_err = "The password you entered is not valid.";
        }
    }
}
?>