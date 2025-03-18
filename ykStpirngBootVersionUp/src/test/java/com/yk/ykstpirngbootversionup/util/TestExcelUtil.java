package com.yk.ykstpirngbootversionup.util;

import org.junit.Test;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.List;

public class TestExcelUtil {
    @Test
    public void test() {
        String userHome = System.getProperty("user.home");
        String deskTop = userHome + File.separator + "Desktop"+File.separator+"test.xls";

        File file = new File(deskTop);

        try {
            InputStream inputStream = new FileInputStream(file);
            List<String[]> excel = ExcelUtil.readExcel(inputStream, false);

            for (String[] row : excel) {
                for (String cell : row) {
                    System.out.print(cell + "  ");
                }
                System.out.println();
            }


        } catch (Exception e) {
            throw new RuntimeException(e);
        }


    }
}
