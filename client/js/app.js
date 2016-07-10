var baseURL = 'http://localhost:4567'
var currentId = 123

var suggestionBox = (function() {
    makeSuggestion("Try new things.", function(){ console.log("suggestion made")})

    function returnResponse(request) {
    	if (request.status >= 200 && request.status < 400) {
    		return (JSON.parse(request.responseText).status)
    	}
    }

    function logError(request) {
        console.log('Error!')
        console.log(request.error)
    }

    function sendRequest(request, data, callback) {
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
        data = data || {}
        request.send(data)
        console.log('Sending data: '+data)
        request.onload = function(){ 
            if (request.status >= 200 && request.status < 400)
                if (callback) { callback(request) }
        }
        request.onerror = function() { logError(request) }
    }

    function takeSuggestion(f) {
    	var request = new XMLHttpRequest()
    	request.open('GET', baseURL+'/take', true)
        sendRequest(request, null, function(res){
            currentId = JSON.parse(res.responseText)["id"]  
            console.log('Set currentId to: '+currentId)
            f(res, currentId)
        })
    }

    // function rateSuggestion(id, f) {
    // 	var request = new XMLHttpRequest()
    // 	request.open('POST', baseURL+'/take', true)
    // 	var data = JSON.stringify({id:currentId, rating: 1})
    //     sendRequest(request, data, function(res, currentId){
    //         f(res, currentId)
    //     })
    // }

    function rateSuggestion(id, rating, f) {
        var request = new XMLHttpRequest()
        request.open('POST', baseURL+'/take', true)
        var data = JSON.stringify({id:currentId, rating: rating})
        sendRequest(request, data, function(res){
            f(res)
        })
    }

    function makeSuggestion(suggestion, f) {
        var request = new XMLHttpRequest()
        request.open('POST', baseURL+'/make', true)
        var data = JSON.stringify({suggestion: suggestion})
        sendRequest(request, data, function(res){
            f(res, currentId)
        })
    }

    function listAllSuggestions(f) {
        var request = new XMLHttpRequest()
        request.open('GET', baseURL+'/list', true)
        sendRequest(request, null, f)
    }

    function deleteAllSuggestions() {
        var request = new XMLHttpRequest()
        request.open('GET', baseURL+'/wipe', true)
        sendRequest(request, null)
    }

    function meh(id, f){
        rateSuggestion(id, -1, f)
    }

    function great(id, f){
        rateSuggestion(id, 1, f)
    }

    return {
        takeSuggestion: takeSuggestion,
        rateSuggestion: rateSuggestion,
        makeSuggestion: makeSuggestion,
        list: listAllSuggestions,
        suggestionRatedMeh: meh,
        suggestionRatedGreat: great,
        currentId: currentId
    }
})()