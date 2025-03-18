package com.yk.ykstpirngbootversionup.util;

import org.springframework.http.MediaType;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.file.Files;

public class FileToMultipartFile {
    public static MultipartFile convertFileToMultipartFile(File file, String fileName) {
        return new MultipartFile() {
            @Override
            public String getName() {
                return fileName;
            }

            @Override
            public String getOriginalFilename() {
                return file.getName();
            }

            @Override
            public String getContentType() {
                try {
                    return Files.probeContentType(file.toPath());
                } catch (IOException e) {
                    return MediaType.APPLICATION_OCTET_STREAM_VALUE;
                }
            }

            @Override
            public boolean isEmpty() {
                return file.length() == 0;
            }

            @Override
            public long getSize() {
                return file.length();
            }

            @Override
            public byte[] getBytes() throws IOException {
                return Files.readAllBytes(file.toPath());
            }

            @Override
            public InputStream getInputStream() throws FileNotFoundException {
                return new FileInputStream(file);
            }

            @Override
            public void transferTo(File dest) throws IOException {
                Files.copy(file.toPath(), dest.toPath());
            }
        };
    }
}
