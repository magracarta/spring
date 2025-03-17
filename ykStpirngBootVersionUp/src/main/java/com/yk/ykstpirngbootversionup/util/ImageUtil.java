package com.yk.ykstpirngbootversionup.util;

import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.Directory;
import com.drew.metadata.Metadata;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.jpeg.JpegDirectory;
import com.yk.ykstpirngbootversionup.util.FileUtil;
import org.apache.commons.lang3.StringUtils;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject;
import org.imgscalr.Scalr;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

/**
 * <pre>
 *  이미지 변환 유틸
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2022. 9. 30.
 * @time 오전 10:20:40
 **/
public class ImageUtil {
    private final static Logger logger = LoggerFactory.getLogger(ImageUtil.class);

    /**
     * <pre>
     * 		이미지 리사이즈
     * 		가로 / 세로 사이즈가 변경하려고 하는 사이즈 보다 클때만 작동함.
     * </pre>
     * @author 엄정영
     * @param originalImage
     * @param reSize
     * @param type
     * @param highQuality
     * @return
     */
    public static BufferedImage resizedImage(BufferedImage originalImage, int reSize, int type, boolean highQuality) {
        return resizedImage(originalImage, reSize, reSize, type, highQuality);
    }

    /**
     * <pre>
     * 		이미지 리사이즈
     * 		가로 / 세로 사이즈가 변경하려고 하는 사이즈 보다 클때만 작동함.
     * </pre>
     * @author 엄정영
     * @param originalImage
     * @param reWidth
     * @param reHeight
     * @param type
     * @param highQuality
     * @return
     */
    public static BufferedImage resizedImage(BufferedImage originalImage, int reWidth, int reHeight, int type, boolean highQuality) {
        double imageWidth = originalImage.getWidth();
        double imageHeight = originalImage.getHeight();
        int resizeWidth = 0;
        int resizeHeight = 0;
        int drawWidth, drawHeight;

        BufferedImage resizeImageJpg = originalImage;

        // 이미지 변환할 필요가 있는지 체크
        // 가로, 세로 사이즈가 변환 사이즈 하나라도 커야 변환 작업진행
        // 2022-10-07 : 동일한 크기일경우 원본파일을 반환하는 부분에서 RGB (파일색상)이 바뀌는 이슈로
        //              해당 체크는 FileUtil.uploadFormFile() 에서 진행함.
//        if (imageWidth <= reSize && imageHeight <= reSize) {
//            return resizeImageJpg;
//        }

        // 기존 img_resize로 이미지 리사이징
        if (reWidth == reHeight) {
            double baseReSize = reWidth;
            int reSize = reWidth;

            if (imageWidth == imageHeight) {
                // 정사각형 이미지
                resizeWidth = reSize;
                resizeHeight = reSize;

                if (reSize > (int) imageWidth) {
                    resizeWidth = (int) imageWidth;
                    resizeHeight = (int) imageHeight;
                }

            } else if (imageWidth > imageHeight) {
                // 가로이미지
                resizeWidth = reSize;
                resizeHeight = (int) Math.round((imageHeight / 100) * (baseReSize / (imageWidth / 100)));

                if (reSize > (int) imageWidth) {
                    resizeWidth = (int) imageWidth;
                    resizeHeight = (int) imageHeight;
                }

            } else if (imageWidth < imageHeight) {
                // 세로이미지
                resizeWidth = (int) Math.round((imageWidth / 100) * (baseReSize / (imageHeight / 100)));
                resizeHeight = reSize;

                if (reSize > (int) imageHeight) {
                    resizeWidth = (int) imageWidth;
                    resizeHeight = (int) imageHeight;
                }
            }
        }

        // max_width, max_height로 이미지 리사이징 (2023-08-18 추가 jsk)
        else {
            double baseReWidth = 0;
            double baseReHeight = 0;

            if (reWidth <= 0) {
                reWidth = (int) imageWidth;
            }
            if (reHeight <= 0) {
                reHeight = (int) imageHeight;
            }

            if (imageWidth/reWidth > imageHeight/reHeight) {
                if (reWidth < (int) imageWidth) {
                    baseReWidth = reWidth;
                    baseReHeight = (imageHeight / 100) * (reWidth / (imageWidth / 100));
                }
            } else {
                baseReWidth = (int) imageWidth;
                baseReHeight = imageHeight;
            }

            if (reHeight < baseReHeight) {
                baseReWidth = (baseReWidth / 100) * (reHeight / (baseReHeight / 100));
                baseReHeight = reHeight;
            }

            resizeWidth = (int) baseReWidth;
            resizeHeight = (int) baseReHeight;
        }

        if (highQuality) {
            drawWidth = (int) imageWidth;
            drawHeight = (int) imageHeight;
        } else {
            drawWidth = resizeWidth;
            drawHeight = resizeHeight;
        }

        do {
            if (highQuality) {
                if (drawWidth > resizeWidth) {
                    drawWidth /= 2;
                    if (drawWidth < resizeWidth) {
                        drawWidth = resizeWidth;
                    }
                }

                if (drawHeight > resizeHeight) {
                    drawHeight /= 2;
                    if (drawHeight < resizeHeight) {
                        drawHeight = resizeHeight;
                    }
                }
            }

            BufferedImage drawImage = new BufferedImage(drawWidth, drawHeight, type);
            Graphics2D g = drawImage.createGraphics();
            g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            //g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            //g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            g.drawImage(resizeImageJpg, 0, 0, drawWidth, drawHeight, null);
            g.dispose();

            resizeImageJpg = drawImage;

        } while (drawWidth != resizeWidth || drawHeight != resizeHeight);

        return resizeImageJpg;
    }

