package mobile.factory.spring;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import mobile.factory.spring.beans.BeanUploadFile;
import mobile.factory.util.DateUtil;
import mobile.factory.util.FileUtil;
//import sunnyyk.erp.common.util.LiteralDefine;

/**
 * <pre>
 * 이 클래스는 최상위 컨트롤러
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2016. 5. 11.
 * @time 오전 10:05:39
 **/
public abstract class ControlController {
	private Logger logger = LoggerFactory.getLogger(this.getClass());

	@Autowired
	protected ServletContext servletContext;
	
	/**
	 * Path가 있으면 사용, 없으면 webroot 사용
	 */
	@Value("${file.upload.path}")
	protected String fileUploadPath;

	/**
	 * fileupload
	 * 
	 * @param request
	 * @return
	 * @throws Exception
	 */
	protected List<InputStream> getFileList(HttpServletRequest request) throws Exception {
		List<InputStream> fileList = null;

		if (request instanceof MultipartHttpServletRequest) {
			fileList = new ArrayList<>();
			MultipartHttpServletRequest mpRequest = (MultipartHttpServletRequest) request;
			Iterator<String> fileNameIterator = mpRequest.getFileNames();

			while (fileNameIterator.hasNext()) {
				
				/* 단일input 다중파일 업로드에 대한 처리 추가 */
				List<MultipartFile> multiFiles = mpRequest.getFiles((String) fileNameIterator.next());
				for(MultipartFile multiFile : multiFiles) {
					if (multiFile.getSize() > 0) {
						fileList.add(multiFile.getInputStream());
					}
				}
			}
		}

		return fileList;
	}

	/**
	 * fileupload
	 * 
	 * @param request
	 * @return
	 * @throws Exception
	 */
	protected InputStream getFileStream(HttpServletRequest request) throws Exception {
		List<InputStream> list = getFileList(request);
		if (list != null && list.size() > 0) {
			return list.get(0);
		}
		return null;
	}

	/**
	 * file upload
	 *
	 * @param request
	 * @param filePath 파일이 저장될 위치 * 주의: file/ 와 같이 위에 '/'만 붙임
	 * @return
	 */
	protected  List<BeanUploadFile> getFileList(HttpServletRequest request, String filePath) {
		return getFileList(request, filePath, "");
	}

	/**
	 * file upload
	 *
	 * @param request
	 * @param filePath 파일이 저장될 위치 * 주의: file/ 와 같이 위에 '/'만 붙임
	 * @param imgResize 이미지일때 가로/세로 가 넘어가면 리사이징함
	 * @return
	 */
	protected  List<BeanUploadFile> getFileList(HttpServletRequest request, String filePath, int imgResize) {
		return getFileList(request, filePath, "", imgResize);
	}

	/**
	 * file upload
	 *
	 * @param request
	 * @param filePath 파일이 저장될 위치 * 주의: file/ 와 같이 위에 '/'만 붙임
	 * @param resizeWidth 이미지일때 가로가 넘어가면 리사이징함
	 * @param resizeHeight 이미지일때 세로가 넘어가면 리사이징함
	 * @return
	 */
	protected  List<BeanUploadFile> getFileList(HttpServletRequest request, String filePath, int resizeWidth, int resizeHeight) {
		return getFileList(request, filePath, "", resizeWidth, resizeHeight);
	}

	/**
	 * file upload
	 *
	 * @param request
	 * @param filePath
	 *            : 파일이 저장될 위치 * 주의: file/ 와 같이 위에 '/'만 붙임
	 * @param fileName
	 *            파일명 확장자포함
	 * @return
	 */
	protected List<BeanUploadFile> getFileList(HttpServletRequest request, String filePath, String fileName) {
		return getFileList(request, filePath, fileName, 0);
	}

	/**
	 * file upload
	 * 
	 * @param request
	 * @param filePath
	 *            : 파일이 저장될 위치 * 주의: file/ 와 같이 위에 '/'만 붙임
	 * @param fileName
	 *            파일명 확장자포함
	 * @param imgResize 이미지일때 가로/세로 가 넘어가면 리사이징함
	 * @return
	 */
	protected List<BeanUploadFile> getFileList(HttpServletRequest request, String filePath, String fileName, int imgResize) {
		return getFileList(request, filePath, fileName, imgResize, imgResize);
	}

