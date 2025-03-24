package mobile.tool;

import java.io.File;
import java.io.IOException;

/**
 * @author JeongY.Eom
 * @date 2007. 09. 19
 * @time 오후 2:29:25
 */

public class FileOperator {
    /**
     * file 이름에 확장자가 있다면 확장자를 return하고 없으면, 그냥
     * 공백 String을 반환하는 메소드.
     *
     * @param filename
     * @return
     */
    public static String getFilenameExt(String filename) {
        String extention = "";

        int i = filename.lastIndexOf(".");
        if (i > 0) {    // file has extention
            extention = filename.substring(i);
        }
        return extention;
    }

    /**
     * 파일디렉토리 체크후 없으면 생성
     *
     * @param dirName
     */
    public static String createDirIfNotExist(String dirName) {
        String[] dir = dirName.split("/");

        dirName = "";
        for (int i = 0, n = dir.length - 1; i < n; i++) {
            dirName += ("/" + dir[i]);
        }

        File localPath = new File(dirName);
        if (!localPath.exists()) {
            localPath.mkdirs();
        }
        return dirName;
    }

    public static boolean createNewFileName(String fullFilename) {
        try {
            return (new File(fullFilename)).createNewFile();
        } catch (IOException ignored) {
            return false;
        }
    }

    /**
     * 중복되는 파일명이 없이 파일명 가져오기
     *
     * @param fullFilename
     * @return
     */
    public static String getRename(String fullFilename) {
        int dirIdx = fullFilename.lastIndexOf("/");
        String dir = fullFilename.substring(0, dirIdx);
        String fileName = fullFilename.substring(dirIdx + 1);
        String body = null;
        String ext = null;

        int dotIdx = fileName.lastIndexOf(".");
        if (dotIdx != -1) {
            body = fileName.substring(0, dotIdx);
            ext = fileName.substring(dotIdx);  // includes "."
        } else {
            body = fileName;
            ext = "";
        }

        int i = 0;
        String newName;
        do {
            newName = dir + "/" + getFileName(body, i++) + ext;
        } while (!createNewFileName(newName));

        String retName = newName.substring(dirIdx + 1);
        return retName.startsWith("/") ? retName.substring(1) : retName;
    }

    private static String getFileName(String fileNameBody, int idx) {
        if (idx == 0) {
            return fileNameBody;
        } else {
            return fileNameBody + idx;
        }
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
}
//:)--