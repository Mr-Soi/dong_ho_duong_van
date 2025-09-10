$u=@(
 "https://donghoduongvan.com/",
 "https://donghoduongvan.com/Home/Intro",
 "https://donghoduongvan.com/Home/Charter",
 "https://donghoduongvan.com/Home/Contact")
foreach($x in $u){ $s=Invoke-WebRequest -Uri $x -Method Head -UseBasicParsing; "{0} {1}" -f $s.StatusCode,$x }
