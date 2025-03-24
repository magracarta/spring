package mobile.factory.spring.beans;

import org.apache.commons.lang3.StringUtils;

/**
 * 파일 업로드 한 정보를 담고 있는 빈
 * 
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 09. 19
 */
public class BeanUploadFile {
	private int fileNo;
	private String fileName;
	private String tempFileName;
	private long fileSize;
	private String contentType;
	private String fullFileName;
	private String fieldName;
	private String realFileName;
	private String fileExt;

	/**
	 * 업로드한 원본 파일
	 */
	private String originFilePath;

	public String getOriginFilePath() {
		return originFilePath;
	}

	public void setOriginFilePath(String originFilePath) {
		this.originFilePath = originFilePath;
	}

	public String getFileExt() {
		return StringUtils.substringAfterLast(getRealFileName(), ".");
	}

	public String getRealFileName() {
		return StringUtils.substringAfterLast(fullFileName, "/");
	}

	public void setRealFileName(String realFileName) {
		this.realFileName = realFileName;
	}

	public int getFileNo() {
		return fileNo;
	}

	public void setFileNo(int fileNo) {
		this.fileNo = fileNo;
	}

	public String getFileName() {

		// 브라우저별 : 실제파일명만 반환하게 처리 ( 전체경로로 반환되는경우 경우 )
		// IE : D:\\sss\sdfsd\sdfs.xls => sdfx.xls

		if (fileName == null) {
			// Should never happen.
			return "";
		}
		// Check for Unix-style path
		int unixSep = fileName.lastIndexOf("/");
		// Check for Windows-style path
		int winSep = fileName.lastIndexOf("\\");
		// Cut off at latest possible point
		int pos = (winSep > unixSep ? winSep : unixSep);
		if (pos != -1) {
			// Any sort of path separator found...
			return fileName.substring(pos + 1);
		} else {
			// A plain name
			return fileName;
		}
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getTempFileName() {
		return tempFileName;
	}

	public void setTempFileName(String tempFileName) {
		this.tempFileName = tempFileName;
	}

	public long getFileSize() {
		return fileSize;
	}

	public void setFileSize(long fileSize) {
		this.fileSize = fileSize;
	}

	public String getContentType() {
		return contentType;
	}

	public void setContentType(String contentType) {
		this.contentType = contentType;
	}

	public String getFullFileName() {
		return fullFileName;
	}

	public void setFullFileName(String fullFileName) {
		this.fullFileName = fullFileName;
	}

	public String getFieldName() {
		return fieldName;
	}

	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}

	public int getFileIntSize() {
		return (new Long(fileSize)).intValue();
	}
}
// :)--