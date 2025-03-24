package mobile.factory.spring;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.*;
import org.springframework.web.servlet.view.document.AbstractXlsView;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ExcelBuilder extends AbstractXlsView {
	@Override
	protected void buildExcelDocument(Map<String, Object> model, Workbook workbook, HttpServletRequest request, HttpServletResponse response) throws Exception {

		Map<String, Object> headerMap = (Map<String, Object>) model.get("header");
		List<Map<String, Object>> dataList = (List<Map<String, Object>>) model.get("list");

		// create a new Excel sheet
		Sheet sheet = workbook.createSheet("Data");
		sheet.setDefaultColumnWidth(10);

		// create style for header cells
		CellStyle style = workbook.createCellStyle();
		Font font = workbook.createFont();
		System.out.println(font);
		font.setFontName("Arial");
		style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.index);
		style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		font.setBold(true);
		font.setColor(IndexedColors.WHITE.index);
		style.setFont(font);

		// create header row
		Row header = sheet.createRow(0);

		int idx = 0;
		for (String key : headerMap.keySet()) {
			if(headerMap.get(key) instanceof LinkedHashMap){
				LinkedHashMap<String, Object> map1 = (LinkedHashMap<String, Object>) headerMap.get(key);

				String name = map1.get("title").toString().replaceAll("<br>", "");

				header.createCell(idx).setCellValue(name);
				header.getCell(idx).setCellStyle(style);

			} else {
				String name = headerMap.get(key).toString();

				header.createCell(idx).setCellValue(name);
				header.getCell(idx).setCellStyle(style);
			}

			idx++;
		}

		// create data rows
		int rowCount = 1;
		if(dataList != null){
			for (Map<String, Object> row : dataList) {
				Row aRow = sheet.createRow(rowCount++);

				int rowIdx = 0;
				for (String key : headerMap.keySet()) {
					if(row.get(key) != null){
						aRow.createCell(rowIdx++).setCellValue(row.get(key).toString());
					}
				}
			}
		}
	}
}
