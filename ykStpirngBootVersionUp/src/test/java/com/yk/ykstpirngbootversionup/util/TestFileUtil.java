package com.yk.ykstpirngbootversionup.util;

import com.yk.ykstpirngbootversionup.bean.BeanUploadFile;
import org.junit.Test;
import org.junit.jupiter.api.DisplayName;

import java.io.File;


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

    }


}
