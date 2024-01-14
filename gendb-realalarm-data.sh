#!/usr/bin/php
<?php
date_default_timezone_set('Asia/Kuala_Lumpur');

$maxGetbulkRepeats=0
$maxGetbulkResponses=500

$subsystem = array( 
	1 => array(
		1 => array(
			"totalAlarm" => 33,
			"subsystemName" => "BTN",
			"equipmentName" => "Core switch",
			)
		2 => 4,
		3 => 4,
		4 => 4,
		5 => 4,
		6 => 4,
		7 => 4,
		8 => 4,
		),

	2 => array(
		1 => 19,
		)


	)

echo "rwcommunity public"
echo "maxGetbulkRepeats $maxGetbulkRepeats"
echo "maxGetbulkResponses $maxGetbulkResponses"

for($subsystemoid=0, $subsystemoid <= $total_subsystem, $subsystemoid += 1){
        echo "override -rw 1.3.6.1.4.1.22835.${subsystemoid}.${equipmentoid}.${alarmoid} integer 0"
}
