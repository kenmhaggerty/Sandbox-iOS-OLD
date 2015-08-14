var parseClassMessage = "Message";
var parseKeyInstallations = "installations";
var parseKeySenderId = "senderId";
var parseKeySenderUsername = "senderUsername";
var parseKeyRecipientId = "recipientId";
var parseKeyRecipientUsername = "recipientUsername";
var parseKeyText = "text";
var parseKeyIsRead = "isRead";
var parsePushKeyMessageId = "messageId";
var parsePushKeyIsRead = "isRead";

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
	var account = request.object;
	if (account.existed()) {
		if (account.dirtyKeys().indexOf("username") >= 0) {
			updateUsernameForAccountId(account.get("username"), account.id)
				.then(
					function() {
						console.log("Checkpoint SUCCESS");
						response.success();
					}, function(error) {
						console.log("Checkpoint ERROR");
						response.error(error);
					});
		}
	}
});

// Parse.Cloud.beforeSave(parseClassMessage, function(request, response) {
// 	var message = request.object;
// 	if (message.existed()) {
// 		if (message.dirtyKeys().indexOf(parseKeyIsRead) >= 0) {
// 			if (message.get(parseKeyIsRead)) {
// 				Parse.Push.send({
// 					channels: [message.get(parseKeySenderId)],
// 					data: {
// 						parsePushKeyIsRead: true
// 					},
// 				}, {
// 					error: function(error) {
// 						console.error("Could not send push notification: "+error);
// 					}
// 				});
// 			}
// 		}
// 	}

// 	response.success();
// });

Parse.Cloud.afterSave(parseClassMessage, function(request) {
	var message = request.object;
	if (message.existed()) {
		if (deleteIfNecessary(message)) {
			return;
		}
	} else {
		Parse.Push.send({
			channels: [message.get(parseKeyRecipientId)],
			data: {
				alert: message.get(parseKeySenderUsername)+": "+message.get(parseKeyText),
				parsePushKeyMessageId: message.id
			},
		}, {
			error: function(error) {
				console.error("Could not send push notification: "+error);
			}
		});
	}
});

function deleteIfNecessary(object) {
	Parse.Cloud.useMasterKey();
	var query = object.relation(parseKeyInstallations).query();
	query.count({
		success: function(count) {
			if (count == 0) {
				object.destroy({
					success: function() {
						return true;
					},
                    error: function(error) {
                    	console.error("Could not delete "+parseClassMessage+": "+error);
                    	return false;
                    }
               });
			}
			return false;
        },
        error: function(error) {
        	console.error("Could not count "+parseKeyInstallations+" for "+parseClassMessage+": "+error);
        	return false;
        }
    });
};

Parse.Cloud.define("getAccountIdForUsername", function(request, response) {
    var username = request.params.username;
    var query = new Parse.Query(Parse.User);
    query.equalTo("username", username);
    query.first({
    	success: function(object) {
    		response.success(object.id);
    	},
    	error: function(error) {
    		response.error("Could not fetch "+parseClassAccount+" for username "+username+": "+error);
    	}
    });
});

function updateUsernameForAccountId(username, accountId) {
	console.log("Checkpoint A-1 ("+username+", "+accountId+")");
	return updateUsernameForMessagesSentByAccountId(username, accountId)
		.then(
			function() {
				console.log("Checkpoint A-2");
				return updateUsernameForMessagesReceivedByAccountId(username, accountId);
			})
		.then(
			function() {
				console.log("Checkpoint A-3");
				return Parse.Promise.as();
			}, function(error) {
				console.log("Checkpoint A-ERROR");
				return Parse.Promise.error(error);
			});
};

function updateUsernameForMessagesSentByAccountId(username, accountId) {
	console.log("Checkpoint B-1");
	var query = new Parse.Query(parseClassMessage);
	query.equalTo(parseKeySenderId, accountId);
	return query.find()
		.then(
			function(results) {
				console.log("Checkpoint B-2");
				var object;
				for (var i = 0; i < results.length; i++) {
					console.log("Checkpoint B-2-"+i);
					object = results[i];
					object.set(parseKeySenderUsername, username);
				}
				return Parse.Promise.as(results);
			})
		.then(
			function(objects) {
				console.log("Checkpoint B-3");
				return Parse.Object.saveAll(objects);
			})
		.then(
			function() {
				console.log("Checkpoint B-4");
				return Parse.Promise.as();
			}, function(error) {
				console.log("Checkpoint B-ERROR");
				return Parse.Promise.error(error);
			});
};

function updateUsernameForMessagesReceivedByAccountId(username, accountId) {
	console.log("Checkpoint C-1");
	var query = new Parse.Query(parseClassMessage);
	query.equalTo(parseKeyRecipientId, accountId);
	return query.find()
		.then(
			function(results) {
				console.log("Checkpoint C-2");
				var object;
				for (var i = 0; i < results.length; i++) {
					console.log("Checkpoint C-2-"+i);
					object = results[i];
					object.set(parseKeyRecipientUsername, username);
				}
				return Parse.Promise.as(results);
			})
		.then(
			function(objects) {
				console.log("Checkpoint C-3");
				return Parse.Object.saveAll(objects);
			})
		.then(
			function() {
				console.log("Checkpoint C-4");
				return Parse.Promise.as();
			}, function(error) {
				console.log("Checkpoint C-ERROR");
				return Parse.Promise.error(error);
			});
};