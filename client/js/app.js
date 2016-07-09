var baseURL = 'http://localhost:4567'

var currentId

function logResponse(request) {
	if (request.status >= 200 && request.status < 400) {
		console.log(JSON.parse(request.responseText))
	}
}

function logError(request) {
    console.log('Error!')
    console.log(request.error)
}

function sendRequest(request, data, callback) {
    data = data || {}
    request.send(data)
    request.onload = function(){ 
        logResponse(request)
        if (callback) {callback(request)}
    }
    request.onerror = function() { logError(request) }
}

function getSuggestion() {
	var request = new XMLHttpRequest()
	request.open('GET', baseURL+'/take', true)
    sendRequest(request, null, function(req){
        currentId = JSON.parse(req.responseText).id
    })
}

function rateSuggestion(id, rating) {
	var request = new XMLHttpRequest()
	request.open('POST', baseURL+'/take', true)
	request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
	var data = JSON.stringify({id: '5780c4a678d73ed6b5fbc5fe', rating: 1 })
    sendRequest(request, data)
}

function makeSuggestion(suggestion) {
    var request = new XMLHttpRequest()
    request.open('POST', baseURL+'/make', true)
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
    var data = JSON.stringify({suggestion: suggestion})
    sendRequest(request, data)
}

function listAllSuggestions() {
    var request = new XMLHttpRequest()
    request.open('GET', baseURL+'/list', true)
    sendRequest(request, null)
}

function deleteAllSuggestions() {
    var request = new XMLHttpRequest()
    request.open('GET', baseURL+'/wipe', true)
    sendRequest(request, null)
}

getSuggestion()
rateSuggestion(1, 123)
makeSuggestion("Brush your teeth!")
listAllSuggestions()
deleteAllSuggestions()