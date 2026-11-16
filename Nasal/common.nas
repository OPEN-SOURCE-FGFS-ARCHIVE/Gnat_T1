var common_ten_ps_loop = func { 

	setprop("velocities/vertical-speed-fpm", 60*getprop("/velocities/vertical-speed-fps") ) ;
# --------------------------------------------------------------------------- Level Change		
	if(getprop("/afcs/level_change") == 1){
		var targetAlt  = getprop("/autopilot/settings/target-altitude-ft");
		var currentAlt = getprop("/position/altitude-ft");
		var targetFpm  = getprop("/autopilot/settings/vertical-speed-fpm");
		var altDiff    = targetAlt - currentAlt ;
		# aim for 6 sec level-off within 200ft (2000fpm = 200ft per 6 seconds )
		if(altDiff >= -200 and 200 >= altDiff){ # we're done
			setprop("/autopilot/locks/altitude", 'altitude-hold');
			setprop("/afcs/level_change", 0);
		}else{
			setprop("/autopilot/locks/altitude", 'vertical-speed-hold');
		}
	}
	# for needles on webpanel instrument
	var h0 = getprop("/orientation/heading-deg");
	var h1 = getprop("/instrumentation/nav/heading-deg");
	var h2 = getprop("/instrumentation/nav[1]/heading-deg");
	
	setprop("/afcs/VOR1", -h0 + h1);
	setprop("/afcs/VOR2", -h0 + h2);
	
# --------------------------------------------------------------------------- 		

	
	
	
	
	settimer(common_ten_ps_loop, 0.10);
}

var common_stop_watch = func { # ----------------------- every second 
	var newSecond = getprop("/afcs/timerSeconds") + 1 ;
	if (newSecond == 60) {
		setprop("/afcs/timerMinutes", getprop("/afcs/timerMinutes") +1 );
		newSecond = 0;
	}
	setprop("/afcs/timerSeconds", newSecond );
	if (newSecond > 9){
		setprop("/afcs/timerReadout", getprop("/afcs/timerMinutes") ~ ':' ~ newSecond);
	}
	else{
		setprop("/afcs/timerReadout", getprop("/afcs/timerMinutes") ~ ':0' ~ newSecond);
	}
	var active = getprop("autopilot/route-manager/active") ;
	var maxID      = getprop("autopilot/route-manager/route/num") - 2 ;
	var wp_current = getprop("autopilot/route-manager/current-wp") ;
	if( active == 1 and maxID >= wp_current){
		var wp_next    = wp_current + 1 ;
		var wp_path    = 'autopilot/route-manager/route/wp[' ~ wp_next ~ ']/leg-bearing-true-deg' ;
		var brg_next = math.round( getprop(wp_path) );
		var wp_path    = 'autopilot/route-manager/route/wp[' ~ wp_next ~ ']/id' ;
		var id_next = getprop(wp_path);	
		var txt = 'next brg = '  ~ brg_next ~ ', to: '  ~ id_next ;
		setprop("navigation/next_up", txt) ;
	}
		
	# this only works if the relevant tile has been LOADED!!
	setprop("/afcs/WP_Alt", 0);
	setprop("/afcs/WP_Alt_diff", 0);
	if(getprop("/instrumentation/gps/wp/wp[1]/ID") != '')
	{ 
		#var WP_ID = getprop("/instrumentation/gps/wp/wp[1]/ID") ;
		#print (WP_ID) ;
		setprop("/afcs/WP_Alt", 1);
		setprop("/afcs/WP_Alt_diff", 1);
		WP_Lat = getprop("/instrumentation/gps/wp/wp[1]/latitude-deg") ;
		WP_Lon = getprop("/instrumentation/gps/wp/wp[1]/longitude-deg") ;
		#print (WP_Lat) ;
		#print (WP_Lon) ;
		var info = geodinfo(WP_Lat,  WP_Lon)  ;
		if ( info[0] == nil ){ 
			setprop("/afcs/WP_Alt", 2); 
			setprop("/afcs/WP_Alt_diff", 2);
			return ;
		}
		#debug.dump(info);		
		WP_Alt = int(info[0] * 3.280839895) ;
		#gui.popupTip(WP_Alt, 3);
		#print (WP_Alt) ;
		setprop("/afcs/WP_Alt", WP_Alt);
		WP_Alt_diff = WP_Alt - int(getprop("/position/altitude-ft"))  ;
		setprop("/afcs/WP_Alt_diff", WP_Alt_diff);

	}	
	
	settimer(common_stop_watch, 1.00);	
}


var common_every_ten_seconds = func { # ----------------------- every ten seconds
	var myLat = getprop("/position/latitude-deg") ;
	myLat = sprintf("%.6f", myLat) ;
	var myLon = getprop("/position/longitude-deg") ;
	myLon = sprintf("%.6f", myLon) ;
	var myAlt = getprop("/position/altitude-ft") ;
	myAlt = math.floor(myAlt) ;
	var myHdg = getprop("/orientation/heading-magnetic-deg");
	myHdg = math.floor(myHdg) ;
	var myMach = getprop("/velocities/mach") ;
	myMach = sprintf("%.2f", myMach) ;
	var logFileText = "--lat=" ~ myLat ~ " --lon=" ~ myLon ~ " --altitude=" ~ myAlt  ~ " --heading=" ~ myHdg ~ " --mach=" ~ myMach;
	var path = getprop("/sim/fg-home") ~ '/Export/positionLogger.txt';
	var file = io.open(path, "wb"); # open in write mode
	io.write(file, logFileText); # write the data
	

	
	
	settimer(common_every_ten_seconds, 10.00);	
}


setlistener("/sim/signals/fdm-initialized", func { # ====================== initialization
	
	setprop("/afcs/fms", 0);
	setprop("/afcs/WP_Alt", 0);
	setprop("/afcs/WP_Alt_diff", 0);
	setprop("/afcs/level_change", 0);
	setprop("/autopilot/settings/target-altitude-ft", int(1000+getprop("/position/altitude-ft")));		
	setprop("/autopilot/settings/vertical-speed-fpm", 1000);
      		
	setprop("/afcs/timerSeconds", 0);
    setprop("/afcs/timerMinutes", 0);
    setprop("/afcs/timerReadout", 0 ~ ':' ~ 0);
    setprop("/afcs/smoke/on", 0);
    setprop("/afcs/VOR1", 0);
    setprop("/afcs/VOR2", 0);
    setprop("/instrumentation/nav/heading-deg", 0);
	setprop("/instrumentation/nav[1]/heading-deg", 0);
    
	common_ten_ps_loop(); # things than need doing ten-times per second.
    common_stop_watch() ; # things than need doing ONCE every second.
	common_every_ten_seconds();  # things than need doing every ten seconds.
})

	

