package com.yk.ykstpirngbootversionup.util.httpConnector;

import com.yk.ykstpirngbootversionup.util.net.HttpConnector;
import org.junit.Test;
import org.junit.jupiter.api.DisplayName;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

import java.io.File;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

public class TestHttpConnector {

    @Test
    @DisplayName("메서드 총 개수 확인")
    public void allCountMethod() {
        Class<HttpConnector> http = HttpConnector.class;

        Method [] methods = http.getDeclaredMethods();
        System.out.println(http.getName() + "의 메서드목록 총 " + methods.length + " 개");
        for (Method method : methods) {
            System.out.println(method.getName());
        }

    }

    @Test
    @DisplayName("addParam String")
    public void addParamMapParamTest(){
        String testUrl = "https://httpbin.org/post";
        HttpConnector httpCon = new HttpConnector(testUrl);
        Map<String, Object> param = new HashMap<String, Object>();

        param.put("key","123");
        param.put("key2","456");
        param.put("key3","789");

        httpCon.addParam(param);
        System.out.println(httpCon.printParams());
    }

    @Test
    @DisplayName("addParam File")
    public void addParamMapFileTest(){

        String testUrl = "https://httpbin.org/post";
        HttpConnector httpCon = new HttpConnector(testUrl);
        String userHome = System.getProperty("user.home");
        String deskTop = userHome + File.separator + "Desktop" + File.separator+"cute.jpg";
        File file = new File(deskTop);


        httpCon.addParam("cute",file);
        System.out.println(httpCon.printParams());

    }

    @Test
    @DisplayName("addParam submit")
    public void addParamSubmitTest(){
        String testUrl = "https://httpbin.org/post";
        HttpConnector httpCon = new HttpConnector(testUrl);

        HttpHeaders headers = new HttpHeaders();
        httpCon.addParam("key","123");
        headers.add("test","test");
        headers.setContentType(MediaType.APPLICATION_JSON);
        try {
            String submit = httpCon.submit(headers);

            System.out.println(submit);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }



}