    /**
     * 이미지 파일인지 체크
     * @author 엄정영
     * @param file
     * @return
     */
    public static boolean isImageFile(File file) {
        try {
            BufferedImage bufferedImage = ImageIO.read(file);
            return bufferedImage != null;
        } catch (Exception ignore) {
            logger.warn("Not an Image file > {}", file.getName(), ignore);
        }

        return false;
    }

    /**
     * 이미지 파일 체크
     * @param path
     * @return
     */
    public static boolean isImageFile(String path) {
        File file = new File(path);

        if(file.exists() == false) {
            return false;
        }

        return isImageFile(file);
    }

    /**
     * <pre>
     * 		이미지 리사이즈
     * 		가로 / 세로 사이즈가 변경하려고 하는 사이즈 보다 클때만 작동함.
     * </pre>
     * @author 엄정영
     * @param originalImage
     * @param reSize
     * @return
     */
    public static BufferedImage resizedImage(BufferedImage originalImage, int reSize) {
        return resizedImage(originalImage, reSize, reSize);
    }

    /**
     * <pre>
     * 		이미지 리사이즈
     * 		가로 / 세로 사이즈가 변경하려고 하는 사이즈 보다 클때만 작동함.
     * </pre>
     * @author 엄정영
     * @param originalImage
     * @param reWidth
     * @param reHeight
     * @return
     */
    public static BufferedImage resizedImage(BufferedImage originalImage, int reWidth, int reHeight) {
        return resizedImage(originalImage, reWidth, reHeight, BufferedImage.TYPE_INT_RGB, true);
    }

    /**
     * <pre>
     * 		이미지 리사이즈
     * 		가로 / 세로 사이즈가 변경하려고 하는 사이즈 보다 클때만 작동함.
     * </pre>
     * @author 엄정영
     * @param originalImageFile
     * @param reSize
     * @param resizeImageFile
     * @throws IOException
     */
    public static void resizedImage(File originalImageFile, int reSize, File resizeImageFile) throws IOException {
        resizedImage(originalImageFile, reSize, reSize, resizeImageFile);
    }

