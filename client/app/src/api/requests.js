/* Exported functions for sending/receiving RESTful API requests/responses */

export function sendEchoRequest(hostname, serverPort) {
    const restfulAPI = `http://${hostname}:${serverPort}/echo`;
    const requestOptions = {
        method: "POST",
        headers: {
            'Content-Type': 'application/json'
        }
    };
    return processRestfulAPI(restfulAPI, requestOptions);
}

export function sendServerRequestWithBody(hostname, serverPort, route, requestBody) {
    const restfulAPI = `http://${hostname}:${serverPort}/${route}`;
    const requestOptions = {
        method: "POST",
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestBody)
    };
    return processRestfulAPI(restfulAPI, requestOptions);
}

export async function processRestfulAPI(restfulAPI, requestOptions) {
    try {
        console.log(requestOptions)
        let response = await fetch(restfulAPI, requestOptions);
        console.log(response);
        return {
            statusCode: response.status,
            statusText: response.statusText,
            body: await response.json()
        };
    } catch(err) {
        console.error(err);
        return { statusCode: 0, statusText: 'Client failure', body: null };
    }
}