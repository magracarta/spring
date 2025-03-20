package com.yk.ykstpirngbootversionup.util.httpConnector;

import com.yk.ykstpirngbootversionup.util.net.HttpUtil;
import org.junit.Test;
import org.junit.jupiter.api.DisplayName;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.io.File;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;

public class TestHttpUtil {

    @Test
    @DisplayName("메서드 확인")
    public void allCountMethod(){
        Class <HttpUtil> httpUtilClass = HttpUtil.class;

        Method[] methods = httpUtilClass.getDeclaredMethods();
        System.out.println(methods.length);
        for (Method method : methods) {
            System.out.println(method.getName());
        }
    }


    @Test
    @DisplayName("getHttpFile")
    public void getHttpFile(){
        String testUrl = "https://httpbin.org/image";

        String userHome = System.getProperty("user.home");
        String deskTop = userHome + File.separator + "Desktop"+File.separator+"image.jpeg";
        boolean httpFile = HttpUtil.getHttpFile(testUrl, deskTop, 1000);
        assertThat(httpFile).isTrue();

    }

    @Test
    @DisplayName("한글 파일명 인코딩")
    public void encodeKorFileName(){
        String userHome = System.getProperty("user.home");
        String deskTop = userHome + File.separator + "Desktop"+File.separator+"한글인뎁쇼.jpeg";
        String fileName = HttpUtil.encodeKorFileName(deskTop);
        System.out.println(fileName);

    }


    @Test
    @DisplayName("getHttpDocument")
    public void getHttpDocument(){
        String testUrl = "https://httpbin.org/post?id=min&message=hi";
        String httpDocument = HttpUtil.getHttpDocument(testUrl);
        System.out.println(httpDocument);
    }


    @Test
    @DisplayName("sendRestGet")
    public void sendRestGet(){
        Map<String, Object> stringObjectMap = HttpUtil.sendRestGet("https://httpbin.org/get?id=min&message=hi");

        System.out.println("sendRestGet ---------------------------------------------");
        for (Map.Entry<String, Object> entry : stringObjectMap.entrySet()) {
            System.out.println(entry.getKey() + "-----------\n" + entry.getValue());
        }
    }

    @Test
    @DisplayName("sendRestGet param")
    public void sendRestGetParam(){
        Map<String, Object> param = new HashMap<>();
        param.put("message", "hi");
        param.put("id", "min");
        Map<String, Object> stringObjectMap = HttpUtil.sendRestGet("https://httpbin.org/get",param);
        readRest(stringObjectMap);
    }


    @Test
    @DisplayName("sendRestGet HttpHeaders")
    public void sendRestGetHttpHeaders(){
        HttpHeaders headers = new HttpHeaders();
        headers.add("test","test");
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> stringObjectMap = HttpUtil.sendRestGet("https://httpbin.org/get", headers);
        readRest(stringObjectMap);

    }


    @Test
    @DisplayName("sendRestGet HttpHeaders param bodyType")
    public void sendRestGetHttpHeadersParamBodyType(){
        HttpHeaders headers = new HttpHeaders();
        headers.add("test","test");

        Map<String, Object> param = new HashMap<>();
        param.put("message", "hi");
        param.put("id", "min");
        Map<String, Object> stringObjectMap = HttpUtil.sendRestGet("https://httpbin.org/get", headers, param, "JSON");
        readRest(stringObjectMap);
    }

    @Test
    @DisplayName("sendRestPost param")
    public void sendRestPostParam(){
        Map<String, Object> param = new HashMap<>();
        param.put("message", "hi");
        param.put("id", "min");
        Map<String, Object> stringObjectMap = HttpUtil.sendRestPost("https://httpbin.org/post", param);
        readRest(stringObjectMap);
    }

    @Test
    @DisplayName("sendRestPost noEncoding")
    public void sendRestPostNoEncoding(){
        Map<String, Object> param = new HashMap<>();
        param.put("encoding", "test@$#");
        param.put("noEncoding", "test@$#");
        String [] strs = {
                "id"
        };
        Map<String, Object> stringObjectMap = HttpUtil.sendRestPost("https://httpbin.org/post", param , strs);
        readRest(stringObjectMap);
    }

    @Test
    @DisplayName("sendRestPut")
    public void sendRestPut(){
        Map<String, Object> param = new HashMap<>();
        HttpHeaders headers = new HttpHeaders();
        headers.add("test","test");

        param.put("message", "hi");
        param.put("id", "min");

        Map<String, Object> stringObjectMap = HttpUtil.sendRestPut("https://httpbin.org/put", headers, param);
        readRest(stringObjectMap);
    }

    @Test
    @DisplayName("sendRestDelete")
    public void sendRestDelete(){
        Map<String, Object> param = new HashMap<>();
        HttpHeaders headers = new HttpHeaders();
        headers.add("test","test");

        param.put("message", "hi");
        param.put("id", "min");

        Map<String, Object> stringObjectMap = HttpUtil.sendRestDelete("https://httpbin.org/delete", headers, param);
        readRest(stringObjectMap);
    }


