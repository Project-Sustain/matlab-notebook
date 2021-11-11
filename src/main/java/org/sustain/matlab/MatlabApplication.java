package org.sustain.matlab;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.sustain.mongodb.MongoQuery;

@SpringBootApplication
public class MatlabApplication {

	public static Logger log = LoggerFactory.getLogger(MatlabApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(MatlabApplication.class, args);
	}

}
