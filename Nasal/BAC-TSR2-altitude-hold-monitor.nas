#--------------------------------------------------------------------
var altitude_hold_monitor = func(n) {
  # This listener script monitors the altitude-hold mode and
  # sets/clears the appropriate A/P locks for pitch and vfps.

  var alt_mode =    n.getValue();
  var aoa_lock =    props.globals.getNode("/autopilot/locks/aoa", 1);
  var hdg_lock =    props.globals.getNode("/autopilot/locks/heading", 1);
  var pitch_lock =  props.globals.getNode("/autopilot/locks/pitch", 1);
  var roll_lock =   props.globals.getNode("/autopilot/locks/roll", 1);
  var rudder_lock = props.globals.getNode("/autopilot/locks/rudder", 1);
  var vfps_lock =   props.globals.getNode("/autopilot/locks/vfps", 1);
  var tgt_vfps =    props.globals.getNode("/autopilot/settings/target-climb-rate-fps", 1);

  if(alt_mode == "") {
    aoa_lock.setValue("off");
    hdg_lock.setValue("");
    pitch_lock.setValue("off");
    roll_lock.setValue("off");
    rudder_lock.setValue("off");
    vfps_lock.setValue("off");
    tgt_vfps.setValue(0);
    tfa_off();
  } else {
    if(alt_mode == "pitch-hold") {
      pitch_lock.setValue("engaged");
      vfps_lock.setValue("off");
      tfa_off();
    } else {
      if(alt_mode == "vfps-hold") {
        pitch_lock.setValue("engaged");
        vfps_lock.setValue("engaged");
        tfa_off();
      } else {
        if(alt_mode == "altitude-hold") {
          pitch_lock.setValue("engaged");
          vfps_lock.setValue("engaged");
          tfa_off();
        } else {
          if(alt_mode == "agl-hold") {
            pitch_lock.setValue("engaged");
            vfps_lock.setValue("engaged");
            tfa_engaged();
          } else {
            if(alt_mode == "gs1-hold") {
              pitch_lock.setValue("engaged");
              vfps_lock.setValue("engaged");
              tfa_off();
            } else {
              if(alt_mode == "rotate") {
                pitch_lock.setValue("off");
                vfps_lock.setValue("off");
                tfa_off();
              }
            }
          }
        }
      }
    }
  }
}
#--------------------------------------------------------------------
var tfa_engaged = func {
  var current_alt_ft = getprop("/position/altitude-ft");
  var tfa_mode =       getprop("/instrumentation/terrain-radar/settings/mode");
  setprop("/autopilot/settings/target-climb-rate-fps", 0);
  setprop("/autopilot/internal/target-tfa-altitude-ft", current_alt_ft);
  setprop("/instrumentation/terrain-radar/settings/state", "on");

  # Start the collision monitor.
  settimer(collision_monitor, 0.5);

  # Check the mode and start the appropriate loop.
  if(tfa_mode == "extend") {
    settimer(tfa_radar_extend_mode_loop, 0.1);
  } else {
    if(tfa_mode == "continuous") {
      settimer(tfa_radar_continuous_mode_loop, 0.1);
    }
  }
}
#--------------------------------------------------------------------
var tfa_off = func {
  setprop("/instrumentation/terrain-radar/settings/state", "off");
  setprop("/instrumentation/terrain-radar/hi-elev/alt-ft", -9999.9);
  setprop("/instrumentation/terrain-radar/hi-elev/lat-deg", -9999.9);
  setprop("/instrumentation/terrain-radar/hi-elev/lon-deg", -9999.9);
  setprop("/instrumentation/terrain-radar/hi-elev/dist-m", -9999.9);
  setprop("/instrumentation/terrain-radar/hi-elev/collision-status", "");
  setprop("/autopilot/internal/target-tfa-altitude-ft", -9999.9);
}
#--------------------------------------------------------------------
