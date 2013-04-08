var x10Units = new Array({name: "Fireplace Lights", type: "0", houseCode: "3", deviceID: "1"},
							{name: "Desk Lights", type: "1", houseCode: "3", deviceID: "2"},
							{name: "Couch Lights", type: "1", houseCode: "3", deviceID: "6"},
							{name: "Dining Room", type: "1", houseCode: "3", deviceID: "4"},
							{name: "Dining Room Closet", type: "1", houseCode: "3", deviceID: "5"},
							{name: "TV Lights", type: "1", houseCode: "3", deviceID: "7"});
							
var net = require('net');

var client = net.connect(1099, function(){
	var WebSocketServer = require('ws').Server, wss = new WebSocketServer({port: 9000});
	console.log('Server Running...');
  	wss.on('connection', function(ws) {
		console.log('New Connection!');
		ws.on('message', function(message) {
        	console.log('Received: ' + message);
        	var js = JSON.parse(message);
        	if(js.event == 8) {
	    		//Get X10 Devices
	    		var ret = {event: 8, devices: x10Units};
	    		ws.send(JSON.stringify(ret));
	    	} else if(js.event == 9) {
		    	console.log('Sending Event');
		    	var house = String.fromCharCode(64+js.houseCode);
		    	var command = null;
		    	if(js.command == 4 || js.command == 5) {
			    	if(js.command == 4) {
		    	  		command = 'off';
		    	  	} else if(js.command == 5) {
			    	  	command = 'on';
			    	}
			    	var x = 0;
			    	for (var i = 0; i < x10Units.length; i++) {
			    		setTimeout((function() {
				    		var device = x10Units[x];
				    		var ncCommand = 'rf '+house+device.deviceID+' '+command+'\n';
				    		client.write(ncCommand);
				    		x++;
			    		}), 1000*i);
				    }
		    	} else {
			    	if(js.command == 0) {
		    	  		command = 'off';
		    	  	} else if(js.command == 1) {
			    	  	command = 'on';
			    	} else if(js.command == 2) {
		      			command = 'dim';
		      		} else if(js.command == 3) {
		      			command = 'bright';
		      		}
		      		var ncCommand = 'rf '+house+js.device+' '+command+'\n';
		      		client.write(ncCommand);
		    	}
		   }
	   });
    });
});