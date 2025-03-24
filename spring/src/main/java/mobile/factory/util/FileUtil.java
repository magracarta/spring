package mobile.factory.util;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.nio.channels.FileChannel;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Random;
import java.util.regex.Pattern;

import org.apache.commons.fileupload.disk.DiskFileItem;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.web.multipart.MultipartFile;

import mobile.factory.spring.beans.BeanUploadFile;
import org.springframework.web.multipart.support.StandardServletMultipartResolver;

import javax.imageio.ImageIO;
import jakarta.servlet.ServletContext;

/**
 * <pre>
 * 이 클래스는 
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2016. 6. 16. 
 * @time 오후 6:58:42
**/
public class FileUtil {
	private static Log logger = LogFactory.getLog(FileUtil.class);
	
	/**
	 * 파일 Path 구분자
	 */
	public static String SEPARATOR = "/";

	public static final Pattern DOS_SEPARATOR = Pattern.compile("\\\\");
	
	/**
	 * 파일복사
	 * @param source
	 * @param target
	 */
	public static void copy(File source, File target) {
		copy(source.getAbsolutePath(), target.getAbsolutePath());
	}

	/**
	 * source에서 target으로의 파일 복사
	 * 
	 * @param source
	 *            복사할 파일명을 포함한 절대 경로
	 * @param target
	 *            복사될 파일명을 포함한 절대경로
	 */
	public static void copy(String source, String target) {
		createFileIfNotExists(target);

		// 복사 대상이 되는 파일 생성
		File sourceFile = new File(source);

		// 스트림, 채널 선언
		FileInputStream inputStream = null;
		FileOutputStream outputStream = null;
		FileChannel fcin = null;
		FileChannel fcout = null;

		try {
			// 스트림 생성
			inputStream = new FileInputStream(sourceFile);
			outputStream = new FileOutputStream(target);
			// 채널 생성
			fcin = inputStream.getChannel();
			fcout = outputStream.getChannel();

			// 채널을 통한 스트림 전송
			long size = fcin.size();
			fcin.transferTo(0, size, fcout);

		} catch (Exception e) {
			logger.error(e);
		} finally {
			// 자원 해제
			try {
				fcout.close();
			} catch (IOException ioe) {
				logger.error(ioe);
			}
			try {
				fcin.close();
			} catch (IOException ioe) {
				logger.error(ioe);
			}
			try {
				outputStream.close();
			} catch (IOException ioe) {
				logger.error(ioe);
			}
			try {
				inputStream.close();
			} catch (IOException ioe) {
				logger.error(ioe);
			}
		}
	}

	/**
	 * 파일디렉토리 체크후 없으면 생성
	 * 
	 * @param dirName
	 */
	public static String createDirIfNotExists(String dirName) {
		String fileOrDir = StringUtils.substringAfterLast(dirName, SEPARATOR);
		if(StringUtils.contains(fileOrDir, ".")) {
			dirName = StringUtils.substringBeforeLast(dirName, SEPARATOR);
		}

		String[] dir = dirName.split(SEPARATOR);

		String osName = System.getProperty("os.name");
		boolean isWin = StringUtils.containsIgnoreCase(osName, "WINDOWS");

		dirName = "";
		for (int i = 0, n = dir.length; i < n; i++) {
			if (StringUtils.isNotBlank(dir[i])) {
				if (isWin) {
					dirName += ((i > 0 ? SEPARATOR : "") + dir[i]);
				} else {
					dirName += (SEPARATOR + dir[i]);
				}
			}
		}

		File localPath = new File(dirName);
		if (!localPath.exists()) {
			localPath.mkdirs();
		}
		return dirName;
	}

	/**
	 * 디렉토리 확인후 없으면 생성
	 * 
	 * @param dirName
	 *            디렉토리 명
	 * @param addYearMonth
	 *            디렉토리 뒤에 년월 붙일 여부
	 * @return
	 */
	public static String createDirIfNotExists(String dirName, boolean addYearMonth) {
		String dirPath;
		if (addYearMonth) {
			dirPath = createDirIfNotExists(dirName + DateUtil.getCurrentDate("yyyyMM") + SEPARATOR);
		} else {
			dirPath = createDirIfNotExists(dirName);
		}
		return dirPath.endsWith(SEPARATOR) ? dirPath : dirPath + SEPARATOR;
	}

	/**
	 * 파일 존재 여부 확인후 없으면 생성한다.
	 * 
	 * @param fileName
	 * @return
	 */
	public static boolean createFileIfNotExists(String fileName) {
		File file = new File(fileName);
		if (file.exists() == false) {
			try {
				createDirIfNotExists(fileName);
				return file.createNewFile();
			} catch (IOException ignore) {
				return false;
			}
		}
		return true;
	}