    @Test
    @DisplayName("sendRestString")
    public void sendRestString(){
        Map<String, Object> param = new HashMap<>();
        HttpHeaders headers = new HttpHeaders();
        headers.add("test","test");

        param.put("message", "hi");
        param.put("id", "min");

        ResponseEntity<String> stringResponseEntity = HttpUtil.sendRestString("https://httpbin.org/post", HttpMethod.POST, headers, param);
        System.out.println(stringResponseEntity.getBody());

    }

    @Test
    @DisplayName("sendRestWithFile")
    public void sendRestWithFile(){
        HttpHeaders headers = new HttpHeaders();
        Map<String, String> param = new HashMap<>();

        String userHome = System.getProperty("user.home");
        String deskTop = userHome + File.separator + "Desktop"+File.separator+"image.jpeg";

        param.put("message", "hi");
        param.put("file_full_path", deskTop);
        try {
            Map<String, Object> stringObjectMap = HttpUtil.sendRestWithFile("https://httpbin.org/post", HttpMethod.POST, headers, param);
            readRest(stringObjectMap);
        } catch (MalformedURLException e) {
            throw new RuntimeException(e);
        }

    }

    @Test
    @DisplayName("sendRestPostFile")
    public void sendRestPostFile(){
        String userHome = System.getProperty("user.home");
        String deskTop = userHome + File.separator + "Desktop"+File.separator+"image.jpeg";
        File [] files = new File[1];
        files[0] = new File(deskTop);
        Map<String, String> param = new HashMap<>();
        param.put("message", "hi");
        param.put("test","test" );

        try {
            Map<String, Object> stringObjectMap = HttpUtil.sendRestPostFile("https://httpbin.org/post", param, files);
            readRest(stringObjectMap);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }


    @Test
    @DisplayName("sendNonRestGet")
    public void sendNonRestGet(){
        Map<String, Object> stringObjectMap = HttpUtil.sendNonRestGet("http://httpbin.org/get");
        readRest(stringObjectMap);
    }

    @Test
    @DisplayName("sendNonRestGet fileUrl param paramEncode")
    public void sendNonRestGetFileUrlParam(){
        Map<String, Object> param = new HashMap<>();
        param.put("encoding1", "test@$#");
        param.put("encoding2", "test@$#");
        Map<String, Object> stringObjectMap = HttpUtil.sendNonRestGet("http://httpbin.org/get", param, true);
        readRest(stringObjectMap);

    }

    @Test
    @DisplayName("sendNonRestGet fileUrl param paramEncode headers")
    public void sendNonRestGetFileUrlParamHeaders(){
        Map<String, Object> param = new HashMap<>();
        param.put("encoding1", "test@$#");
        param.put("encoding2", "test@$#");
        Map<String, String> headers = new HashMap<>();
        headers.put("Accept","text/html, image/gif, image/jpeg, */*");
        headers.put("Content-Type","application/x-www-form-urlencoded");
        headers.put("Accept-Encoding","gzip, deflate");

        Map<String, Object> stringObjectMap = HttpUtil.sendNonRestGet("http://httpbin.org/get", param, true,headers);
        readRest(stringObjectMap);
    }

    @Test
    @DisplayName("sendNonRestPost fileUrl param paramEncode")
    public void sendNonRestPostFileUrlParam(){
        Map<String, Object> param = new HashMap<>();param.put("encoding1", "test@$#");
        param.put("encoding2", "test@$#");
        Map<String, Object> stringObjectMap = HttpUtil.sendNonRestPost("http://httpbin.org/post", param, true);
        readRest(stringObjectMap);
    }

    @Test
    @DisplayName("sendNonRestPost fileUrl param paramEncode headers")
    public void sendNonRestPostFileUrlParamHeaders(){
        Map<String, Object> param = new HashMap<>();
        param.put("encoding1", "test@$#");
        param.put("encoding2", "test@$#");
        Map<String, String> headers = new HashMap<>();
        headers.put("Accept","text/html, image/gif, image/jpeg, */*");
        headers.put("Content-Type","application/x-www-form-urlencoded");
        headers.put("Accept-Encoding","gzip, deflate");

        Map<String, Object> stringObjectMap = HttpUtil.sendNonRestPost("http://httpbin.org/post", param, true, headers);
        readRest(stringObjectMap);
    }


    @Test
    @DisplayName("sendSapRestPost")
    public void sendSapRestPost(){
        try {
            String s = HttpUtil.sendSapRestPost("http://httpbin.org/post", "?id=testId&text=hihi");
            System.out.println(s);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Test
    @DisplayName("getJsonToList")
    public void getJsonToList(){
        Map<String, Object> stringObjectMap = HttpUtil.sendRestGet("http://httpbin.org/json");
        String jsontext = "{json_objects"+": [" +stringObjectMap.get("_originResult").toString()+"]}";

        List<Map<String, Object>> jsonToList = HttpUtil.getJsonToList(jsontext);
        for (Map<String, Object> map : jsonToList) {
            readRest(map);
        }
    }


    public void readRest(Map<String, Object> stringObjectMap){
        for (Map.Entry<String, Object> entry : stringObjectMap.entrySet()) {
            System.out.println(entry.getKey() + "-----------\n" + entry.getValue());
        }
    }
}
