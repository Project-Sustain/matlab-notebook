package org.sustain.matlab;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MatlabApplication {

	private static final String VERSION = "0.1";

	public static Logger log = LoggerFactory.getLogger(MatlabApplication.class);

	public static void main(String[] args) {
		log.info("Starting MatlabApplication v{}", VERSION);

		SpringApplication.run(MatlabApplication.class, args);
	}

}
