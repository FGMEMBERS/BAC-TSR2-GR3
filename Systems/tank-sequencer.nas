


# ==================================== fuel tank stuff ===================================

###
# Initialize internal values
##
tank_1_col_port = nil;
tank_1_col_stbd = nil;
tank_1_port 	= nil;
tank_1_stbd 	= nil;
tank_1a_port 	= nil;
tank_1a_stbd 	= nil;
tank_2_port 	= nil;
tank_2_stbd 	= nil;
tank_3_port 	= nil;
tank_3_stbd 	= nil;
tank_4_port 	= nil;
tank_4_stbd 	= nil;
pinion_port 	= nil;
pinion_stbd 	= nil;



#variables
var amount_port = amount_stbd  = 0;
var amount_2_port = amount_2_stbd = 0;
var amount_3_port = amount_3_stbd = 0;
var amount_4_port = amount_4_stbd = 0;
var flowrate_lbs_hr = 9000; 
var time = 0;
var dt = 0;
var last_time = 0.0;

##
# Initialize the fuel system
#

init_fuel_system = func {
	print("Initializing Sea Vixen tank sequencer ...");


###
#tanks ("name", number, initial connection stauus)
###
    tank_1_col_port = Tank.new		( "tank_1_col_port", 0, 1 );
	tank_1_col_stbd = Tank.new		( "tank_1_col_stbd", 1, 1 );
	tank_1_port 	= Tank.new		( "tank_1_port", 2, 0 );
	tank_1_stbd 	= Tank.new		( "tank_1_stbd", 3, 0 );
	tank_1a_port 	= Tank.new		( "tank_1a_port", 4, 0);
	tank_1a_stbd 	= Tank.new		( "tank_1a_stbd", 5, 0 );
	tank_2_port 	= Tank.new		( "tank_2_port", 6, 0 );
	tank_2_stbd 	= Tank.new		( "tank_2_stbd", 7, 0 );
	tank_3_port 	= Tank.new		( "tank_3_port", 8, 0 );
	tank_3_stbd 	= Tank.new		( "tank_3_stbd", 9, 0 );
	tank_4_port 	= Tank.new		( "tank_4_port", 10, 0 );
	tank_4_stbd 	= Tank.new		( "tank_4_stbd", 11, 0 );
	pinion_port 	= Tank.new		( "pinion_port", 12, 0 );
	pinion_stbd 	= Tank.new		( "pinion_stbd", 13, 0 );

settimer(fuelTrans,0);

print ("Running Sea Vixen tank sequencer");

} # end intitialization

Tank = {
	new : func ( name, number, connect ) {
		var obj = { parents : [Tank]};
		obj.name = name;
		obj.prop = props.globals.getNode( "consumables/fuel" ).getChild ("tank", number );
		obj.capacity = obj.prop.getNode( "capacity-gal_us", 1 );
		obj.ppg = obj.prop.getNode("density-ppg", 1);
		obj.level_gal_us = obj.prop.getNode( "level-gal_us", 1 );
		obj.level_lbs = obj.prop.getNode( "level-lbs", 1 );
		obj.prop.getChild( "selected", 0, 1).setBoolValue( connect );
		append( Tank.list, obj ); 
		return obj;
	},
	get_capacity : func {
		return me.capacity.getValue(); 
	},
	get_level : func {
		return me.level_gal_us.getValue();	
	},
	set_level : func (gals_us){
		me.level_gal_us.setDoubleValue(gals_us);
		me.level_lbs.setDoubleValue(gals_us * me.ppg.getValue());
	},
	get_amount : func ( dt, ullage ) {
		amount = ( flowrate_lbs_hr / (me.ppg.getValue() * 60 * 60) ) * dt * 1 ;
		if (amount > me.level_gal_us.getValue() ) {
			amount = me.level_gal_us.getValue();
		} 
		if (amount > ullage ) {
			amount = ullage;
		} 
		#flowrate_lbs = ((amount/dt) * 60 * 60 ) * me.ppg.getValue();
		#print ( "flowrate_lbs_actual ", me.name, " ", flowrate_lbs);
		return amount
	},
	get_ullage : func () {
		return me.get_capacity() - me.get_level()
	},
	get_name : func () {
		return me.name;
	},
	set_transfer_tank : func ( dt, tank ) {
		foreach (var t; Tank.list) {
			if ( t.get_name() == tank)  {
				transfer = me.get_amount( dt, t.get_ullage() );
				#print (me.name, " tranfer ", transfer, " ", t.get_name() );
				me.set_level( me.get_level() - transfer );
				t.set_level( t.get_level() + transfer );
			}
		}
	},
	list : [],
};



# tranfer fuel - this is the main loop which keeps everyhting updated

