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
    if (response) {
        console.log("Response in processRestfulAPI:", response);
        if (response.ok) {
            let responseBody = await response.json();
            console.log("Response ok, responseBody:", responseBody);
            return {
                statusCode: response.status,
                statusText: response.statusText,
                url: response.url,
                ok: response.ok,
                body: response.body
            }
        } else {
            console.log("Response not ok");
            return {
                statusCode: response.status,
                statusText: response.statusText,
                url: response.url,
                ok: response.ok,
                body: null
            };
        }
    } else {
        console.log("Response is undefined in processRestfulAPI");
    }
}