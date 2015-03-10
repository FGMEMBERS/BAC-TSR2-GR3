#--------------------------------------------------------------------
var start_up = func {
  settimer(initialise_drop_view_pos, 5);
  settimer(yaw_monitor, 5);
  setlistener("/autopilot/locks/altitude", altitude_hold_monitor);
  setlistener("/autopilot/locks/heading", heading_hold_monitor);
  var dialog = gui.Dialog.new("/sim/gui/dialogs/BAC-TSR2/TFA-popup/dialog",
               "Aircraft/BAC-TSR2/Dialogs/TFA-popup.xml");
}
#--------------------------------------------------------------------
