var parseClassMessage = "Message";
var parseKeyInstallations = "installations";
var parseKeySenderId = "senderId";
var parseKeySenderUsername = "senderUsername";
var parseKeyRecipientId = "recipientId";
var parseKeyRecipientUsername = "recipientUsername";
var parseKeyText = "text";
var parseKeySendDate = "sendDate";
var parseKeyIsRead = "isRead";

var parseParamUsername = "username";
var parseParamMessageId = "messageId";

var parsePushKeyType = "pushType";
var parsePushTypeNewMessage = "newMessage";
var parsePushKeyMessageId = "messageId";
var parsePushKeySenderId = parseKeySenderId;
var parsePushKeySenderUsername = parseKeySenderUsername;
var parsePushKeyText = parseKeyText;
var parsePushKeySendDate = parseKeySendDate;
var parsePushTypeReadReceipt = "readReceipt";

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
	console.log("Parse.Cloud.beforeSave(Parse.User)");
	var account = request.object;
	if (account.existed()) {
		console.log("Checkpoint A-1");
		if (account.dirtyKeys().indexOf("username") >= 0) {
			console.log("Checkpoint A-2");
			updateUsernameForAccountId(account.get("username"), account.id)
				.then(function() {
					console.log("Checkpoint A-SUCCESS");
					response.success();
				}, function(error) {
					console.error("Checkpoint A-ERROR: "+error.message);
					response.error(error);
				});
		}
	}
});

Parse.Cloud.beforeSave(parseClassMessage, function(request, response) {
	console.log("Parse.Cloud.beforeSave("+parseClassMessage+")");
	var message = request.object;
	if (message.existed()) {
		console.log("Checkpoint J-1");
		if (message.dirtyKeys().indexOf(parseKeyIsRead) >= 0) {
			console.log("Checkpoint J-2");
			if (message.get(parseKeyIsRead)) {
				console.log("Checkpoint J-3");
				var query = new Parse.Query(Parse.Installation);
				query.equalTo("channels", message.get(parseKeySenderId));
				query.notEqualTo("installationId", request.installationId);
				var data = {};
				data[parsePushKeyMessageId] = message.id;
				data[parsePushKeyType] = parsePushTypeReadReceipt;
				Parse.Push.send({
					where: query,
					data: data,
				}).then(function() {
					console.log("Checkpoint J-SUCCESS");
					response.success();
				}, function(error) {
					console.error("Checkpoint J-ERROR: "+error.message);
					response.error(error);
				});
			}
		}
	}

	response.success();
});

Parse.Cloud.afterSave(parseClassMessage, function(request) {
	console.log("Parse.Cloud.afterSave("+parseClassMessage+")");
	var message = request.object;
	if (message.existed()) {
		console.log("Checkpoint B-1");
		if (deleteIfNecessary(message)) {
			console.log("Checkpoint B-2");
			return;
		}
	} else {
		console.log("Checkpoint B-3");
		pushNotificationDataForMessage(message)
			.then(function(data) {
				return Parse.Push.send({
					channels: [message.get(parseKeyRecipientId)],
					data: data
				});
			}).then(function() {
				console.log("Checkpoint B-SUCCESS");
			}, function(error) {
				console.error("Checkpoint B-ERROR: "+error.message);
			});
	}
});

function pushNotificationDataForMessage(message) {
	console.log("pushNotificationDataForMessage(message)");
	return getAccountIdForUsername(message.get(parseKeySenderUsername))
		.then(function(accountId) {
			console.log("Checkpoint C-1");
			var data = {};
			data["alert"] = message.get(parseKeySenderUsername)+": "+message.get(parseKeyText);
			data[parsePushKeyType] = parsePushTypeNewMessage;
			data[parsePushKeyMessageId] = message.id;
			data[parsePushKeySenderId] = accountId;
			data[parsePushKeySenderUsername] = message.get(parseKeySenderUsername);
			data[parsePushKeyText] = message.get(parseKeyText);
			data[parsePushKeySendDate] = message.get(parseKeySendDate);
			return Parse.Promise.as(data);
		}, function(error) {
			console.error("Checkpoint C-ERROR: "+error.message);
			return Parse.Promise.error(error);
		});
}

function deleteIfNecessary(object) {
	console.log("deleteIfNecessary(object)");
	Parse.Cloud.useMasterKey();
	var query = object.relation(parseKeyInstallations).query();
	return query.count()
		.then(function(count) {
			console.log("Checkpoint D-1");
			if (count == 0) {
				return object.destroy().then(function() {
						return Parse.Promise.as(true);
					});
			}

			console.log("Checkpoint D-2");
			return Parse.Promise.as(false);
		}).then(function(deleted) {
			console.log("Checkpoint D-SUCCESS");
			return deleted;
		}, function(error) {
			if (error.code === Parse.Error.OBJECT_NOT_FOUND) {
				console.log("Checkpoint D-3");
				return true;
			}

			console.log("Checkpoint D-ERROR");
			console.error(error);
			return false;
		});
};