fuelTrans = func {

	# if fuel consumption is frozen, skip it
	if(getprop("/sim/freeze/fuel")) { return settimer(fuelTrans, 0); }
	
	#calculate dt
	time = props.globals.getNode("/sim/time/elapsed-sec", 1).getValue();
	dt = time - last_time;
	#print("dt " , dt);
	last_time = time;
    
	# these are the rules governing fuel transfer
	if ( tank_1a_port.get_capacity() > (tank_1a_port.get_level() + 59.4)) {
		# transfer 2 to 1 collector box
		if ( tank_1_col_port.get_ullage() > 0 and tank_2_port.get_level() > 0){
			tank_2_port.set_transfer_tank( dt, "tank_1_col_port" );		
		}
	
		# transfer pinion to 1 collector box
		if ( tank_2_port.get_level() == 0  
			and tank_1_col_port.get_ullage() > 0 and pinion_port.get_level() > 0){ 
				pinion_port.set_transfer_tank( dt, "tank_1_col_port" );	
		}
	
		# transfer 3 to 1 collector box
		if (pinion_port.get_level() == 0 
			and tank_1_col_port.get_ullage() > 0 and tank_3_port.get_level() > 0){
				tank_3_port.set_transfer_tank( dt, "tank_1_col_port" );
		}
	
		# transfer 4 to 1 collector box
		if (tank_3_port.get_level() == 0
			and tank_1_col_port.get_ullage() > 0 and tank_4_port.get_level() > 0){
				tank_4_port.set_transfer_tank( dt, "tank_1_col_port" );
		}
	}
	
	if ( tank_1a_stbd.get_capacity() > (tank_1a_stbd.get_level() + 59.4)) {
		# transfer 2 to 1 collector box
		if ( tank_1_col_stbd.get_ullage() > 0 and tank_2_stbd.get_level() > 0){
			tank_2_stbd.set_transfer_tank( dt, "tank_1_col_stbd" );		
		}
	
		# transfer pinion to 1 collector box
		if ( tank_2_stbd.get_level() == 0  
			and tank_1_col_stbd.get_ullage() > 0 and pinion_stbd.get_level() > 0){ 
				pinion_stbd.set_transfer_tank( dt, "tank_1_col_stbd" );	
		}
	
		# transfer 3 to 1 collector box
		if (pinion_stbd.get_level() == 0 
			and tank_1_col_stbd.get_ullage() > 0 and tank_3_stbd.get_level() > 0){
				tank_3_stbd.set_transfer_tank( dt, "tank_1_col_stbd" );
		}
	
		# transfer 4 to 1 collector box
		if (tank_3_stbd.get_level() == 0
			and tank_1_col_stbd.get_ullage() > 0 and tank_4_stbd.get_level() > 0){
				tank_4_stbd.set_transfer_tank( dt, "tank_1_col_stbd" );
		}
	}
	
	# we have to treat the transfer of fuel in tank 1 and 1a differently
	# transfer 1a to 1     
	if (  tank_1_port.get_ullage() > 0 and tank_1a_port.get_level() > 0){
		amount_1a_port = tank_1_port.get_ullage();
		if ( amount_port > tank_1a_port.get_level() ) {
			amount_port = tank_1a_port.get_level();
		}
		#print( "Amount 1a port: " , amount_1a_port);
		tank_1a_port.set_level( tank_1a_port.get_level() - amount_1a_port );
		tank_1_port.set_level( tank_1_port.get_level() + amount_1a_port );
	}
	
	if (  tank_1_stbd.get_ullage() > 0 and tank_1a_stbd.get_level() > 0){
		amount_1a_stbd = tank_1_stbd.get_ullage();
		if ( amount_stbd > tank_1a_stbd.get_level() ) {
			amount_stbd = tank_1a_stbd.get_level();
		}
		#print( "Amount 1a stbd: " , amount_1a_stbd);
		tank_1a_stbd.set_level( tank_1a_stbd.get_level() - amount_1a_stbd );
		tank_1_stbd.set_level( tank_1_stbd.get_level() + amount_1a_stbd );
	}
	
	# transfer 1 to 1 collector box     
	if ( tank_1_col_port.get_ullage() > 0 and tank_1_port.get_level() > 0){
		amount_port = tank_1_col_port.get_ullage();
		if ( amount_port > tank_1_port.get_level() ) {
			amount_port = tank_1_port.get_level();
		}
		#print( "Amount port: " , amount_port );
		tank_1_port.set_level( tank_1_port.get_level() - amount_port );
		tank_1_col_port.set_level( tank_1_col_port.get_level() + amount_port );
	}
	
	if ( tank_1_col_stbd.get_ullage() > 0 and tank_1_stbd.get_level() > 0){
		amount_stbd = tank_1_col_stbd.get_ullage();
		if ( amount_stbd > tank_1_stbd.get_level() ) {
			amount_stbd = tank_1_stbd.get_level();
		}
		#print( "Amount stbd: " , amount_stbd);
		tank_1_stbd.set_level( tank_1_stbd.get_level() - amount_stbd );
		tank_1_col_stbd.set_level( tank_1_col_stbd.get_level() + amount_stbd );
	}
	
	settimer(fuelTrans, 0);
	
	} # end funtion fuelTrans    
		
	
	# fire it up
	
	settimer(init_fuel_system, 0);
	
	
	
	
	
	
	
	
	