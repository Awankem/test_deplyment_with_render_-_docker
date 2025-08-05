<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});



// Route::get('/scan-devices', function () {
//     $command = "arp -a";  // Ping scan in grepable format

//     $output = shell_exec($command);

//     return "<pre>{{ $output }}</pre>";
// });



Route::get('/scan-devices', function () {
    $command = "arp -a";
    $output = shell_exec($command);

    // Split the output into lines
    $lines = explode("\n", trim($output));

    $table = "<h2>ARP Table</h2>";
    $table .= "<table border='1' cellpadding='6' cellspacing='0'>";
    $table .= "<tr><th>IP Address</th><th>MAC Address</th><th>Type</th></tr>";

    foreach ($lines as $line) {
        if (preg_match('/\s*([^ ]+)\s+\(([^)]+)\)\s+at\s+([0-9a-f:]+)\s+\[(\w+)\]/i', $line, $matches)) {
            $host = $matches[1];      // host name
            $ip = $matches[2];        // IP address
            $mac = $matches[3];       // MAC address
            $type = $matches[4];      // e.g. "ether"

            $table .= "<tr><td>{$ip}</td><td>{$mac}</td><td>{$type}</td></tr>";
        }
    }

    $table .= "</table>";

    return $table;
});
