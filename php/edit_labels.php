<?php
    include_once( "var.php" );

    function getFieldLabel( $varname ) {
        if( $LANG = "pl_PL" ) {
            $strings = [
                "issuer_name" => "Nazwa wystawcy",
                "issuer_street" => "Adres wystawcy - ulica",
                "issuer_zip" => "Adres wystawcy - kod pocztowy",
                "issuer_city" => "Adres wystawcy - miasto",
                "issuer_iban" => "Numer rachunku wystawcy",
                "issuer_swift" => "Kod SWIFT banku wystawcy",
                "issuer_phone" => "Numer telefonu wystawcy",
                "issuer_tax" => "NIP wystawcy",
                "print_no" => "Ilość cyfr w numerze porządkowym",
                "ordinal_no" => "Źródło numeru porządkowego",
                "invoice_no" => "Format pełnego numeru faktury",
                "buyer_name" => "Nazwa odbiorcy",
                "buyer_street" => "Adres odbiorcy - ulica",
                "buyer_zip" => "Adres odbiorcy - kod pocztowy",
                "buyer_city" => "Adres odbiorcy - miasto",
                "buyer_tax" => "NIP odbiorcy",
                "issue_city" => "Miasto wystawienia",
                "issue_date" => "Data wystawienia",
                "service_date" => "Data wykonania usługi",
                "payment_method" => "Sposób płatności",
                "deadline_date" => "Ilość dni do terminu zapłaty",
                "curr" => "Waluta",
                "comments" => "Uwagi",
                "item_name" => "Nazwa przedmiotu/usługi",
                "item_unit" => "Jednostka",
                "item_quan" => "Ilość",
                "item_price_netto" => "Cena netto",
                "item_tax_rate" => "Wartość podatku",
                "on_day" => "Wystawiana dnia",
                "rtf_template" => "Szablon faktury",
                "mail_template" => "Szablon maila",
                "mail_to" => "Odbiorcy wiadomości",
                "mail_bbc" => "Odbiorcy wiadomości (UDW)",
                "mail_subject" => "Temat wiadomości",
            ];
        }

        if( array_key_exists( $varname, $strings ) ) {
            return $strings[ $varname ];
        } else {
            return $varname;
        }
    }
?>