    /**
     * <pre>
     * 		이미지 리사이즈
     * 		가로 / 세로 사이즈가 변경하려고 하는 사이즈 보다 클때만 작동함.
     * </pre>
     * @author 엄정영
     * @param originalImageFile
     * @param reWidth
     * @param reHeight
     * @param resizeImageFile
     * @throws IOException
     */
    public static void resizedImage(File originalImageFile, int reWidth, int reHeight, File resizeImageFile) throws IOException {
        BufferedImage originalImage = ImageIO.read(originalImageFile);

        BufferedImage resizeImage = resizedImage(originalImage, reWidth, reHeight);

        // 이미지 회전 정보가 있으면 회전
        int angle = rotationAngle(originalImageFile);
        if(angle > 0) {
            resizeImage = rotation(resizeImage, angle);
        }

        ImageIO.write(resizeImage, "jpg", resizeImageFile);
    }

    /**
     * 이미지 회전 각도 구하기
     * @param imageFile
     * @return
     */
    private static int rotationAngle(File imageFile) {
        int angle = 0;
        int orientation = 1; // 회전정보, 1. 0도, 3. 180도, 6. 270도, 8. 90도 회전한 정보
        try {
            Metadata metadata = ImageMetadataReader.readMetadata(imageFile);
            Directory directory = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
            JpegDirectory jpegDirectory = metadata.getFirstDirectoryOfType(JpegDirectory.class);
            if (directory != null) {
                orientation = directory.getInt(ExifIFD0Directory.TAG_ORIENTATION);
            }
        } catch (Exception ignore) {
            logger.warn(ignore.getMessage());
        }

        switch (orientation) {
            case 1:
                angle = 0;
                break;
            case 3:
                angle = 180;
                break;
            case 6:
                angle = 90;
                break;
            case 8:
                angle = 270;
                break;

        }
        return angle;
    }

    /**
     * <pre>
     * 		이미지 리사이즈
     * 		가로 / 세로 사이즈가 변경하려고 하는 사이즈 보다 클때만 작동함.
     * </pre>
     * @author 엄정영
     * @param originalImageFile
     * @param reSize
     * @param fileFullName 새로 변경할 파일명(디렉토리를 포함한 full 파일확장자까지 기술)
     * @return
     * @throws IOException
     */
    public static File resizedImage(File originalImageFile, int reSize, String fileFullName) throws IOException {
        return resizedImage(originalImageFile, reSize, fileFullName, false);
    }

    /**
     * <pre>
     * 		이미지 리사이즈
     * 		가로 / 세로 사이즈가 변경하려고 하는 사이즈 보다 클때만 작동함.
     * </pre>
     * @author 엄정영
     * @param originalImageFile
     * @param reSize
     * @param fileFullName
     * @param sizeAppend 파일명에 사이즈 붙일지 여부, xxx.jpg -> xxx_200.jpg
     * @return
     * @throws IOException
     */
    public static File resizedImage(File originalImageFile, int reSize, String fileFullName, boolean sizeAppend) throws IOException {
        return resizedImage(originalImageFile, reSize, reSize, fileFullName, sizeAppend);
    }

