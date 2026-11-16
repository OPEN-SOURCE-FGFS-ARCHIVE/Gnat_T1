# ========================================================================================
#                 Slimmed down AFCS System for the Gnat_T1 by Warty, 2023
# ========================================================================================
var afcs_loop = func { 
	var           altRate = getprop("/velocities/vertical-speed-fps");
	var currentFlightMode = getprop("/afcs/flight-mode");
	var        currentAGL = getprop("/position/altitude-agl-ft"); 
	var        currentIAS = getprop("/velocities/airspeed-kt");
	
	# Put the gear and flaps up once take off is established	
	if(currentFlightMode == 'Take off' and currentAGL>=50 and altRate >= 10){
		setprop("/controls/gear/gear-down", 0);
		if(currentAGL >= 200 and currentIAS >= 120){
			setprop("/afcs/flight-mode", '-----');
			setprop("/controls/flight/flaps", 0.0 );
			setprop("/autopilot/locks/speed", "speed-with-throttle" );
			setprop("/autopilot/settings/target-speed-kt", 200); 
			s#etprop("/autopilot/locks/altitude", "altitude-hold" );
			#setprop("/autopilot/settings/target-altitude-ft", 500 + getprop("/position/altitude-ft"));
			#setprop("/autopilot/locks/heading", "dg-heading-hold" );
			#setprop("/autopilot/settings/heading-bug-deg", getprop("/orientation/heading-magnetic-deg"));			
		}
	}
	# Adjust flap dependent on airspeed for landing
	if(currentFlightMode == 'Landing' and 200 >= currentIAS ){
		setprop("/controls/flight/flaps", 1.00 - (currentIAS - 150)*0.01  );
		if(150 >= currentIAS ){
			setprop("/controls/flight/flaps", 1.00 ) ;
		}
	}
	# Cut power and AutoPilot once landing is established
	if(currentFlightMode == 'Landing' and 25 >= currentAGL){
		setprop("/autopilot/settings/target-speed-kt", 0);	
		setprop("/autopilot/locks/altitude", "");
		setprop("/autopilot/locks/heading", "");
		setprop("/autopilot/locks/speed", "");
		setprop("/controls/engines/engine/throttle", 0.0);
		setprop("/controls/gear/brake-parking", 1);
		setprop("/sim/current-view/field-of-view", 90.0); # was probably on zoom for landing
		setprop("/controls/flight/speedbrake", 0); # just in case (should not operate 
		#               on the ground because the gear doors are the air brakeso n a Gnat)

		if( 10 >= currentIAS){
			setprop("/afcs/flight-mode", "Taxi");
			setprop("/controls/engines/engine[0]/throttle", 0.10);;
			setprop("/controls/gear/brake-parking", 0);
		}
	}
    setprop("/afcs/counter", getprop("/afcs/counter")+1); # testing only
    var forDebug = getprop("/afcs/counter") ;
    
    ##### Blinkers should maybe be in the HUD Nasal as it is where they are used ??
    setprop("/afcs/Blink2HzCount", getprop("/afcs/Blink2HzCount")+1);
    if(getprop("/afcs/Blink2HzCount") == 5){
    	setprop("/afcs/Blink2HzCount", 0);
    	if(getprop("/afcs/Blinker2Hz") == 0){setprop("/afcs/Blinker2Hz", 1.0);}
    	else                                {setprop("/afcs/Blinker2Hz", 0.0);}
    }
    setprop("/afcs/Blink5HzCount", getprop("/afcs/Blink5HzCount")+1);
    if(getprop("/afcs/Blink5HzCount") == 2){
    	setprop("/afcs/Blink5HzCount", 0);
    	if(getprop("/afcs/Blinker5Hz") == 0){setprop("/afcs/Blinker5Hz", 1.0);}
    	else                                {setprop("/afcs/Blinker5Hz", 0.0);}
    }	
		settimer(afcs_loop, 0.05);	
	}
	
setlistener("/sim/signals/fdm-initialized", func { # ====================== initialization

	##################setprop("ai/models/aircraft[0]/position/altitude-ft", -200); #targetMarker
	#setprop("/sim/keytest", "WartAFCS");  # testing only
    setprop("/afcs/counter", 0);
  	setprop("/afcs/targetYawRate", 0);
  	setprop("/afcs/yaw", 0);
  	setprop("/afcs/hasGear", 1);
  	setprop("/afcs/screenXPhysical", 4.63); # PFD-Screen position
  	setprop("/afcs/flight-mode", '-----');
  	setprop("/afcs/Blink2HzCount", 0); setprop("/afcs/Blinker2Hz", 0);
  	setprop("/afcs/Blink5HzCount", 0); setprop("/afcs/Blinker5Hz", 0);
    setprop("/surface-positions/elevator-pos-norm", 0);
  	setprop("/canopy/position-norm", 0);
  	
	# force radar debug-mode on (forced radar calculations even if
    # no radar instrument and AI aircraft are out of range
    setprop("/instrumentation/radar/debug-mode", 1);
    
    engines.engine1.autostart();
      		
	afcs_loop();

    
})
