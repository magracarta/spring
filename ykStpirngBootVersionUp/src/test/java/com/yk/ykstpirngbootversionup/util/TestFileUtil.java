package com.yk.ykstpirngbootversionup.util;

import com.yk.ykstpirngbootversionup.bean.BeanUploadFile;
import jakarta.servlet.ServletContext;
import org.junit.Test;
import org.junit.jupiter.api.DisplayName;
import org.springframework.mock.web.MockServletContext;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.List;


public class TestFileUtil {
    private final String testURL = "https://designbase.co.kr/wp-content/uploads/2021/05/photoshop-basic-06-overview.jpg";
    private final String testFileName = testURL.split("/")[testURL.split("/").length - 1];
    private final String deskTopPath = System.getProperty("user.home") + File.separator +"Desktop";
    private final String realPath = deskTopPath+File.separator+"upload"+File.separator;



    @Test
    @DisplayName("testFileUrlToUploadFormFile")
    public void testFileUrlToUploadFormFile() {
        BeanUploadFile uploadFile = FileUtil.urlToUploadFormFile(testURL, realPath , testFileName);
        System.out.println("----------------------------------------------");
        System.out.println("uploadFile.getOriginFilePath() "+uploadFile.getOriginFilePath());
        System.out.println("uploadFile.getFileName() "+uploadFile.getFileName());
        System.out.println("uploadFile.getFullFileName() "+uploadFile.getFullFileName());
        System.out.println("uploadFile.getFileSize "+uploadFile.getFileSize());
    }

    @Test
    @DisplayName("copyFileToFile")
    public void copyFileToFile() {
        String filePath = System.getProperty("user.home") + File.separator + "Desktop";
        File source = new File(filePath+File.separator+"cute.jpg");
        File target = new File(filePath+File.separator+"copyCute.jpg");
        FileUtil.copy(source, target);
    }

    @Test
    @DisplayName("createDirIfNotExists")
    public void createDirIfNotExists() {
        String createDir = deskTopPath+File.separator+"test";
        FileUtil.createDirIfNotExists(createDir);
    }

    @Test
    @DisplayName("delete")
    public void delete() {
        FileUtil.delete(deskTopPath+File.separator+"test");
    }

    @Test
    @DisplayName("getFileSize")
    public void getFileSize() {
        long fileSize = FileUtil.getFileSize(deskTopPath + File.separator + "cute.jpg");
        System.out.println(fileSize);
    }


    @Test
    @DisplayName("readTextFile")
    public void readTextFile() {
        List<String> strings = FileUtil.readTextFile(deskTopPath + File.separator + "test.txt");
        for (String string : strings) {
            System.out.println(string);
        }
    }


    @Test
    @DisplayName("writeTextFile")
    public void writeTextFile() {
        List<String> strings = FileUtil.readTextFile(deskTopPath + File.separator + "test.txt");
        try {
            boolean b = FileUtil.writeTextFile(strings, deskTopPath + File.separator + "test"+File.separator + "test.txt");
            System.out.println(b);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Test
    @DisplayName("uploadFormFile")
    public void uploadFormFile() {
        String filePath = System.getProperty("user.home") + File.separator + "Desktop";
        File source = new File(filePath+File.separator+"cute.jpg");
        MultipartFile multipartFile = FileToMultipartFile.convertFileToMultipartFile(source ,"cute.jpg" );
        BeanUploadFile beanUploadFile = FileUtil.uploadFormFile(multipartFile, filePath);
        System.out.println(beanUploadFile.getFullFileName());
        System.out.println(beanUploadFile.getRealFileName());
        System.out.println(beanUploadFile.getFileName());
    }

    @Test
    @DisplayName("toByteArrayOutputStream")
    public void toByteArrayOutputStream() {
        String filePath = System.getProperty("user.home") + File.separator + "Desktop";
        File source = new File(filePath+File.separator+"cute.jpg");

        try {
            ByteArrayOutputStream byteArrayOutputStream = FileUtil.toByteArrayOutputStream(source);
            System.out.println(byteArrayOutputStream.toString());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Test
    @DisplayName("encodingBase64")
    public void encodingBase64() {
        String filePath = System.getProperty("user.home") + File.separator + "Desktop";
        File source = new File(filePath+File.separator+"cute.jpg");
        try {
            String s = FileUtil.encodingBase64(source);
            System.out.println(s);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Test
    @DisplayName("getSavePath")
    public void getSavePath() {
        ServletContext servletContext = new MockServletContext();

        String savePath = FileUtil.getSavePath(servletContext, deskTopPath + File.separator);
        System.out.println(savePath);
    }

}
