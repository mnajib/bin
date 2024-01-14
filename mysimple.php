<?php
/**
 * Simple PHP MySQL Client
 * Copyright (c) 2007, Andreas Gohr <andi (at) splitbrain.org>
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 *   * Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *
 *   * Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *
 *   * Neither the name of Andreas Gohr nor the names of other contributors may
 *     be used to endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
 
    // disable magic quotes
    if (get_magic_quotes_gpc() && !defined('MAGIC_QUOTES_STRIPPED')){
        $_POST = array_map('stripslashes',$_POST);
    }
 
    if(!$_POST['db_host']) $_POST['db_host'] = 'localhost';
?>
<html>
<head>
    <title>MySimple</title>
    <style type="text/css">
        body {
            font: 90% sans-serif;
        }
 
        table {
            font: 90% sans-serif;
            border-right: 1px solid #000;
            border-top: 1px solid #000;
            empty-cells: show;
        }
        td, th {
            border-left: 1px solid #000;
            border-bottom: 1px solid #000;
            padding: 0.2em 0.5em;
        }
        input, textarea, fieldset {
            border: 1px solid #333;
        }
    </style>
</head>
<body>
    <form action="" method="post">
    <fieldset>
        <legend>Database Connection</legend>
 
        <label for="db_host">Host:</label>
        <input type="text" name="db_user" value="<?php echo htmlspecialchars($_POST['db_host'])?>" />
 
        <label for="db_name">Database:</label>
        <input type="text" name="db_name" value="<?php echo htmlspecialchars($_POST['db_name'])?>" />
 
        <label for="db_user">User:</label>
        <input type="text" name="db_user" value="<?php echo htmlspecialchars($_POST['db_user'])?>" />
 
        <label for="db_pass">Password:</label>
        <input type="password" name="db_pass" value="<?php echo htmlspecialchars($_POST['db_pass'])?>" />
    </fieldset>
 
    <fieldset>
        <legend>Query</legend>
        <textarea name="query" style="width: 98%" rows="20"><?php echo htmlspecialchars($_POST['query'])?></textarea><br />
 
        <input type="submit" name="go" style="cursor: hand" /> (separate multiple queries with a semicolon at end of line)
    </fieldset>
 
    <?php
    // do the work
    if($_POST['go']){
        $ok = true;
        echo '<fieldset><legend>Results</legend>';
 
        // connect to db host
        $link = @mysql_connect($_POST['db_host'], $_POST['db_user'], $_POST['db_pass']);
        if(!$link){
            echo "<b>Could not connect: ".mysql_error()."</b><br />";
            $ok = false;
        }else{
            echo "<b>Connected to host</b><br />";
        }
 
        // select database
        if($ok){
            if($_POST['db_name']){
                if(!@mysql_select_db($_POST['db_name'])){
                    echo "<b>Could not select DB: ".mysql_error()."</b><br />";
                    $ok = false;
                }else{
                    echo "<b>Database selected</b><br />";
                }
            }
        }
 
        // run queries
        if($ok){
            if($_POST['query']){
                $queries = preg_split("/;(\r\n|\r|\n)/s",$_POST['query']);
                $queries = array_filter($queries);
 
                foreach($queries as $query){
                    echo '<hr >';
                    $result = @mysql_query($query);
                    if(!$result){
                        echo "<b>Query failed: ".mysql_error()."</b><br /><pre>".htmlspecialchars($query)."</pre><br />";
                    }else{
                        echo '<b>'.mysql_affected_rows($link).' affected rows</b><br />';
 
                        if($result != 1){
                            echo '<table cellpadding="0" cellspacing="0">'."\n";
                            $first = true;
                            while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
                                if($first){
                                    echo "\t<tr>\n";
                                    foreach (array_keys($line) as $col_value) {
                                        echo "\t\t<th>".htmlspecialchars($col_value)."</th>\n";
                                    }
                                    echo "\t</tr>\n";
                                    $first = false;
                                }
                                echo "\t<tr>\n";
                                foreach ($line as $col_value) {
                                    echo "\t\t<td>".htmlspecialchars($col_value)."</td>\n";
                                }
                                echo "\t</tr>\n";
                            }
                            echo "</table>\n";
                        }
                    }
                }
            }
        }
 
        echo '</pre></fieldset>';
    }
    ?>
    </form>
</body>
</html>
