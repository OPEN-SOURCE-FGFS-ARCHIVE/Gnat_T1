# =====
# Doors
# =====

Doors = {};

Doors.new = func {
   obj = { parents : [Doors],
           crew : aircraft.door.new("instrumentation/doors/crew", 4.5)
         };
   return obj;
};

Doors.crewexport = func {
   if ( getprop("/velocities/airspeed-kt") < 70  or getprop("instrumentation/doors/crew/position-norm") > 0.05 ) {
     me.crew.toggle();
   } else {
     if ( getprop("/velocities/airspeed-kt") >= 70 ) {
       setprop("/tmp/alarm/beep_once",1);
       screen.log.write("Airspeed too high !!");
     }
   }
}

# ==============
# Initialization
# ==============

# objects must be here, otherwise local to init()
doorsystem = Doors.new();

# without this toggle needs 2 calls after start
# don't really understand why
doorsystem.crewexport();
