var winston = require('winston');

winston.add(winston.transports.File, { filename: '/var/log/lights.log' });
winston.remove(winston.transports.Console);

winston.stream({ start: -1 }).on('log', function(log) {
	console.log(log.timestamp+': '+log.message);
});