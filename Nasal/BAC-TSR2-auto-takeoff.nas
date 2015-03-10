#--------------------------------------------------------------------
var autotakeoff = func {
  if(getprop("/autopilot/locks/auto-takeoff") == "enabled") {
    ato_start();
  }
}
#--------------------------------------------------------------------
var ato_start = func {
  # This script checks that the ground-roll-heading has been reset
  # (<-999) and that the a/c is on the ground.
  if(getprop("/autopilot/settings/ground-roll-heading-deg") < -999) {
    if(getprop("/position/gear-agl-ft") < 0.1) {
      var hdgdeg = getprop("/orientation/heading-deg");
      setprop("/autopilot/settings/ground-roll-heading-deg", hdgdeg);
      setprop("/autopilot/settings/true-heading-deg", hdgdeg);
      setprop("/autopilot/settings/target-speed-kt", 350);
      setprop("/autopilot/settings/target-pitch-deg", 0.1);
      setprop("/autopilot/locks/altitude", "ground-roll");
      setprop("/autopilot/locks/speed", "speed-with-throttle");
      setprop("/autopilot/locks/heading", "wing-leveler");
      setprop("/autopilot/locks/rudder", "heading-hold");
      setprop("/autopilot/locks/auto-takeoff", "engaged");
      setprop("/controls/flight/flaps", 0.64);
      setprop("/controls/flight/spoilers", 0);
      setprop("/controls/gear/brake-left", 0);
      setprop("/controls/gear/brake-right", 0);
      setprop("/controls/gear/brake-parking", 0);
      settimer(ato_main_loop, 0.5);
    }
  }
}
#--------------------------------------------------------------------
var ato_main_loop = func {
  var ato_status = props.globals.getNode("/autopilot/locks/auto-takeoff", 1);

  ato_spddep();

  # Test and re-schedule the next loop.
  if(ato_status.getValue() == "engaged") {
    settimer(ato_main_loop, 0.1);
  }
}
#--------------------------------------------------------------------
var ato_spddep = func {
  # This script controls speed dependent actions.
  # Get the nodes.
  var altitude_lock = props.globals.getNode("/autopilot/locks/altitude", 1);
  var heading_lock =  props.globals.getNode("/autopilot/locks/heading", 1);
  var speed_lock =    props.globals.getNode("/autopilot/locks/speed", 1);
  var rudder_lock =   props.globals.getNode("/autopilot/locks/rudder", 1);
  var ato_lock =      props.globals.getNode("/autopilot/locks/auto-takeoff", 1);
  var atl_lock =      props.globals.getNode("/autopilot/locks/auto-landing", 1);
  var tgt_pitch_set = props.globals.getNode("/autopilot/settings/target-pitch-deg", 1);
  var flap_ctl =      props.globals.getNode("/controls/flight/flaps", 1);
  var rudder_ctl =    props.globals.getNode("/controls/flight/rudder", 1);
  var gear_ctl =      props.globals.getNode("/controls/gear/gear-down", 1);
  var airspeed =      props.globals.getNode("/velocities/airspeed-kt", 1);
  var rotate_spd_kt = props.globals.getNode("/autopilot/settings/rotate-speed-kt", 1);
  var rotate_deg =    props.globals.getNode("/autopilot/settings/rotate-deg", 1);

  # Many of the node values are tested multiple times so read them once.
  var rlck = rudder_lock.getValue();
  var pset = tgt_pitch_set.getValue();
  var fctl = flap_ctl.getValue();
  var rctl = rudder_ctl.getValue();
  var gctl = gear_ctl.getValue();
  var aspd = airspeed.getValue();
  var rspd = rotate_spd_kt.getValue();
  var rdeg = rotate_deg.getValue();

  if(aspd < 40) {
    altitude_lock.setValue("ground-roll");
    flap_ctl.setValue(0.64);
  } else {
    if(aspd < rspd) {
      rudder_lock.setValue("heading-hold");
      altitude_lock.setValue("pitch-hold");
      tgt_pitch_set.setValue(1.1);
      flap_ctl.setValue(0.64);
    } else {
      if(aspd < 155) {
        altitude_lock.setValue("pitch-hold");
        tgt_pitch_set.setValue(rdeg);
        flap_ctl.setValue(0.64);
      } else {
        if(aspd < 160) {
          altitude_lock.setValue("pitch-hold");
          tgt_pitch_set.setValue(rdeg);
          flap_ctl.setValue(0.64);
        } else {
          if(aspd < 170) {
            altitude_lock.setValue("pitch-hold");
            tgt_pitch_set.setValue(rdeg);
            flap_ctl.setValue(0.64);
            if(rlck != "") {
              interpolate(rudder_ctl, 0, 10);
              rudder_lock.setValue("");
            }
          } else {
            if(aspd < 180) {
              flap_ctl.setValue(0.32);
              gear_ctl.setValue("false");
            } else {
              if(aspd < 190) {
                flap_ctl.setValue(0.16);
              } else {
                if(aspd < 200) {
                  flap_ctl.setValue(0.08);
                } else {
                  if(aspd < 210) {
                    flap_ctl.setValue(0.0);
                  } else {
                    if(aspd > 260) {
                      # Switch to true-heading-hold, speed-with-throttle,
                      # altitude-hold and disable Take-Off mode.
                      heading_lock.setValue("true-heading-hold");
                      speed_lock.setValue("speed-with-throttle");
                      altitude_lock.setValue("altitude-hold");
                      ato_lock.setValue("disabled");
                      atl_lock.setValue("enabled");
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
#--------------------------------------------------------------------
