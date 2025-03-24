package mobile.factory.util;

import org.apache.commons.lang3.StringUtils;
import org.springframework.util.CollectionUtils;

import java.io.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

/**
 * <pre>
 *  압축관련 유틸
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2022. 9. 30.
 * @time 오전 10:20:40
 **/
public class ZipUtil {

    private static final int COMPRESSION_LEVEL = 8;

    private static final int BUFFER_SIZE = 1024 * 2;

    /**
     * 파일(들)을 Zip 파일로 압축한다.
     *
     * @param fileList
     *            - 압출 대상 파일 리스트
     * @param zipName
     *            - 저장 zip 파일 이름
     * @throws Exception
     */
    public static void zip(List<Map<String, Object>> fileList, String zipName) throws Exception {

        // 파일이 없다면 리턴한다.
        if (CollectionUtils.isEmpty(fileList)) {
            throw new Exception("압축 대상 파일이 없습니다.");
        }

        // output 의 확장자가 zip이 아니면 리턴한다.
        if (!(StringUtils.substringAfterLast(zipName, ".")).equalsIgnoreCase("zip")) {
            throw new Exception("압축 후 저장 파일명의 확장자를 확인하세요");
        }

        FileOutputStream fos = null;
        BufferedOutputStream bos = null;
        ZipOutputStream zos = null;

        try {
            fos = new FileOutputStream(zipName); // FileOutputStream
            bos = new BufferedOutputStream(fos); // BufferedStream
            zos = new ZipOutputStream(bos); // ZipOutputStream
            zos.setLevel(COMPRESSION_LEVEL); // 압축 레벨 - 최대 압축률은 9, 디폴트 8
            zipEntry(fileList, zos); // Zip 파일 생성
            zos.finish(); // ZipOutputStream finish
        } finally {
            if (zos != null) {
                zos.close();
            }
            if (bos != null) {
                bos.close();
            }
            if (fos != null) {
                fos.close();
            }
        }
    }

    /**
     * 파일(들)을 Zip 파일에 추가한다.
     *
     * @param fileList 압축 대상 파일 리스트
     * @param zos 압축파일
     * @throws Exception
     */
    private static void zipEntry(List<Map<String, Object>> fileList, ZipOutputStream zos) throws Exception {
        BufferedInputStream bis = null;

        try {
            Map<String, Integer> idxMap = new HashMap<>();
            for (Map<String, Object> map : fileList) {
                File sourceFile = new File(map.get("file_path")+"");

                bis = new BufferedInputStream(new FileInputStream(sourceFile));
                String fileName = map.get("file_name")+"";

                String firstFileName = fileName.substring(0, fileName.lastIndexOf("."));
                String extName = fileName.substring(fileName.lastIndexOf("."));

                if(idxMap.containsKey(fileName)) {
                    idxMap.put(fileName, idxMap.get(fileName)+1);
                } else {
                    idxMap.put(fileName, 0);
                }

                String outFileName = "";
                if(0 != idxMap.get(fileName)) {
                    outFileName = firstFileName + " (" + idxMap.get(fileName) + ")" + extName;
                } else {
                    outFileName = fileName;
                }

                ZipEntry zentry = new ZipEntry(outFileName); // origin_file_name 으로 zip안에 파일명 세팅
                zentry.setTime(sourceFile.lastModified());
                zos.putNextEntry(zentry);

                byte[] buffer = new byte[BUFFER_SIZE];
                int cnt = 0;
                while ((cnt = bis.read(buffer, 0, BUFFER_SIZE)) != -1) {
                    zos.write(buffer, 0, cnt);
                }
                zos.closeEntry();
            }

        } finally {
            if (bis != null) {
                bis.close();
            }
        }
    }

    /**
     * 파일압축
     *
     * @param files
     * @param zipFileName
     * @throws Exception
     */
    public static void zipEntry(String[] files, String zipFileName) throws Exception {
        // 파일을 읽기위한 버퍼
        byte[] buf = new byte[1024];

        try {
            // 압축파일명
            ZipOutputStream out = new ZipOutputStream(new FileOutputStream(zipFileName));

            // 파일 압축
            for (int i = 0; i < files.length; i++) {
                FileInputStream in = new FileInputStream(files[i]);

                String entryName = StringUtils.replace(files[i], File.separator, "/");
                entryName = StringUtils.substringAfterLast(entryName, "/");
                // 압축 항목추가
                out.putNextEntry(new ZipEntry(entryName));

                // 바이트 전송
                int len;
                while ((len = in.read(buf)) > 0) {
                    out.write(buf, 0, len);
                }

                out.closeEntry();
                in.close();
            }

            // 압축파일 작성
            out.close();
        } catch (Exception e) {
            throw e;
        }
    }

    /**
     * 파일압축
     *
     * @param fileName
     * @param zipFileName
     * @throws Exception
     */
    public static void zipEntry(String fileName, String zipFileName) throws Exception {
        zipEntry(new String[] { fileName }, zipFileName);
    }

    /**
     * Zip 파일의 압축을 푼다.
     *
     * @param zipFile
     *            - 압축 풀 Zip 파일
     * @param targetDir
     *            - 압축 푼 파일이 들어간 디렉토리
     * @param fileNameToLowerCase
     *            - 파일명을 소문자로 바꿀지 여부
     * @throws Exception
     */
    public static void unzip(File zipFile, File targetDir, boolean fileNameToLowerCase) throws Exception {
        FileInputStream fis = null;
        ZipInputStream zis = null;
        ZipEntry zentry = null;

        try {
            fis = new FileInputStream(zipFile); // FileInputStream
            zis = new ZipInputStream(fis); // ZipInputStream

            while ((zentry = zis.getNextEntry()) != null) {
                String fileNameToUnzip = zentry.getName();
                fileNameToUnzip = StringUtils.replace(fileNameToUnzip, "\\", "/");
                if (fileNameToLowerCase) { // fileName toLowerCase
                    fileNameToUnzip = fileNameToUnzip.toLowerCase();
                }

                File targetFile = new File(targetDir, fileNameToUnzip);

                if (zentry.isDirectory()) {// Directory 인 경우
                    FileUtil.createDirIfNotExists(targetFile.getAbsolutePath()); // 디렉토리생성
                } else { // File 인 경우
                    // parent Directory 생성
                    FileUtil.createDirIfNotExists(targetFile.getParent());
                    unzipEntry(zis, targetFile);
                }
            }
        } finally {
            if (zis != null) {
                zis.close();
            }
            if (fis != null) {
                fis.close();
            }
        }
    }

    /**
     * Zip 파일의 한 개 엔트리의 압축을 푼다.
     *
     * @param zis
     *            - Zip Input Stream
     * @param targetFile
     *            - 압축 풀린 파일의 경로
     * @return
     * @throws Exception
     */
    private static File unzipEntry(ZipInputStream zis, File targetFile) throws Exception {
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(targetFile);

            byte[] buffer = new byte[BUFFER_SIZE];
            int len = 0;
            while ((len = zis.read(buffer)) != -1) {
                fos.write(buffer, 0, len);
            }
        } finally {
            if (fos != null) {
                fos.close();
            }
        }
        return targetFile;
    }
} //:)--
