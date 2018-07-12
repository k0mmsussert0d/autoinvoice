<?php
    include_once( "var.php" );

    $conf_avaiable_dir = $APP_ROOT."/conf-available";
    $conf_avaiable_list = scandir( $conf_avaiable_dir );

    $conf_enabled_dir = $APP_ROOT."/conf-enabled";
    $conf_enabled_list = scandir( $conf_enabled_dir );
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
    <nav class="navbar navbar-default navbar-fixed-top">
        <div class="container-fluid">
          <div class="navbar-header">
            <a class="navbar-brand" href="#">autoinvoice – Control Panel</a>
          </div>
          <ul class="nav navbar-nav">
            <li><a href="#">Home</a></li>
            <li class="active"><a href="configs.php">Configs</a></li>
            <li><a href="history.php">History</a></li>
          </ul>
          <ul class="nav navbar-nav navbar-right">
            <li><a href="login.html"><span class="glyphicon glyphicon-log-in"></span> Login</a></li>
          </ul>
        </div>
    </nav>
    <div class="container" style="padding-left: 200px; padding-right: 200px; margin-top: 50px;">
        <h2>Available configuration files</h2>
        <p>This is a list of available configuration files from <i>conf-avaialable</i> directory.<br />
            Enabled files (linked in <i>conf-enabled</i>) are marked as green.</p>
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th width="90%">Filename</th>
                    <th width="10%">Enabled</th>
                </tr>
            </thead>
            <tbody>
                <?php
                    foreach( $conf_avaiable_list as $V ) {
                        if( substr( $V, 0, 1 ) === "." ) {
                            continue;
                        }

                        echo "<tr>\n<td>".$V."</td>\n<td>";
                        echo "<input type=\"checkbox\" name=\"enabled\" value=\"".$V."\" ";
                        if( in_array( $V, $conf_enabled_list ) ) {
                            echo "checked ";
                        }
                        echo "/>";
                        echo "</td></tr>\n";
                    }
                ?>
            </tbody>
        </table>
    </div>
 </body>
</html>