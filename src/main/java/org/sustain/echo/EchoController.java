package org.sustain.echo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Component
public class EchoController {

    public static Logger log = LoggerFactory.getLogger(EchoController.class);

    @PostMapping("/echo")
    @CrossOrigin(origins = "http://localhost:8081")
    public EchoResponse echoPostRequest(@RequestBody EchoRequest request) {
        log.info("Received echo POST request: {}", request);
        return new EchoResponse(request);
    }

}