    /**
     * <pre>
     * 		이미지 리사이즈
     * 		가로 / 세로 사이즈가 변경하려고 하는 사이즈 보다 클때만 작동함.
     * </pre>
     * @author 엄정영
     * @param originalImageFile
     * @param reWidth
     * @param reHeight
     * @param fileFullName
     * @param sizeAppend 파일명에 사이즈 붙일지 여부, xxx.jpg -> xxx_200x300.jpg
     * @return
     * @throws IOException
     */
    public static File resizedImage(File originalImageFile, int reWidth, int reHeight, String fileFullName, boolean sizeAppend) throws IOException {
        String newFileFullName = FileUtil.replaceSeparator(fileFullName);
        String saveFileName = newFileFullName;
        if (sizeAppend) {
            String prefixName = StringUtils.substringBeforeLast(newFileFullName, "/");
            String filePathName = StringUtils.substringAfterLast(newFileFullName, "/");

            String fileName = StringUtils.substringBeforeLast(filePathName, ".");
            String fileTempExt = StringUtils.substringAfterLast(filePathName, ".");
            String fileExt = "".equals(fileTempExt) ? "" : String.format(".%s", fileTempExt);

            if (reWidth == reHeight) {
                saveFileName = String.format("%s/%s_%d%s", prefixName, fileName, reWidth, fileExt);
            } else {
                saveFileName = String.format("%s/%s_%dx%d%s", prefixName, fileName, reWidth, reHeight, fileExt);
            }
        }

        FileUtil.createDirIfNotExists(saveFileName);

        File resizeImageFile = new File(saveFileName);
        resizedImage(originalImageFile, reWidth, reHeight, resizeImageFile);

        return resizeImageFile;
    }

    /**
     * <pre>
     * 		이미지 리사이즈
     * 		가로 / 세로 사이즈가 변경하려고 하는 사이즈 보다 클때만 작동함.(변환정보 파일명에 추가함)
     * </pre>
     * @author 엄정영
     * @param originalImageFile
     * @param reSize
     * @return 변환된 파일
     * @throws IOException
     */
    public static File resizedImage(File originalImageFile, int reSize) throws IOException {
        return resizedImage(originalImageFile, reSize, originalImageFile.getAbsolutePath(), true);
    }

    /**
     * <pre>
     * 		이미지 리사이즈
     * 		가로 / 세로 사이즈가 변경하려고 하는 사이즈 보다 클때만 작동함.
     * </pre>
     * @author 엄정영
     * @param originalImageFile
     * @param reSize
     * @param sizeAppend 사이즈정보 파일명에 추가여부
     * @return 변환된 파일
     * @throws IOException
     */
    public static File resizedImage(File originalImageFile, int reSize, boolean sizeAppend) throws IOException {
        return resizedImage(originalImageFile, reSize, originalImageFile.getAbsolutePath(), sizeAppend);
    }

    /**
     * 이미지 사이즈 구함
     * @author 엄정영
     * @param file
     * @param type W:가로, H:세로
     * @return 이미지 사이즈
     */
    private static int widthOrHeight(File file, String type) {
        try {
            BufferedImage bufferedImage = ImageIO.read(file);
            return widthOrHeight(bufferedImage, type);
        } catch (Exception ignore) {
            logger.warn("Not an Image file > {}", file.getName(), ignore);
            return 0;
        }
    }

    /**
     * 이미지 사이즈 구함
     * @author 엄정영
     * @param imageFile
     * @param type W:가로, H:세로
     * @return 이미지 사이즈
     */
    private static int widthOrHeight(BufferedImage imageFile, String type) {
        if(imageFile == null) {
            return 0;
        }

        if ("W".equals(type)) {
            return imageFile.getWidth();
        } else if ("H".equals(type)) {
            return imageFile.getHeight();
        } else {
            return 0;
        }
    }

    /**
     * 이미지 가로 사이즈 구함
     * @author 엄정영
     * @param file
     * @return
     */
    public static int width(File file) {
        return widthOrHeight(file, "W");
    }

    /**
     * 이미지 세로 사이즈 구함
     * @author 엄정영
     * @param file
     * @return
     */
    public static int height(File file) {
        return widthOrHeight(file, "H");
    }

    /**
     * 이미지 가로 사이즈 구함
     * @author 엄정영
     * @param file
     * @return
     */
    public static int width(BufferedImage file) {
        return widthOrHeight(file, "W");
    }

    /**
     * 이미지 세로 사이즈 구함
     * @author 엄정영
     * @param file
     * @return
     */
    public static int height(BufferedImage file) {
        return widthOrHeight(file, "H");
    }

