package mobile.factory.util.net;

import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.entity.mime.FileBody;
import org.apache.hc.client5.http.entity.mime.MultipartEntityBuilder;
import org.apache.hc.client5.http.entity.mime.StringBody;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;

import org.apache.hc.core5.http.ContentType;
import org.apache.hc.core5.http.HttpEntity;
import org.springframework.http.HttpHeaders;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;


public class HttpConnector {
    private static final String DEFAULT_ENCODING = "UTF-8";

    private String url;
    private MultipartEntityBuilder params;
    private Map<String, Object> paramMap = new HashMap<>();

    /**
     * @param url 접속할 url
     */
    public HttpConnector(String url){
        this.url = url;
        params = MultipartEntityBuilder.create();
    }

    /**
     * Map 으로 한꺼번에 파라메터 훅 추가하는 메소드
     * @param param 파라메터들이 담긴 맵, 파라메터들은 UTF-8로 인코딩 됨
     * @return
     */
    public HttpConnector addParam(Map<String, Object> param){
        return addParam(param, DEFAULT_ENCODING);
    }

    /**
     * Map 으로 한꺼번에 파라메터 훅 추가하는 메소드
     * @param param 파라메터들이 담긴 맵
     * @param encoding 파라메터 encoding charset
     * @return
     */
    public HttpConnector addParam(Map<String, Object> param, String encoding) {
        for (Map.Entry<String, Object> e : param.entrySet()) {
            if (e.getValue() instanceof File) {
                addParam(e.getKey(), (File) e.getValue(), encoding);
            } else {
                addParam(e.getKey(), (String) e.getValue(), encoding);
            }
        }
        return this;
    }

    /**
     * 문자열 파라메터를 추가한다.
     * @param name 추가할 파라메터 이름
     * @param value 파라메터 값
     * @return
     */
    public HttpConnector addParam(String name, String value){
        return addParam(name, value, DEFAULT_ENCODING);
    }

    public HttpConnector addParam(String name, String value, String encoding){
        params.addPart(name, new StringBody(value, ContentType.create("text/plain", encoding)));

        paramMap.put(name, value);
        return this;
    }

    /**
     * 업로드할 파일 파라메터를 추가한다.
     * @param name
     * @param file
     * @return
     */
    public HttpConnector addParam(String name, File file){
        return addParam(name, file, DEFAULT_ENCODING);
    }

    public HttpConnector addParam(String name, File file, String encoding){
        if (file.exists()) {
            try {
                params.addPart(
                        name,
                        new FileBody(file, ContentType.create("application/octet-stream"),
                                URLEncoder.encode(file.getName(), encoding)));

                paramMap.put(name, file);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }

        return this;
    }

    /**
     * 타겟 URL 로 POST 요청을 보낸다.
     * @return 요청결과
     * @throws Exception
     */
    public String submit() throws Exception{
        return submit(null);
    }

    /**
     * 타겟 URL 로 POST 요청을 보낸다.
     *
     * @param header
     * @return 요청결과
     * @throws Exception
     */
    public String submit(HttpHeaders header) throws Exception {
        CloseableHttpClient http = HttpClients.createDefault();
        StringBuffer result = new StringBuffer();

        try {
            HttpPost post = new HttpPost(url);
            post.setEntity(params.build());

            if (header != null) {
                for(String item : header.keySet()) {
                    post.setHeader(item, header.get(item).get(0));
                }
            }

            CloseableHttpResponse response = http.execute(post);

            try {
                HttpEntity res = response.getEntity();
                BufferedReader br = new BufferedReader(
                        new InputStreamReader(res.getContent(), Charset.forName("UTF-8")));

                String buffer = null;
                while ((buffer = br.readLine()) != null) {
                    result.append(buffer).append("\r\n");
                }
            } finally {
                response.close();
            }
        } finally {
            http.close();
        }

        return result.toString();
    }

    public String printParams() {
        return paramMap.toString();
    }
}
