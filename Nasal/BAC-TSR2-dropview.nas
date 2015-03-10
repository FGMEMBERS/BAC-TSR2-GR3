#--------------------------------------------------------------------
var initialise_drop_view_pos = func {
  var eyelatdeg = getprop("/position/latitude-deg");
  var eyelondeg = getprop("/position/longitude-deg");
  var eyealtft = getprop("/position/altitude-ft") + 20;
  setprop("/sim/view[101]/latitude-deg", eyelatdeg);
  setprop("/sim/view[101]/longitude-deg", eyelondeg);
  setprop("/sim/view[101]/altitude-ft", eyealtft);
}
#--------------------------------------------------------------------
var update_drop_view_pos = func {
  var eyelatdeg = getprop("/position/latitude-deg");
  var eyelondeg = getprop("/position/longitude-deg");
  var eyealtft = getprop("/position/altitude-ft") + 20;
  interpolate("/sim/view[101]/latitude-deg", eyelatdeg, 5);
  interpolate("/sim/view[101]/longitude-deg", eyelondeg, 5);
  interpolate("/sim/view[101]/altitude-ft", eyealtft, 5);
}
#--------------------------------------------------------------------
