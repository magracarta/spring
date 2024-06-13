package com.himedea.util;

import java.util.Map;

public enum Sqlenum {
    STUDENTSELECT("select * from student") , STUDENTINSERT("insert into student ");

    private String sql;
    Sqlenum(String sqltext){
        this.sql = sqltext;
    }



    public String insertSql(Map<String, String> list){
        StringBuffer key = new StringBuffer();
        StringBuffer value = new StringBuffer();
        int [] count = {0};

        list.forEach((k,v)->{
            key.append(k);
            if(!numberCheck(v)) value.append("'").append(v).append("' ");
            else value.append(v);
            if (count[0] != list.size()-1){
                key.append(", ");
                value.append(", ");
            }
            count[0] += 1;

        });



        return sql + " (" + key.toString() + ")"
                + " values(" + value.toString() + ") " ;
    }

    public String selectSql() {
        return sql;
    }


    public boolean numberCheck(String text){
        try{
            Integer.parseInt(text);
            if(Integer.parseInt(text) > 100) return false;
        }catch (NumberFormatException e){
            return false;
        }

        return true;
    }

}
