var gear_indicators_loop = func { 

	var gear0     = getprop("/gear/gear/position-norm");
	var gear1     = getprop("/gear/gear[1]/position-norm");
	var gear2     = getprop("/gear/gear[2]/position-norm");
	var gearTotal = (gear0 +  gear1 + gear2) ;
		
	if (gear0 == 1){
		setprop("/Gnat_T1/gear0_DN", 1);
		setprop("/Gnat_T1/gear0_UP", 0);
	}
	if (gear0 == 0){
		setprop("/Gnat_T1/gear0_DN", 0);
		setprop("/Gnat_T1/gear0_UP", 1);
	}
	if (gear0 > 0 and gear0 < 1){ # transit
		setprop("/Gnat_T1/gear0_DN", 0);
		setprop("/Gnat_T1/gear0_UP", 0);		
	}	
	
	if (gear1 == 1){
		setprop("/Gnat_T1/gear1_DN", 1);
		setprop("/Gnat_T1/gear1_UP", 0);
	}
	if (gear1 == 0){
		setprop("/Gnat_T1/gear1_DN", 0);
		setprop("/Gnat_T1/gear1_UP", 1);
	}
	if (gear1 > 0 and gear1 < 1){ # transit
		setprop("/Gnat_T1/gear1_DN", 0);
		setprop("/Gnat_T1/gear1_UP", 0);		
	}	
	
	if (gear2 == 1){
		setprop("/Gnat_T1/gear2_DN", 1);
		setprop("/Gnat_T1/gear2_UP", 0);
	}
	if (gear2 == 0){
		setprop("/Gnat_T1/gear2_DN", 0);
		setprop("/Gnat_T1/gear2_UP", 1);
	}	
	if (gear2 > 0 and gear2 < 1){ # transit
		setprop("/Gnat_T1/gear2_DN", 0);
		setprop("/Gnat_T1/gear2_UP", 0);		
	}	
	
	if (gearTotal > 0 and gearTotal < 3){ # transit
		setprop("/Gnat_T1/gearTransit", 1);	
	}
	else { 
		setprop("/Gnat_T1/gearTransit", 0);
	}# all done
			
	settimer(gear_indicators_loop, 0.2);
}

setlistener("/sim/signals/fdm-initialized", func { # ====================== initialization
	
	setprop("/Gnat_T1/gear0_DN", 1);
	setprop("/Gnat_T1/gear1_DN", 1);
	setprop("/Gnat_T1/gear2_DN", 1);
	setprop("/Gnat_T1/gearTransit", 0);
	setprop("/Gnat_T1/gear0_UP", 0);
	setprop("/Gnat_T1/gear1_UP", 0);
	setprop("/Gnat_T1/gear2_UP", 0);	
	
	setprop("/gear/gear/position-norm",    1);
	setprop("/gear/gear[1]/position-norm", 1);
	setprop("/gear/gear[2]/position-norm", 1);	
	
	gear_indicators_loop(); 
	
	print ("Gnat_T1 loaded");
    
})
