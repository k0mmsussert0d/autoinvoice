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
                    <th>Filename</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Default</td>
                </tr>
            </tbody>
        </table>
    </div>
 </body>
</html>