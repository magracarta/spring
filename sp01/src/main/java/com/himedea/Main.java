package com.himedea;

import com.himedea.dao.StudentDao;
import com.himedea.dto.StudentDto;
import com.himedea.util.Sqlenum;
import org.springframework.context.support.GenericXmlApplicationContext;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Main {
    public static void main(String[] args) throws IllegalAccessException {
        String[] sNums={"A1","A2","A3","A4","A5","A6","A7","A8","A9"};
        String[] sIds = {"hippo", "raccoon", "elephant", "lion",  "tiger", "pig", "horse", "bird", "deer"};
        String[] sPws={"9487","1528","4876","2866","6091","3002","2980","2864","2846"};
        String[] sNames={"barbara","chris","doris","elva","fiona","holly","jasmin","lena","melissa"};
        int[] sAges = {22, 20, 27, 19, 21, 19, 25, 22, 24};
        String[] sGenders = {"W", "W", "M", "M", "M", "W", "M", "W", "W"};
        String[] sMajors = {"Korean Literature",   "French Literature", "Philosophy", "History",   "Law", "Statistics", "Computer", "Economics", "Public Admin"};

        GenericXmlApplicationContext ctx = new GenericXmlApplicationContext("classpath:appctx.xml");
        StudentDao sdao = ctx.getBean("stdao", StudentDao.class);


        Sqlenum insetStudent = Sqlenum.STUDENTINSERT;



        /*
        for(int i =0; i < sNames.length; i++){
            Map<String , String> list = new HashMap<String, String>();
            StudentDto std = new StudentDto(sNums[i],sIds[i],sPws[i],sNames[i],sAges[i],sGenders[i],sMajors[i]);
            Object obj = std;
            for (Field field : obj.getClass().getDeclaredFields()) {
                field.setAccessible(true);
                Object value = field.get(obj);
                list.put(field.getName(), String.valueOf(value));
            }
            sdao.sqlFunction(insetStudent.insertSql(list));
        }
        */

        Sqlenum selectStudent = Sqlenum.STUDENTSELECT;
        ArrayList<StudentDto> slist = sdao.selectsql(selectStudent.selectSql() , StudentDto.class);
        slist.forEach(el->{
            try {
                for(Field sdto : el.getClass().getDeclaredFields()){
                    sdto.setAccessible(true);
                    Object value = sdto.get(el);
                    System.out.print(sdto.getName() + " : " + value + "\t\t\t\t\t");
                }
                System.out.println();
            } catch (IllegalAccessException e) {
                throw new RuntimeException(e);
            }
        });



    }
}