    /**
     * 이미지 회전
     *
     * @param imagePath
     * @param angle 회전각도, 90이면 가로세로 변경
     */
    public static void rotation(String imagePath, int angle) throws IOException {
        rotation(new File(imagePath), angle);
    }

    /**
     * 이미지 회전
     * @param file
     * @param angle
     * @throws IOException
     */
    public static void rotation(File file, int angle) throws IOException {
        BufferedImage bufferedImage = ImageIO.read(file);
        BufferedImage rotateImg = rotation(bufferedImage, angle);

        ImageIO.write(rotateImg, "jpg", file);
    }

    /**
     * 이미지회전
     * @param imageToRotate
     * @param angle 90, 180, 270 만 변환
     * @return
     */
    private static BufferedImage rotation(BufferedImage imageToRotate, int angle) {
        BufferedImage newImage = imageToRotate;
        switch (angle) {
            case 90 : newImage = Scalr.rotate(newImage, Scalr.Rotation.CW_90, null); break;
            case 180 : newImage = Scalr.rotate(newImage, Scalr.Rotation.CW_180, null); break;
            case 270 : newImage = Scalr.rotate(newImage, Scalr.Rotation.CW_270, null); break;
        }

        return newImage;
    }

    /**
     * 이미지 병합하여 PDF 문서 만들기(기본 A4사이즈)
     *
     * @param imageFiles   이미지 풀경로
     * @param saveFullPath 저장될 경로(파일이름포함. 확장자 pdf)
     */
    public static void makePdfImage(String[] imageFiles, String saveFullPath) throws IOException {
        makePdfImage(imageFiles, saveFullPath, PDRectangle.A4);
    }

    /**
     * 이미지 병합하여 PDF 문서 만들기
     *
     * @param imageFiles   이미지 풀경로
     * @param saveFullPath 저장될 경로(파일이름포함. 확장자 pdf)
     * @param rectangle    PDF 사이즈
     * @throws IOException
     */
    public static void makePdfImage(String[] imageFiles, String saveFullPath, PDRectangle rectangle) throws IOException {
        // 새로운 PDF 문서생성
        PDDocument doc = new PDDocument();

        for (String image : imageFiles) {
            // PDF 페이지 생성
            PDPage page = new PDPage(rectangle);
            doc.addPage(page);

            // 이미지 파일로부터 PDImageXObject 생성
            PDImageXObject pdImage = PDImageXObject.createFromFile(image, doc);
            PDPageContentStream contentStream = new PDPageContentStream(doc, page);

            float imgWidth = pdImage.getWidth();
            float imgHeight = pdImage.getHeight();

            float pdfWidth = page.getMediaBox().getWidth();
            float pdfHeight = page.getMediaBox().getHeight();

            // 이미지가 페이지 크기보다 큰 경우 크기 조절
            if (imgWidth >= pdfWidth || imgHeight >= pdfHeight) {
                float widthGap = imgWidth - pdfWidth;
                float heightGap = imgHeight - pdfHeight;
                if (widthGap >= heightGap) {
                    float ratioW = pdfWidth / imgWidth;
                    imgWidth = pdfWidth;
                    imgHeight *= ratioW;
                } else {
                    float ratioH = pdfHeight / imgHeight;
                    imgHeight = pdfHeight;
                    imgWidth *= ratioH;
                }
            }

            // 이미지를 페이지 중앙에 배치
            float x = (pdfWidth - imgWidth) / 2;
            float y = (pdfHeight - imgHeight) / 2;

            contentStream.drawImage(pdImage, x, y, imgWidth, imgHeight);    // 이미지를 페이지에 추가
            contentStream.close();
        }

        saveFullPath = StringUtils.endsWithIgnoreCase(saveFullPath, ".pdf") == false ? String.format("%s.pdf", saveFullPath) : saveFullPath;
        FileUtil.createDirIfNotExists(saveFullPath);

        doc.save(saveFullPath);
        doc.close();
    }
} //:)--
