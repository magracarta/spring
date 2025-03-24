package com.yk.ykstpirngbootversionup.dbTest;

import com.google.api.client.util.Value;
import org.junit.Test;
import org.junit.jupiter.api.DisplayName;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

import java.sql.*;
import java.util.Enumeration;

@SpringBootTest
public class TestDBConnection {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String query = null;


    String url ="jdbc:oracle:thin:@222.239.76.83:1521/YKDevDB";
    String username = "yk_erp_new";
    String password = "ykerpnew!123";



    @Test
    @DisplayName("DB TEST")
    public void testDBConnection() {
        try {
            Class.forName("core.log.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(url, username, password);
            
        } catch (ClassNotFoundException e) {

            System.out.println("연결 실패");
            throw new RuntimeException(e);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }


    }


    @Test
    public void testdd(){
        Enumeration<Driver> drivers = java.sql.DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            System.out.println("로드된 JDBC 드라이버: " + driver.getClass().getName());
        }
    }


}