	/**
	 * file upload
	 *
	 * @param request
	 * @param filePath
	 *            : 파일이 저장될 위치 * 주의: file/ 와 같이 위에 '/'만 붙임
	 * @param fileName
	 *            파일명 확장자포함
	 * @param resizeWidth 이미지일때 가로가 넘어가면 리사이징함
	 * @param resizeHeight 이미지일때 세로가 넘어가면 리사이징함
	 * @return
	 */
	protected List<BeanUploadFile> getFileList(HttpServletRequest request, String filePath, String fileName, int resizeWidth, int resizeHeight) {
		List<BeanUploadFile> fileList = new ArrayList<BeanUploadFile>();

		if (request instanceof MultipartHttpServletRequest) {
			MultipartHttpServletRequest mpRequest = (MultipartHttpServletRequest) request;
			Iterator<String> fileNameIterator = mpRequest.getFileNames();

			while (fileNameIterator.hasNext()) {
				/* 단일input 다중파일 업로드에 대한 처리 추가 */
				List<MultipartFile> multiFiles = mpRequest.getFiles((String) fileNameIterator.next());
				for(MultipartFile multiFile : multiFiles) {
					if (multiFile.getSize() > 0) {
						BeanUploadFile uploadFile = FileUtil.uploadFormFile(multiFile, getRealDirPath(filePath), false, fileName, resizeWidth, resizeHeight);
						fileList.add(uploadFile);
					}
				}

			}
		}

		return fileList;
	}

	/**
	 * fileupload
	 * 
	 * @param request
	 * @return
	 * @throws Exception
	 */
	protected BeanUploadFile getFileBean(HttpServletRequest request, String filePath) {
		return getFileBean(request, filePath, null, 0);
	}

	/**
	 * 파일 업로드
	 * @param request
	 * @param filePath 파일저장할 Path
	 * @param imgResize 이미지일때 리사이징 사이즈(원본이 클때만 적용)
	 * @return
	 */
	protected BeanUploadFile getFileBean(HttpServletRequest request, String filePath, int imgResize) {
		return getFileBean(request, filePath, null, imgResize);
	}

	/**
	 * 파일업로드
	 *
	 * @param request
	 * @param filePath  파일저장할 Path
	 * @param fileName  확장자를 포함한파일명.
	 * @param imgResize
	 * @return
	 */
	protected BeanUploadFile getFileBean(HttpServletRequest request, String filePath, String fileName, int imgResize) {
		List<BeanUploadFile> list = getFileList(request, filePath, fileName, imgResize);
		BeanUploadFile uploadFile = null;
		if (list != null && list.size() > 0) {
			uploadFile = list.get(0);
		}
		return uploadFile;
	}

	/**
	 * 파일리스트 가져오기
	 * 
	 * @param request
	 * @param filePath
	 * @return
	 */
	protected Map<String, BeanUploadFile> getFileListMap(HttpServletRequest request, String filePath) {
		List<BeanUploadFile> list = getFileList(request, filePath);


		Map<String, BeanUploadFile> map = new  HashMap<String, BeanUploadFile>();
		for (BeanUploadFile bean : list) {
			map.put(bean.getFileName(), bean);
		
		}

		return map;
	}

	/**
	 * 실제 경로에서 웹으로 접속되는 경로를 반환
	 * 
	 * @param fileRealPath
	 *            실제 경로에 저장되는 경로
	 * @return web_path
	 */
	protected String getWebFilePath(String fileRealPath) {
		return StringUtils.removeStart(fileRealPath, getRealDirPath());
	}

	protected String getRealDirPath() {
		return getRealDirPath(null);
	}

	/**
	 * 컨텍스트의 디렉토리 경로를 알아옴
	 * 
	 * @param dirName
	 *            "report/aaa" 앞에 "/"제외
	 * @return
	 */
	protected String getRealDirPath(String dirName) {
		return FileUtil.getSavePath(servletContext, fileUploadPath, dirName);
	}
	
	/**
	 * 파일쓰기
	 * @param contentType
	 * @param response
	 * @param baos
	 * @param fileName 파일명(확장자포함)
	 * @throws UnsupportedEncodingException 
	 */
	protected void writeExportToResponseStream(String contentType, HttpServletResponse response, ByteArrayOutputStream baos, String fileName) throws UnsupportedEncodingException {
		response.setContentType(contentType);
		response.setContentLength(baos.size());

		fileName = "".equals(fileName) ? String.format("file_%s", DateUtil.getCurrentDatetimeMilisecond()) : fileName;
		String downFilename = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20"); // 파일명 공백이 (+)로 나오지 않게 수정(Q&A 13704, 22-07-21, 손광진)

		// PDF 새페이지에서 그냥 보여줄 경우 addheader 하지않음 
//		if (LiteralDefine.CONTENT_TYPE_PDF.equals(contentType) == false) {
//			response.addHeader("Content-Disposition", "attachment; filename=" + downFilename);
//		}
//
//		try {
//			ServletOutputStream out = response.getOutputStream();
//			baos.writeTo(out);
//			out.flush();
//			baos.close();
//		} catch (Exception e) {
//			logger.error("", e);
//		}
	}
	
