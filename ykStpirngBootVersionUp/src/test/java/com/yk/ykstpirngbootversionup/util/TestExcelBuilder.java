package com.yk.ykstpirngbootversionup.util;

import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.junit.Test;
import org.junit.jupiter.api.BeforeEach;

import jakarta.servlet.http.HttpServletRequest;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.*;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.*;

public class TestExcelBuilder {
    private final ExcelBuilder excelBuilder = new ExcelBuilder();
    private HttpServletRequest request  = mock(HttpServletRequest.class);
    private HttpServletResponse response = mock(HttpServletResponse.class);


    @Test
    public void testBuildExcelDocumtent() throws Exception{
        Map<String, Object> headerMap = new HashMap<>();

        headerMap.put("column1","Header 1");
        headerMap.put("column2","Header 2");

        List<Map<String, Object>> dataList = new ArrayList<>();
        Map<String, Object> row1 = new HashMap<>();
        row1.put("column1","Data 1");
        row1.put("column2","Data 2");
        dataList.add(row1);

        Map<String, Object> row2 = new HashMap<>();
        row2.put("column1","Data 3");
        row2.put("column2","Data 4");
        dataList.add(row2);

        Map<String, Object> model = new HashMap<>();
        model.put("header", headerMap);
        model.put("list", dataList);

        //workbook 생성 (Excel 문서)
        Workbook workbook = new HSSFWorkbook();


        //파일 다운로드 확인 : setContentType 오류가 나도 문제 발생하지 않게
        doNothing().when(response).setContentType(anyString());
        when(response.getContentType()).thenReturn("application/vnd.ms-excel");
        
        //when
        // 엑셀 문서 생성
        excelBuilder.buildExcelDocument(model, workbook, request, response);

        //Then
        //엑셀 파일 응답 확인
        assertEquals("application/vnd.ms-excel", response.getContentType());



        // 바탕화면에 경로 설정
        String deskTopPath = Paths.get(System.getProperty("user.home"), "Desktop","test.xls").toString();

        try (FileOutputStream fileOutputStream = new FileOutputStream(deskTopPath)) {
            workbook.write(fileOutputStream);
            System.out.println("엑셀파일 저장완료"+deskTopPath);
        }catch (IOException e){
            e.printStackTrace();
        }

        workbook.close();
    }


}
