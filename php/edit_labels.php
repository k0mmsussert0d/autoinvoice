<?php
    include_once( "var.php" );

    function getFieldLabel( $varname ) {
        if( $LANG = "pl_PL" ) {
            switch( $varname ) {
                case "issuer_name": return "Nazwa wystawcy";
                case "issuer_street": return "Adres wystawcy - ulica";
                case "issuer_zip": return "Adres wystawcy - kod pocztowy";
                case "issuer_city": return "Adres wystawcy - miasto";
                case "issuer_iban": return "Numer rachunku wystawcy";
                case "issuer_swift": return "Kod SWIFT banku wystawcy";
                case "print_no": return "Ilość cyfr w numerze porządkowym faktury";
                case "ordinal_no": return "Źródło numeru porządkowego";
                case "invoice_no": return "Format pełnego numeru faktury";
                case "buyer_name": return "Nazwa odbiorcy";
                case "buyer_street": return "Adres odbiorcy - ulica";
                default: return $varname;
            }
        }
    }
?>