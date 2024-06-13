package com.himedea.util;

import org.springframework.beans.factory.annotation.Autowired;

import java.sql.*;

public class DbManager {
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    @Autowired
    Dbman dbman;

    public Connection connection( ){
        try {
            Class.forName(dbman.getDriver());
            con = DriverManager.getConnection(dbman.getUrl(),dbman.getId(), dbman.getPw());

        } catch (ClassNotFoundException | SQLException e) {
            throw new RuntimeException(e);
        }
        return con;

    }

    public void close(){
        try {
            if(con != null) con.close();
            if(pstmt != null) pstmt.close();
            if(rs != null) rs.close();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