Parse.Cloud.define("getAccountIdForUsername", function(request, response) {
	console.log("Parse.Cloud.define(\"getAccountIdForUsername\")");
    var username = request.params[parseParamUsername];
    getAccountIdForUsername(username)
    	.then(function(accountId) {
    		console.log("Checkpoint E-SUCCESS");
    		response.success(accountId);
    	}, function(error) {
    		console.log("Checkpoint E-ERROR: "+error.message);
    		response.error(error);
    	});
});

function getAccountIdForUsername(username) {
	console.log("getAccountIdForUsername(username)");
	var query = new Parse.Query(Parse.User);
    query.equalTo("username", username);
    query.select("id");
    return query.first().then(function(user) {
    		console.log("Checkpoint F-SUCCESS");
    		return Parse.Promise.as(user.id);
    	}, function(error) {
    		console.log("Checkpoint F-ERROR: "+error.message);
    		return Parse.Promise.error(error);
    	});
}

function updateUsernameForAccountId(username, accountId) {
	console.log("updateUsernameForAccountId(username, accountId)");
	return Parse.Promise.when(updateUsernameForMessagesSentByAccountId(username, accountId), updateUsernameForMessagesReceivedByAccountId(username, accountId))
		.then(function() {
			console.log("Checkpoint G-SUCCESS");
			return Parse.Promise.as();
		}, function(error) {
			console.error("Checkpoint G-ERROR: "+error.message);
			return Parse.Promise.error(error);
		});
};

function updateUsernameForMessagesSentByAccountId(username, accountId) {
	console.log("updateUsernameForMessagesSentByAccountId(username, accountId)");
	var query = new Parse.Query(parseClassMessage);
	query.equalTo(parseKeySenderId, accountId);
	return query.find().then(function(results) {
			console.log("Checkpoint H-1");
			var object;
			for (var i = 0; i < results.length; i++) {
				console.log("Checkpoint H-1-"+i);
				object = results[i];
				object.set(parseKeySenderUsername, username);
			}
			return Parse.Promise.as(results);
		}).then(function(objects) {
			console.log("Checkpoint H-2");
			return Parse.Object.saveAll(objects);
		}).then(function() {
			console.log("Checkpoint H-SUCCESS");
			return Parse.Promise.as();
		}, function(error) {
			if (error.code === Parse.Error.OBJECT_NOT_FOUND) {
				console.log("Checkpoint H-3");
				return Parse.Promise.as();
			}
			
			console.error("Checkpoint H-ERROR: "+error.message);
			return Parse.Promise.error(error);
		});
};

function updateUsernameForMessagesReceivedByAccountId(username, accountId) {
	console.log("updateUsernameForMessagesReceivedByAccountId(username, accountId)");
	var query = new Parse.Query(parseClassMessage);
	query.equalTo(parseKeyRecipientId, accountId);
	return query.find().then(function(results) {
			console.log("Checkpoint I-1");
			var object;
			for (var i = 0; i < results.length; i++) {
				console.log("Checkpoint I-1-"+i);
				object = results[i];
				object.set(parseKeyRecipientUsername, username);
			}
			return Parse.Promise.as(results);
		}).then(function(objects) {
			console.log("Checkpoint I-2");
			return Parse.Object.saveAll(objects);
		}).then(function() {
			console.log("Checkpoint I-SUCCESS");
			return Parse.Promise.as();
		}, function(error) {
			if (error.code === Parse.Error.OBJECT_NOT_FOUND) {
				console.log("Checkpoint I-3");
				return Parse.Promise.as();
			}
			
			console.error("Checkpoint I-ERROR: "+error.message);
			return Parse.Promise.error(error);
		});
};

Parse.Cloud.define("messageWasRead", function(request, response) {
	console.log("Parse.Cloud.define(\"messageWasRead\")");
	var query = new Parse.Query(parseClassMessage);
	return query.get(request.params[parseParamMessageId])
		.then(function(message) {
			console.log("Checkpoint K-1");
			message.set(parseKeyIsRead, true);
			return message.save();
		}).then(function() {
			console.log("Checkpoint K-SUCCESS");
			response.success();
		}, function(error) {
			if (error.code === Parse.Error.OBJECT_NOT_FOUND) {
				console.log("Checkpoint K-2");
				return response.success();
			}
			
			console.error("Checkpoint K-ERROR: "+error.message);
			response.error(error);
		});
});