package com.chutianjing.auth;

import org.junit.jupiter.api.Test;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(classes = {AuthServiceApplication.class, DataSourceAutoConfiguration.class})
class AuthServiceApplicationTests {

	@Test
	void contextLoads() {
	}

}