	/**
	 * 파일쓰기
	 * @param contentType
	 * @param response
	 * @param baos
	 * @throws UnsupportedEncodingException 
	 */
	protected void writeExportToResponseStream(String contentType, HttpServletResponse response, ByteArrayOutputStream baos) throws UnsupportedEncodingException {
		writeExportToResponseStream(contentType, response, baos, "");
	}

	/**
	 * 파일쓰기
	 * 
	 * @param contentType
	 * @param response
	 * @param file
	 * @throws IOException
	 */
	protected void writeExportToResponseStream(String contentType, HttpServletResponse response, File file) throws IOException {
		writeExportToResponseStream(contentType, response, file, "");
	}

	/**
	 * 파일쓰기
	 * @param contentType
	 * @param response
	 * @param file
	 * @param fileName 파일명(확장자포함)
	 * @throws IOException
	 */
	protected void writeExportToResponseStream(String contentType, HttpServletResponse response, File file, String fileName) throws IOException {
		writeExportToResponseStream(contentType, response, FileUtil.toByteArrayOutputStream(file), fileName);
	}

	/**
	 * 파일쓰기
	 * 
	 * @param contentType
	 * @param response
	 * @param fullFilePath
	 * @throws IOException
	 */
	protected void writeExportToResponseStream(String contentType, HttpServletResponse response, String fullFilePath) throws IOException {
		writeExportToResponseStream(contentType, response, fullFilePath, "");
	}
	
	/**
	 * 파일쓰기
	 * @param contentType
	 * @param response
	 * @param fullFilePath
	 * @param fileName 파일명(확장자포함)
	 * @throws IOException
	 */
	protected void writeExportToResponseStream(String contentType, HttpServletResponse response, String fullFilePath, String fileName) throws IOException {
		writeExportToResponseStream(contentType, response, new File(fullFilePath), fileName);
	}
	
	
	/**
	 * 압축파일 생성 후 내리기
	 * @param response
	 * @param List<BeanFile>
	 * @param fileName 파일명(확장자포함)
	 * @throws IOException 
	 */
	protected void writeExportToZipFile(List<Map<String, String>> list, String zipfileName,HttpServletResponse response) throws IOException {
		//임시저장이름
	    String zipFile = "tempt.zip";

			    
		FileOutputStream zipFileOutputStream = new FileOutputStream(zipFile);
		ZipOutputStream zout = new ZipOutputStream(zipFileOutputStream);
			
		for( Map<String, String> map : list){
			
			 //본래 파일명 유지
		       ZipEntry zipEntry = new ZipEntry(map.get("origin_file_name").toString());

		       zout.putNextEntry(zipEntry);

		       FileInputStream fileInputStream = new FileInputStream(map.get("file_path").toString());
		       byte[] buffer = new byte[1024];
		       int length;

		       // input file을 1024바이트로 읽음, zip stream에 읽은 바이트를 씀
		       while((length = fileInputStream.read(buffer)) > 0){
		           zout.write(buffer, 0, length);
		       }

		       zout.closeEntry();
		       fileInputStream.close();			
		}
		
		zout.close();
		
	    response.setContentType("application/zip");
	    response.addHeader("Content-Disposition", "attachment; filename=" + zipfileName + ".zip");
 
	    FileInputStream fileInputStream = new FileInputStream(zipFile);
	    BufferedInputStream bufferedInputStream = new BufferedInputStream(fileInputStream);
	    ServletOutputStream servletOutputStream = response.getOutputStream();
	    BufferedOutputStream bufferedOutputStream = new BufferedOutputStream(servletOutputStream );

	    byte[] data=new byte[2048];
	    int input=0;

	    while((input=bufferedInputStream.read(data))!=-1){
	        bufferedOutputStream .write(data,0,input);
	        bufferedOutputStream .flush();
	    }

	    if(bufferedOutputStream !=null) {
	    	bufferedOutputStream .close();
	    }
	    if(bufferedInputStream!=null) {
	    	bufferedInputStream.close();
	    }
	    if(servletOutputStream !=null) {
	    	servletOutputStream .close();
	    }
	    if(fileInputStream!=null) {
	    	fileInputStream.close();
	    }
	}
		
}
// :)--