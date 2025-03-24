package mobile.factory.util;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * <pre>
 * 이 클래스는
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2016. 6. 23.
 * @time 오후 3:36:24
 **/
public class ExcelUtil {
	private static final Log logger = LogFactory.getLog(ExcelUtil.class);

	/**
	 * 엑셀파일 읽기
	 * 
	 * @param ins
	 * @param xlsxExcel
	 *            xlsx 여부
	 * @param sheetIdx
	 *            읽을 sheet index 0부터시작
	 * @param startRow
	 *            데이터가 있는 시작행, -1 이 헤더가 있다고 판단
	 * @param isTrim
	 *            데이터 trim 여부
	 * @return
	 * @throws Exception
	 */
	public static List<String[]> readExcel(InputStream ins, boolean xlsxExcel, int sheetIdx, int startRow, boolean isTrim) throws Exception {
		List<String[]> list = new ArrayList<String[]>();

		Workbook workbook = xlsxExcel ? new XSSFWorkbook(ins) : new HSSFWorkbook(ins);
		Sheet sheet = workbook.getSheetAt(sheetIdx);

		int endSheetRow = sheet.getLastRowNum();
		
		// 데이터Row는 Header의 Cell을 정확히 못가져오므로 추가
		Row headerRow = sheet.getRow(startRow - 1);

		for (int i = startRow; i < endSheetRow+1; i++) {
			Row excelRow = sheet.getRow(i);
			if(excelRow == null){
				break;
			}
			String[] row = new String[headerRow.getLastCellNum()];
			for (int j = 0, n = headerRow.getLastCellNum(); j < n; j++) {
//				Cell cell = excelRow.getCell(j, Row.CREATE_NULL_AS_BLANK);
//				row[j] = isTrim ? cell.toString().trim() : cell.toString();
			}
			list.add(row);
		}

		ins.close();
		workbook.close();

		return list;
	}

	/**
	 * 엑셀파일 읽기
	 * 
	 * @param ins
	 * @param xlsxExcel
	 * @return
	 * @throws Exception
	 */
	public static List<String[]> readExcel(InputStream ins, boolean xlsxExcel) throws Exception {
		return readExcel(ins, xlsxExcel, 0, 1, true);
	}
}
// :)--