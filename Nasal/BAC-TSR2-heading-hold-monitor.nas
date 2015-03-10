#--------------------------------------------------------------------
var heading_hold_monitor = func(n) {
  # This listener script monitors the roll-hold mode and
  # sets/clears the appropriate A/P locks for roll.

  var roll_mode = n.getValue();
  var roll_lock = props.globals.getNode("/autopilot/locks/roll", 1);
  var tgt_roll =  props.globals.getNode("/autopilot/settings/target-roll-deg", 1);

  if(roll_mode == "") {
    roll_lock.setValue("off");
    tgt_roll.setValue(0);
  } else {
    if(roll_mode == "roll-hold") {
      roll_lock.setValue("engaged");
    } else {
      if(roll_mode == "true-heading-hold") {
        roll_lock.setValue("engaged");
      } else {
        if(roll_mode == "dg-heading-hold") {
          roll_lock.setValue("engaged");
        } else {
          if(roll_mode == "nav1-hold") {
            roll_lock.setValue("engaged");
          } else {
            if(roll_mode == "wing-leveler") {
              tgt_roll.setValue(0);
              roll_lock.setValue("engaged");
            }
          }
        }
      }
    }
  }
}
#--------------------------------------------------------------------