	/**
	 * 파일삭제
	 * 
	 * @param path
	 *            디렉토리는 하위모두, 파일은 특정파일만 삭제
	 */
	public static void delete(String path) {
		if (existsFile(path) == false) {
			return;
		}

		File file = new File(path);
		if (file.isDirectory()) {
			deleteDirectory(path);
		} else {
			deleteFile(path);
		}
	}

	/**
	 * path부터 하위폴더 전체 삭제
	 * 
	 * @param path
	 *            경로
	 */

	public static void deleteDirectory(String path) {
		logger.debug("Directory 통으로 삭제  : " + path);

		File file = new File(path);
		File[] childFiles = file.listFiles();

		for (File childfile : childFiles) {
			if (childfile.isDirectory()) {
				deleteDirectory(childfile.getAbsolutePath());
			} else {
				childfile.delete();
			}
		}
		file.delete();
	}

	/**
	 * 파일삭제
	 * 
	 * @param fileFullPath
	 * @return 존재하고 삭제 성공시만 true
	 */
	public static boolean deleteFile(String fileFullPath) {
		boolean result = false;
		if (existsFile(fileFullPath)) {
			result = (new File(fileFullPath)).delete();
		}
		return result;
	}

	/**
	 * 파일 존재 여부 판단
	 * 
	 * @param fileFullPath
	 * @return
	 */
	public static boolean existsFile(String fileFullPath) {
		return (new File(fileFullPath)).exists();
	}

	/**
	 * file 이름에 확장자가 있다면 확장자를 return하고 없으면, 그냥 공백 String을 반환하는 메소드.
	 * 
	 * @param filename
	 * @return
	 */
	public static String getFilenameExt(String filename) {
		return StringUtils.substringAfterLast(filename, ".");
	}

	/**
	 * 파일 사이즈 구하기
	 * 
	 * @param fullPath
	 * @return default is -1
	 */
	public static long getFileSize(String fullPath) {
		if (existsFile(fullPath)) {
			return (new File(fullPath)).length();
		} else {
			return -1;
		}
	}

	/**
	 * 파일 이름으로 사용할 중복되지 않은 Unique String을 만들어줌.(20자리)
	 * 
	 * @return
	 */
	public static String getNextSerial() {
		// 이 로직은 추후 DB의 squence를 사용하는 식으로 수정해도 됨.
		// 아마도 그게 더 바람직할 듯...
		Random random = new Random();
		String front = StringUtils.leftPad(random.nextInt(999) + "", 3, "0");
		String end = StringUtils.leftPad(random.nextInt(99) + "", 2, "0");
		String uid = String.format("%s%s%s", front, DateUtil.getCurrentDate("yyMMddHHmmssSSS"), end);

		return uid;
	}

	/**
	 * 파일 내용 가져옴
	 * 
	 * @param fullPath
	 * @return
	 */
	public static List<String> readTextFile(String fullPath) {
		String line;
		List<String> list = new ArrayList<>();

		try {
			FileReader reader = new FileReader(new File(fullPath));
			BufferedReader bufferedReader = new BufferedReader(reader);

			while (true) {
				line = bufferedReader.readLine();
				if (line == null) {
					break;
				}
				list.add(line);
			}
			reader.close();
			bufferedReader.close();
		} catch (Exception e) {
			logger.error("", e);
		}

		return list;
	}
	
