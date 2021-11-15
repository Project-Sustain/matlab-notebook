package org.sustain.echo;

public class EchoResponse {

    public String responseBody;

    public EchoResponse(EchoRequest request) {
        this.responseBody = request.requestBody;
    }

    @Override
    public String toString() {
        return "EchoResponse{" +
                "responseBody='" + responseBody + '\'' +
                '}';
    }
}
