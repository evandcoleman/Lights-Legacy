var cronJob = require('cron').CronJob;
var Cubby = require('cubby'),
    cubby = new Cubby();

var scheduledEvents = new Array();

var x10Units = new Array({name: "Desk Light", type: "0", houseCode: "2", deviceID: "1"},
							{name: "Lamp", type: "1", houseCode: "2", deviceID: "2"});
    
if(cubby.get('events') == null) {
	cubby.set('events',{ events : [] });
} else {
	var events = cubby.get('events');
	for(var i = 0; i < events.events.length; i++) {
		var now = Math.round(new Date().getTime() / 1000);
		if(now > events.events[i].time && events.events[i].repeat == '') {
			events.events[i].state = false;
		}
		
		if(events.events[i].state == true) {
		   	scheduleEvent(events.events[i], JSON.stringify(events.events[i]));
		} else {
        	console.log('Not Scheduling Event');
	    }
	}
	cubby.set('events',events);
}

var WebSocketServer = require('ws').Server
  , wss = new WebSocketServer({port: 9000});
console.log('Server Running...');
wss.on('connection', function(ws) {
	console.log('New Connection!');
    ws.on('message', function(message) {
        console.log('Received: ' + message);
        //This try-catch block tries to parse the JSON data, if it fails then that means it's not valid JSON (meaning it's the currentState response) and sends it along to the iOS app.
        try {
	        var js = JSON.parse(message);
        }
        catch (e) {
	        for (var i = 0; i < wss.clients.length; i++) {
	        	wss.clients[i].send(message);
	        }
	        return;
        }
        if(js.event == 4) {
	        //Query Schedule
	        var events = cubby.get('events');
	        events.event = 4;
	        ws.send(JSON.stringify(events));
	    } else if(js.event == 8) {
	    	//Get X10 Devices
	    	var ret = {event: 8, devices: x10Units};
	    	ws.send(JSON.stringify(ret));
	    } else if(js.event == 5) {
	    	//flush schedules
	    	cubby.set('events',{ events : [] });
	    	for(var i = 0; i < scheduledEvents.length; i++) {
		    	scheduledEvents[i].stop();
	    	}
	    	scheduledEvents = new Array;
        } else {
		    if(js.time > 0) {
	        	var events = cubby.get('events');
	        	events.events.push(js);
	        	cubby.set('events', events);
	        	if(js.state == true) {
		        	scheduleEvent(js, message);
	        	} else {
		        	console.log('Not Scheduling Event');
	        	}
	        } else {
	        	console.log('Sending Event');
		        for (var i = 0; i < wss.clients.length; i++) {
		        	wss.clients[i].send(message);
		        }
	        }
        }
    });
});

function scheduleEvent(js, message) {
    console.log('Event Scheduled');
    var date = new Date(js.time*1000);
    var cronString = date.getMinutes() + ' ' + date.getHours() + ' * * ' + js.repeat;
    //console.log(cronString);
    if(js.repeat == '') {
    	//one-time
        var job = new cronJob(date, function(){
        		for (var i = 0; i < wss.clients.length; i++) {
	        		wss.clients[i].send(message);
	        	}
	        	console.log('Sending Scheduled Event');
	        	checkEvents();
	    	}, function () {
	    		//on-stop
	    		
	    	}, 
	    	true ,
		    js.timeZone
		);
		scheduledEvents.push(job);
    } else {
    	//repeating
        var job = new cronJob({
        	cronTime: cronString,
        	onTick: function() {
        		for (var i = 0; i < wss.clients.length; i++) {
	        		wss.clients[i].send(message);
	        	}
	        	console.log('Sending Scheduled Event');
	        	checkEvents();
        	},
        	start: true,
        	timeZone: js.timeZone
        });
        scheduledEvents.push(job);
    }
}

function checkEvents() {
	var events = cubby.get('events');
	for(var i = 0; i < events.events.length; i++) {
    	var now = Math.round(new Date().getTime() / 1000);
    	if(now >= events.events[i].time && events.events[i].repeat == '') {
        	events.events[i].state = false;
        }
	}
	cubby.set('events',events);
}