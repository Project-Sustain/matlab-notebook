/* Exported functions for sending/receiving RESTful API requests/responses */

export function sendEchoRequest(hostname, serverPort) {
    const restfulAPI = `https://${hostname}:${serverPort}/matlab_notebook/echo`;
    const requestOptions = {
        method: "POST",
        headers: {
            'Content-Type': 'application/json'
        }
    };
    return processRestfulAPI(restfulAPI, requestOptions);
}

export function sendServerRequestWithBody(hostname, serverPort, route, requestBody) {
    const restfulAPI = `https://${hostname}:${serverPort}/${route}`;
    const requestOptions = {
        method: "POST",
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestBody)
    };
    return processRestfulAPI(restfulAPI, requestOptions);
}

export function sendServerRequestWithoutBody(hostname, serverPort, route) {
    const restfulAPI = `https://${hostname}:${serverPort}/${route}`;
    const requestOptions = {
        method: "POST",
        headers: {
            'Content-Type': 'application/json'
        },
    };
    return processRestfulAPI(restfulAPI, requestOptions);
}

export async function processRestfulAPI(restfulAPI, requestOptions) {
    let response = await fetch(restfulAPI, requestOptions);
    let responseBody = await response.json();
    if(response.status === 400) {
        return {statusCode: 400, statusText: 'Bad Request', body: null};
    } else {
        return {
            statusCode: response.status,
            statusText: response.statusText,
            body: responseBody
        };
    }
}