	/**
	 * 파일쓰기
	 * 
	 * @param list
	 * @param fullPath
	 *            파일저장할 풀경로를 포함.. /xxx/bbb/zzz.txt
	 * @return
	 * @throws Exception
	 */
	public static boolean writeTextFile(List<String> list, String fullPath) throws Exception {
		if (createFileIfNotExists(fullPath)) {
			// BufferedWriter 와 FileWriter를 조합하여 사용 (속도 향상)
			BufferedWriter fw = new BufferedWriter(new FileWriter(fullPath));

			for (String row : list) {
				fw.write(row);
				fw.newLine();
			}
			fw.flush();
			fw.close();

			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * 서블릿에서 파일 업로드시 사용(파일명 자동생성)
	 * 
	 * @param formFile
	 * @param realPath
	 * @return
	 */
	public static BeanUploadFile uploadFormFile(MultipartFile formFile, String realPath) {
		return uploadFormFile(formFile, realPath, true, "");
	}

	/**
	 * 서블릿에서 파일 업로드시 사용
	 * @param formFile
	 * @param realPath
	 * @param addYearDir
	 * @param fileName
	 * @return
	 */
	public static BeanUploadFile uploadFormFile(MultipartFile formFile, String realPath, boolean addYearDir, String fileName) {
		return uploadFormFile(formFile, realPath, addYearDir, fileName, 0);
	}



	/**
	 * 서블릿에서 파일 업로드시 사용
	 *
	 * @param formFile
	 * @param realPath
	 * @param fileName 생성할 파일명 확장자포함
	 * @param imgResize 이미지일때 리사이징 사이즈, 0이면 변환안함.
	 * @return
	 */
	public static BeanUploadFile uploadFormFile(MultipartFile formFile, String realPath, boolean addYearDir, String fileName, int imgResize) {
		return uploadFormFile(formFile, realPath, addYearDir, fileName, imgResize, imgResize);
	}

	/**
	 * 서블릿에서 파일 업로드시 사용
	 *
	 * @param formFile
	 * @param realPath
	 * @param fileName 생성할 파일명 확장자포함
	 * @param resizeWidth 이미지일때 가로리사이징 사이즈, 0이면 변환안함.
	 * @param resizeHeight 이미지일때 세로리사이징 사이즈, 0이면 변환안함.
	 * @return
	 */
	public static BeanUploadFile uploadFormFile(MultipartFile formFile, String realPath, boolean addYearDir, String fileName, int resizeWidth, int resizeHeight) {
		InputStream stream;

		realPath = createDirIfNotExists(realPath, addYearDir);
		
		String filenameExt = getFilenameExt(formFile.getOriginalFilename());
		String tempFileName = String.format("%s.%s", FileUtil.getNextSerial(), filenameExt);
		String fullFileName = String.format("%s%s", realPath, StringUtils.isBlank(fileName) ? tempFileName : fileName);
		String originFileName = fullFileName;

		try {
			stream = formFile.getInputStream();

			// write the file to the file specified
			OutputStream bos = new FileOutputStream(fullFileName);
			int bytesRead = 0;
			byte[] buffer = new byte[8192];
			while ((bytesRead = stream.read(buffer, 0, 8192)) != -1) {
				bos.write(buffer, 0, bytesRead);
			}
			bos.close();
			stream.close();

			if (logger.isDebugEnabled()) {
				logger.debug("The file has been written to \"" + fullFileName);
			}
		} catch (FileNotFoundException e) {
			logger.error(e);
		} catch (IOException e) {
			logger.error(e);
		}

		File resizedImage = null;

		try {
			// 이미지 변환일때만 동작 (이미지 리사이징)
			BufferedImage newImage = ImageIO.read(new File(fullFileName));
			if (ImageUtil.isImageFile(fullFileName)) {
				if ((resizeWidth > 0 && resizeWidth < newImage.getWidth()) || (resizeHeight > 0 && resizeHeight < newImage.getHeight())) {
					resizedImage = ImageUtil.resizedImage(new File(fullFileName), resizeWidth, resizeHeight, fullFileName, true);

					// 2024-03-22 (황빛찬) : 용량제한으로 인하여 이미지 리사이징 파일 저장 후 원본 파일 삭제 로직 추가
					deleteFile(fullFileName);
				}
			}
		} catch (Exception ignore) {
			logger.warn(ignore);
		}

		// 리사이징된 파일일 경우
		if (resizedImage != null) {
			tempFileName = resizedImage.getName();
			// BufferedImage가 반환하는 파일의 path는 역슬래시로 되어있어서, 원본파일의 path에 리사이징된 파일 name을 붙임.
			fullFileName = String.format("%s%s", realPath, StringUtils.isBlank(fileName) ? tempFileName : fileName);
		}

		BeanUploadFile beanUploadFile = new BeanUploadFile();
		beanUploadFile.setFileName(formFile.getOriginalFilename());
		beanUploadFile.setFileSize(formFile.getSize());
		beanUploadFile.setContentType(formFile.getContentType());
		beanUploadFile.setTempFileName(tempFileName);
		beanUploadFile.setFullFileName(fullFileName);
		beanUploadFile.setFieldName(formFile.getName());
		beanUploadFile.setOriginFilePath(originFileName);

		return beanUploadFile;
	}
	
	/**
	 * ByteArrayOutputStream 으로 변환
	 * @param file
	 * @return
	 * @throws IOException
	 */
	public static ByteArrayOutputStream toByteArrayOutputStream(File file) throws IOException {
		FileInputStream fis = new FileInputStream(file);

		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] buf = new byte[1024];
		for (int readNum; (readNum = fis.read(buf)) != -1;) {
			bos.write(buf, 0, readNum); // no doubt here is 0
		}
		fis.close();

		return bos;
	}

	/**
	 * 디렉토리 구분자를 '/' 로 변환
	 * @param fullFileName
	 * @return
	 */
	public static String replaceSeparator(String fullFileName) {
		return DOS_SEPARATOR.matcher(fullFileName).replaceAll("/");
	}

	/**
	 * 서블릿에서 다운로드URL로 파일 업로드시 사용
	 * @param url
	 * @param realPath
	 * @param fileName
	 * @return
	 */
	public static BeanUploadFile urlToUploadFormFile(String url, String realPath, String fileName) {
		BeanUploadFile beanUploadFile = new BeanUploadFile();
		try {
			// URL to File
			URL downUrl = new URL(url);

			String filenameExt = getFilenameExt(fileName);
			String tempFileName = String.format("%s.%s", FileUtil.getNextSerial(), filenameExt);
			String fullFileName = String.format("%s%s", realPath, tempFileName);
			File file = new File(String.format("%s/%s", realPath, tempFileName));
			FileUtils.copyURLToFile(downUrl, file);

			// File to MultipartFile
			DiskFileItem fileItem = new DiskFileItem("file", Files.probeContentType(file.toPath()), false, fileName, (int) file.length(), file.getParentFile());
			InputStream input = new FileInputStream(file);
			OutputStream os = fileItem.getOutputStream();
			IOUtils.copy(input, os);
//			MultipartFile multiFile = new CommonsMultipartFile(fileItem);

//			beanUploadFile.setFileName(multiFile.getOriginalFilename());
//			beanUploadFile.setFileSize(multiFile.getSize());
//			beanUploadFile.setContentType(multiFile.getContentType());
//			beanUploadFile.setTempFileName(tempFileName);
//			beanUploadFile.setFullFileName(fullFileName);
//			beanUploadFile.setFieldName(multiFile.getName());
//			beanUploadFile.setOriginFilePath(fullFileName);
		} catch (Exception e){
			beanUploadFile = null;
			logger.error("", e);
		}

		return beanUploadFile;
	}

	/**
	 * base64 인코딩
	 * @param file
	 * @return
	 * @throws IOException
	 */
	public static String encodingBase64(File file) throws IOException {
		byte[] fileByte = Files.readAllBytes(Paths.get(file.getAbsolutePath()));
		byte[] encodedBytes = Base64.getEncoder().encode(fileByte);
		String encodedString = new String(encodedBytes);

		return encodedString;
	}

	/**
	 * 저장될 디렉토리 경로를 구함
	 * @param servletContext prefixRoot가 없으면, 실제 app 하위 경로 사용
	 * @param prefixRoot 있으면 실제 app 경로 무시
	 * @param dirName 하위 디렉토리
	 * @return
	 */
	public static String getSavePath(ServletContext servletContext, String prefixRoot, String dirName) {
		String realPath = null;
		if(StringUtils.isNotBlank(prefixRoot)) {
			realPath = StringUtils.removeEnd(prefixRoot, "/");
		} else {
			realPath = StringUtils.replace(servletContext.getRealPath(""), "\\", "/");
			realPath = StringUtils.removeEnd(realPath, "/");
		}

		if (StringUtils.isNotBlank(dirName)) {
			dirName = StringUtils.startsWith(dirName, "/") ? dirName : String.format("/%s", dirName);
			return realPath + dirName;
		} else {
			return realPath;
		}
	}

	/**
	 * 저장될 디렉토리 경로를 구함(실제 app 하위 경로 사용)
	 * @param servletContext
	 * @param dirName 하위 디렉토리
	 * @return
	 */
	public static String getSavePath(ServletContext servletContext, String dirName) {
		return getSavePath(servletContext, "", dirName);
	}

	/**
	 * 저장될 디렉토리 경로를 구함
	 * @param prefixRoot
	 * @param dirName 하위 디렉토리
	 * @return
	 */
	public static String getSavePath(String prefixRoot, String dirName) {
		return getSavePath(null, prefixRoot, dirName);
	}

	/**
	 * 파일읽기
	 * @param inputStream
	 * @return
	 */
	public static String readTextFile(InputStream inputStream) {
		return readTextFile(inputStream, "UTF-8");
	}

	/**
	 * 파일읽기
	 * @param inputStream
	 * @param encoding
	 * @return
	 */
	public static String readTextFile(InputStream inputStream, String encoding) {
		String content = "";

		try {
			int ca = inputStream.available();
			byte[] by = new byte[ca];

			inputStream.read(by);
			content = new String(by, encoding);
			inputStream.close();

		} catch (FileNotFoundException e) {
			logger.error("", e);
		} catch (IOException e) {
			logger.error("", e);
		}

		return content;

	}
}
//:)--