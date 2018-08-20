<?php
    include_once( "var.php" );
    include_once( "edit_labels.php" );

    if( $_GET ) {
        $filename = $APP_ROOT."/conf-available/".$_GET[ 'config' ];
        $file_array = file( $filename, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES );
    }
?>

<!doctype html>
<html lang="en">
  <head>
    <title>autoinvoice – Control Panel</title>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
   </head>
  <body>
    <script>
        var i = 1;

        function addRow() {
            var left = "Nazwa nowej wartości";
            var right = "Wartość";
            
            var table = document.getElementById("list").getElementsByTagName("tbody")[0];
            var row = table.insertRow(table.rows.length);
            var cell1 = row.insertCell(0);
            var cell2 = row.insertCell(1);
            cell1.innerHTML = "<input type=\"text\" name=\"" + "val" + i + "\" value=\"" + left + "\" />";
            cell2.innerHTML = "<input type=\"text\" name=\"" + "var" + i + "\" value=\"" + right + "\" />";
            i++;
        }
    </script>
    <nav class="navbar navbar-default navbar-fixed-top">
        <div class="container-fluid">
          <div class="navbar-header">
            <a class="navbar-brand" href="#">autoinvoice – Control Panel</a>
          </div>
          <ul class="nav navbar-nav">
            <li class="active"><a href="#">Home</a></li>
            <li><a href="configs.php">Configs</a></li>
            <li><a href="history.php">History</a></li>
          </ul>
          <ul class="nav navbar-nav navbar-right">
            <li><a href="login.html"><span class="glyphicon glyphicon-log-in"></span> Login</a></li>
          </ul>
        </div>
    </nav>
    <div class="container" style="padding-left: 200px; padding-right: 200px; margin-top: 50px;">
        <form action="save.php" method="GET">
            <table class="table table-bordered" id="list">
                <thead>
                    <tr>
                        <th width="35%">Variable name</th>
                        <th width="65%">Value</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                        $i = 0;
                        foreach( $file_array as $line_number => $line ) {
                            if( $line[ 0 ] != '#' ) {
                                list( $var, $val ) = explode( '=', $line );
                                echo "<tr>\n\t<td>".getFieldLabel( $var );
                                echo "</td>\n";
                                echo "\t<td><input type=\"text\" name=\"".$var."\" value=\"".trim( $val, "\"")."\" /></td>\n</tr>\n";
                            } else {
                                echo "<input type=\"hidden\" name=\"hidden[".$i++."]\" value=\"".$line."\" />";
                            }
                        }
                    ?>
                </tbody>
            </table>
            <div class="pull-left">
                <input type="button" class="btn btn-info" value="Add row" onclick="addRow();" />
            </div>
            <div class="pull-right">
                <input type="submit" class="btn btn-info" value="Save" style="text-align: right;">
            </div>
        </form>
    </div>
 </body>
</html>