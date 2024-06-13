package com.himedea.dao;



import com.himedea.dto.StudentDto;
import com.himedea.util.DbManager;
import org.springframework.beans.factory.annotation.Autowired;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Map;

public class StudentDao {

    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    @Autowired
    DbManager dbManger;

    public void sqlFunction(String sql) {
        con = dbManger.connection();
        try {
            pstmt = con.prepareStatement(sql);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            dbManger.close();
        }
    }

    public <T>  ArrayList<T> selectsql(String sql, Class<T> clazz) {
        ArrayList<T> list = new ArrayList<>();

        con = dbManger.connection();
        try {
            pstmt = con.prepareStatement(sql);
            rs =pstmt.executeQuery();
            while (rs.next()){
                T obj = clazz.getDeclaredConstructor().newInstance();
                for(Field field : obj.getClass().getDeclaredFields()){
                    field.setAccessible(true);
                    if(field.getType().equals(int.class))field.set( obj ,rs.getInt(field.getName()));
                    else field.set(obj , rs.getString(field.getName()));
                }
                list.add(obj);
            }
        } catch (SQLException | IllegalAccessException | InvocationTargetException | InstantiationException |
                 NoSuchMethodException e) {
            throw new RuntimeException(e);
        } finally {
            dbManger.close();
        }
        return list;
    }
}
