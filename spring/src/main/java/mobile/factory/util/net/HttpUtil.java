package mobile.factory.util.net;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import mobile.factory.util.CollectionUtil;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hc.client5.http.classic.HttpClient;
import org.apache.hc.client5.http.config.ConnectionConfig;
import org.apache.hc.client5.http.config.RequestConfig;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.HttpClientBuilder;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.client5.http.impl.io.PoolingHttpClientConnectionManager;
import org.apache.hc.client5.http.impl.io.PoolingHttpClientConnectionManagerBuilder;
import org.apache.hc.client5.http.ssl.NoopHostnameVerifier;
import org.apache.hc.client5.http.ssl.SSLConnectionSocketFactory;

import org.apache.hc.core5.ssl.SSLContexts;
import org.apache.hc.core5.ssl.TrustStrategy;
import org.apache.hc.core5.util.Timeout;
import org.json.JSONObject;
import org.json.XML;
import org.springframework.http.*;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import javax.net.ssl.*;
import java.io.*;
import java.net.*;
import java.nio.charset.Charset;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import java.util.*;
import java.util.concurrent.TimeUnit;

/**
 * <pre>
 * 이 클래스는
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2013. 10. 25.
 * @time 오후 5:34:49
 **/
public class HttpUtil {
	private static final Log logger = LogFactory.getLog(HttpUtil.class);

	/**
	 * body json 타입 {"aa"="22", "bb"="33"}
	 */
	public static final String BODY_TYPE_JSON = "JSON";
	/**
	 * body query 타입 aa=22&bb=33
	 */
	public static final String BODY_TYPE_Query = "Query";

	/**
	 * body query 타입 Xml
	 */
	public static final String BODY_TYPE_XML = "XML";

	/**
	 * @brief 최신 설치 파일 다운로드(오휘 셋업)
	 *
	 * @param strSaveFileName
	 *            저장 경로
	 * @param nTimeoutMs
	 *            타임아웃 설정 0.5초
	 * @return 정상 다운로드 true, 실패 false
	 * @author
	 * @date 2011. 3. 22.
	 * @warning URL : "UPDATE_URL" + GaluxyConsult.zip <br>
	 *          SaveFileName : GetModuleDir(0) + "/apkTemp/" + GaluxyConsult.zip
	 */
	public static boolean getHttpFile(String urlStr, String strSaveFileName, int nTimeoutMs) {

		int nTotalCnt = 0;
		try {
			URL url = new URL(urlStr);
			BufferedInputStream in = new BufferedInputStream(url.openStream());
			FileOutputStream fos = new FileOutputStream(strSaveFileName);
			BufferedOutputStream bout = new BufferedOutputStream(fos, 1024);
			byte data[] = new byte[1024];
			int nCount = 0;
			while ((nCount = in.read(data, 0, 1024)) != -1) {
				bout.write(data, 0, nCount);
				nTotalCnt += nCount;
			}

			bout.close();
			// out.close();
			in.close();

			if (nTotalCnt < 512) {
				return false;
			}
		} catch (Exception ex) {
			System.out.println("HTTP ==> " + ex.getMessage());
			return false;
		}

		return true;
	}

	/**
	 * 한글파일명만 인코딩
	 *
	 * @param containKorFile=인코딩될대상.xls
	 * @return
	 */
	public static String encodeKorFileName(String containKorFile) {
		boolean containSlash = StringUtils.contains(containKorFile, "/");

		String prefixDir = containSlash ? StringUtils.substringBeforeLast(containKorFile, "/") : "";

		String fileFullName = containSlash ? StringUtils.substringAfterLast(containKorFile, "/") : containKorFile;

		String fileName = StringUtils.substringBeforeLast(fileFullName, ".");
		String fileExt = StringUtils.substringAfterLast(fileFullName, ".");

		String encodeFileName = HttpUtil.urlEncode(fileName);

		String encodeFileFullName = String.format("%s.%s", encodeFileName, fileExt);

		String retStr = containSlash ? String.format("%s/%s", prefixDir, encodeFileFullName) : encodeFileFullName;

		return retStr;
	}

	/**
	 * 파라미터 값 "utf-8"형식으로 변환
	 *
	 * @param original
	 *            값
	 * @return 변환 된 값
	 * @warning original : 키=original 부분
	 *
	 */
	public static String urlEncode(String original, String encoding) {
		try {
			return URLEncoder.encode(original, encoding).replace("+", "%20").replace("*", "%2A").replace("%7E", "~").replace("%40", "@");
		} catch (UnsupportedEncodingException e) {
			return original;
		}
	}

	public static String urlEncode(String original) {
		return urlEncode(original, "UTF-8");
	}

	public static String urlDecode(String original, String encoding) {
		try {
			return URLDecoder.decode(original, encoding).replace("+", "%20").replace("*", "%2A").replace("%7E", "~").replace("%40", "@");
		} catch (UnsupportedEncodingException e) {
			String strMsg = e.getMessage();
			return null;
		}
	}

	public static String urlDecode(String original) {
		return urlDecode(original, "UTF-8");
	}

	/**
	 * post 방식으로 전달
	 *
	 * @param urlStr
	 * @return
	 */
	public static String getHttpDocument(String urlStr) {
		StringBuilder sbufDoc = new StringBuilder();

		String host = StringUtils.substringBefore(urlStr, "?");
		String param = StringUtils.substringAfter(urlStr, "?");

		HttpURLConnection conn = null;
		URL url = null;
		try {
			url = new URL(host);
			conn = (HttpURLConnection) url.openConnection();
			if (conn != null) {
				conn.setConnectTimeout(5000);
				conn.setUseCaches(false);
				conn.setReadTimeout(100 * 1000);
				conn.setRequestMethod("POST");
				conn.setDoInput(true);
				conn.setDoOutput(true);
				conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

				OutputStream os = conn.getOutputStream();

				os.write(param.getBytes("utf-8"));

				os.flush();
				os.close();

				if (conn.getResponseCode() == HttpURLConnection.HTTP_OK) {
					BufferedReader brx = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));

					for (;;) {
						String sLineStr = brx.readLine();
						if (sLineStr == null) {
							break;
						}
						sLineStr += "\n";
						sbufDoc.append(sLineStr);
					}
					brx.close();
				}
				conn.disconnect();
			}
		} catch (Exception ex) {
			System.out.println("getHttpDocument => " + ex.getMessage());
		} finally {
			if (conn != null) {
				conn.disconnect();
				conn = null;
			}
		}

		return sbufDoc.toString();
	}

	public static Map<String, Object> sendRestGet(String fullUrl) {
		return sendRestGet(fullUrl, null, null);
	}

	public static Map<String, Object> sendRestGet(String fullUrl, Map<String, Object> param) {
		return sendRestGet(fullUrl, null, param);
	}

	public static Map<String, Object> sendRestGet(String fullUrl, HttpHeaders headers) {
		return sendRestGet(fullUrl, headers, null);
	}

	public static Map<String, Object> sendRestGet(String fullUrl, HttpHeaders headers, Map<String, Object> param) {
		return sendRest(fullUrl, HttpMethod.GET, headers, param);
	}

	public static Map<String, Object> sendRestGet(String fullUrl, HttpHeaders headers, Map<String, Object> param, String bodyType) {
		return sendRest(fullUrl, HttpMethod.GET, headers, param, bodyType);
	}

	public static Map<String, Object> sendRestPost(String fullUrl, Map<String, Object> param) {
		return sendRestPost(fullUrl, null, param);
	}

	public static Map<String, Object> sendRestPost(String fullUrl, Map<String, Object> param, String... noEncoding) {
		return sendRestPost(fullUrl, null, param, null, noEncoding);
	}

	public static Map<String, Object> sendRestPost(String fullUrl, HttpHeaders headers, Map<String, Object> param, String bodyType) {
		return sendRest(fullUrl, HttpMethod.POST, headers, param, bodyType);
	}

	public static Map<String, Object> sendRestPost(String fullUrl, HttpHeaders headers, Map<String, Object> param, String bodyType, String... noEncoding) {
		return sendRest(fullUrl, HttpMethod.POST, headers, param, bodyType, noEncoding);
	}

	public static Map<String, Object> sendRestPost(String fullUrl, HttpHeaders headers, Map<String, Object> param) {
		return sendRestPost(fullUrl, headers, param, null);
	}

	public static Map<String, Object> sendRestPut(String fullUrl, HttpHeaders headers, Map<String, Object> param) {
		return sendRest(fullUrl, HttpMethod.PUT, headers, param);
	}

	public static Map<String, Object> sendRestDelete(String fullUrl, HttpHeaders headers, Map<String, Object> param) {
		return sendRest(fullUrl, HttpMethod.DELETE, headers, param);
	}

	public static Map<String, Object>  sendRest(String fullUrl, HttpMethod httpMethod, HttpHeaders headers, Map<String, Object> param, String bodyType) {
		return sendRest(fullUrl, httpMethod, headers, param, bodyType, "");
	}

	/**
	 * http 요청
	 *
	 * @param fullUrl
	 * @param httpMethod
	 * @param headers
	 * @param param
	 * @param bodyType @see HttpUtil.BODY_TYPE_JSON, HttpUtil.BODY_TYPE_Query, HttpUtil.BODY_TYPE_XML
	 * @return httpStatusCode는 반드시 존재
	 */
	public static Map<String, Object>  sendRest(String fullUrl, HttpMethod httpMethod, HttpHeaders headers, Map<String, Object> param, String bodyType, String... noEncoding) {
		bodyType = StringUtils.defaultIfBlank(bodyType, BODY_TYPE_Query);


		ResponseEntity<String> respEntity = sendRestString(fullUrl, httpMethod, headers, param, bodyType, noEncoding);

		Gson gson = new Gson();
		Map<String, Object> resultMap = null;

		// 결과가 리스트로 오는 경우가 있음.
		try {
			if(BODY_TYPE_XML.equals(bodyType)) {
				JSONObject json = XML.toJSONObject(respEntity.getBody());
				resultMap = gson.fromJson(json.toString(), HashMap.class);
			} else {
				resultMap = gson.fromJson(respEntity.getBody(), HashMap.class);
			}
		} catch (Exception e) {
			try {   // 리스트인 경우
				List<Map<String, Object>> list = gson.fromJson(respEntity.getBody(), List.class);

				resultMap = new HashMap<String, Object>() {
					{
						put("result", list);
					}
				};
			} catch (Exception ie) { // String으로 &로 묶어서 Get형식으로 오는 경우도 있음.
				String result = respEntity.getBody();

				// 결과에 %포함시 URLDecoding
				if(StringUtils.contains(result, "%")) {
					result = urlDecode(result);
				}

				String[] resultArray = result.split("&");

				resultMap = new HashMap<>();
				for(String item : resultArray) {
					String key = StringUtils.substringBefore(item, "=");
					String value = StringUtils.substringAfter(item, "=");

					resultMap.put(key, value);
				}
			}
		}

		if(resultMap == null) {
			resultMap = new HashMap<>();
		}

		resultMap.put("_httpStatusCode", respEntity.getStatusCodeValue());
		resultMap.put("_originResult", respEntity.getBody());

		return resultMap;
	}

	/**
	 * http 요청
	 * @param fullUrl
	 * @param httpMethod
	 * @param headers
	 * @param param
	 * @return
	 */
	public static Map<String, Object> sendRest(String fullUrl, HttpMethod httpMethod, HttpHeaders headers, Map<String, Object> param) {
		return sendRest(fullUrl, httpMethod, headers, param, null);
	}

	public static ResponseEntity<String> sendRestString(String fullUrl, HttpMethod httpMethod, HttpHeaders headers, Map<String, Object> param, String bodyType) {
		return sendRestString(fullUrl, httpMethod, headers, param, bodyType, "");
	}

	/**
	 * SSL 통신 시 ReRestTemplate 사용 할 때 인증서 유효성 체크 안하게 하는 로직이다.
	 * @return
	 * @throws KeyStoreException
	 * @throws NoSuchAlgorithmException
	 * @throws KeyManagementException
	 * @see https://mylupin.tistory.com/16
	 */
	private static RestTemplate makeRestTemplate(int timeOutSecond) {

		TrustStrategy acceptingTrustStrategy = (X509Certificate[] chain, String authType) -> true;

		SSLContext sslContext = null;
		try {
			sslContext = SSLContexts.custom()
					.loadTrustMaterial(null,acceptingTrustStrategy)
					.build();
		} catch (Exception e) {
			logger.warn("", e);
		}

		SSLConnectionSocketFactory csf = new SSLConnectionSocketFactory(sslContext, new NoopHostnameVerifier());

		PoolingHttpClientConnectionManager connManager = PoolingHttpClientConnectionManagerBuilder.create()
				.setSSLSocketFactory(csf)
				.setDefaultConnectionConfig(ConnectionConfig.custom()
						.setSocketTimeout(Timeout.ofSeconds(timeOutSecond))
						.setConnectTimeout(Timeout.ofSeconds(timeOutSecond)).build() //연결 타임아웃
				).build();



		CloseableHttpClient httpClient = HttpClients.custom()
				.setConnectionManager(connManager)
				.evictExpiredConnections() // 만료된 연결 정리
				.evictIdleConnections(Timeout.ofMinutes(1)) // 유휴 연결 정리
				.build();

		HttpComponentsClientHttpRequestFactory requestFactory = new HttpComponentsClientHttpRequestFactory(httpClient);


//        requestFactory.setHttpClient(httpClient);
//        requestFactory.setConnectTimeout(timeOutSecond * 1000);
//        requestFactory.setReadTimeout(timeOutSecond * 1000);

		return new RestTemplate(requestFactory);
	}

	/**
	 * http 요청
	 *
	 * @param fullUrl
	 * @param httpMethod
	 * @param headers
	 * @param param
	 * @param bodyType JSON(body를 JSON타입으로 전송), 생략시 기본(Query)
	 * @param noEncoding 인코딩 안하는 필드
	 * @return
	 */
	public static ResponseEntity<String> sendRestString(String fullUrl, HttpMethod httpMethod, HttpHeaders headers, Map<String, Object> param, String bodyType, String... noEncoding) {
//      RestTemplate restTemplate = new RestTemplate(new HttpComponentsClientHttpRequestFactory());

		int timeOutSecond = 3;
		// 2024-10-24 황빛찬 모두싸인 요청일경우 time-out 10초로 늘림 (모두싸인측에서 안내받음)
		if (fullUrl.contains("https://api.modusign.co.kr/documents")) {
			timeOutSecond = 10;
		}

		RestTemplate restTemplate = makeRestTemplate(timeOutSecond);

		restTemplate.getMessageConverters()
				.add(0, new StringHttpMessageConverter(Charset.forName("UTF-8")));

		HttpEntity<?> httpEntity = null;
		MultiValueMap<String, String> mvm = null;

		switch (bodyType) {
			case BODY_TYPE_JSON: // body가 json 타입
				headers = headers == null ? new HttpHeaders() : headers;
				headers.setContentType(MediaType.APPLICATION_JSON);

				JSONObject jsonParam = new JSONObject();
				for (String item : param.keySet()) {
					jsonParam.put(item, param.get(item));
				}

				httpEntity = new HttpEntity<>(jsonParam.toString(), headers);
				break;
			case BODY_TYPE_XML:
				headers = headers == null ? new HttpHeaders() : headers;
				headers.setContentType(MediaType.APPLICATION_XML);

				httpEntity = new HttpEntity<>(headers);
				break;
			default: // 일반타입
				mvm = new LinkedMultiValueMap<>();
				if (param != null) {
					Map<String, String> strMap = CollectionUtil.toStringMap(param);
					for (String item : strMap.keySet()) {

						if(ArrayUtils.contains(noEncoding, item) == false) {
							mvm.add(item, urlEncode(strMap.get(item)));
						} else {
							mvm.add(item, strMap.get(item));
						}
					}
				}

				httpEntity = new HttpEntity<MultiValueMap<String, String>>(mvm, headers);
				break;
		}

		if (logger.isDebugEnabled()) {
			logger.debug(String.format("requestUrl => %s, method => %s, header => %s, param => %s, encodingParam => %s", fullUrl, httpMethod, headers, param, mvm));
		}

		ResponseEntity<String> result = restTemplate.exchange(fullUrl, httpMethod, httpEntity, String.class);
		return result;
	}

	/**
	 * http 요청
	 * @param fullUrl
	 * @param httpMethod
	 * @param headers
	 * @param param
	 * @return
	 */
	public static ResponseEntity<String> sendRestString(String fullUrl, HttpMethod httpMethod, HttpHeaders headers, Map<String, Object> param) {
		return sendRestString(fullUrl, httpMethod, headers, param, BODY_TYPE_Query);
	}

	/**
	 *
	 * @param fullUrl
	 *            : 요청URL
	 * @param httpMethod
	 *            : method
	 * @param headers
	 *            : header
	 * @param param
	 *            : file_full_path = 파일 경로 , unique_key = 파일 uuid , file_name =
	 *            실파일명(확장자포함)
	 * @return
	 * @throws MalformedURLException
	 */
	public static Map<String, Object> sendRestWithFile(String fullUrl, HttpMethod httpMethod, HttpHeaders headers, Map<String, String> param) throws MalformedURLException {
		Map<String, Object> resultMap = new HashMap<>();

		File fFile = new File(param.get("file_full_path"));
		if (fFile.exists()) {
			try {
				HttpConnector httpCon = new HttpConnector(fullUrl);

				for (String item : param.keySet()) {
					httpCon.addParam(item, param.get(item));
				}

				httpCon.addParam("attach_file", fFile);

				if (logger.isDebugEnabled()) {
					logger.debug(String.format("requestUrl => %s, method => %s, param => %s", fullUrl, httpMethod, param));
				}
				// System.out.println(String.format("requestUrl => %s, method =>
				// %s, param => %s", fullUrl, httpMethod, param));

				String strRet = httpCon.submit();

				Gson gson = new Gson();
				resultMap = gson.fromJson(strRet, HashMap.class);

			} catch (Exception e) {
				logger.error("", e);
				resultMap.put("result", "false");
				resultMap.put("msg", "파일 변환에 실패하였습니다.");
			}
		} else {
			resultMap.put("result", "false");
			resultMap.put("msg", "첨부파일이 존재하지 않습니다.");
		}

		return resultMap;
	}

	public static Map<String, Object> sendRestPostFile(String fullUrl, Map<String, String> param, File[] files) throws Exception {
		String[] fileNames = new String[files.length];
		for (int i = 0, n = files.length; i < n; i++) {
			fileNames[i] = String.format("file_%s", i);
		}

		return sendRestPostFile(fullUrl, param, files, fileNames);
	}

	public static Map<String, Object> sendRestPostFile(String fullUrl, Map<String, String> param, File[] files, String[] fileNames) throws Exception {
		return sendRestPostFile(fullUrl, param, files, fileNames, null);
	}

	/**
	 *
	 * @param fullUrl
	 * @param param
	 * @param files
	 * @return
	 * @throws Exception
	 */
	public static Map<String, Object> sendRestPostFile(String fullUrl, Map<String, String> param, File[] files, String[] fileIdNames, HttpHeaders header) throws Exception {
		Map<String, Object> resultMap = new HashMap<>();

		HttpConnector httpCon = new HttpConnector(fullUrl);
		if (param != null) {
			for (String item : param.keySet()) {
				httpCon.addParam(item, param.get(item));
			}
		}

		if(ArrayUtils.isNotEmpty(files)) {
			for(int i=0,n= files.length; i<n; i++) {
				httpCon.addParam(fileIdNames[i], files[i]);
			}
		}

		if (logger.isDebugEnabled()) {
			logger.debug(String.format("requestUrl => %s, param => %s, %s", fullUrl, param, httpCon.printParams()));
		}

		String strRet = httpCon.submit(header);

		Gson gson = new Gson();
		resultMap = gson.fromJson(strRet, HashMap.class);

		return resultMap;
	}

	public static Map<String, Object> sendNonRestGet(String fileUrl) {
		return sendNonRest(fileUrl, null, "GET", false, null);
	}

	public static Map<String, Object> sendNonRestGet(String fileUrl, Map<String, Object> param, boolean paramEncode) {
		return sendNonRest(fileUrl, param, "GET", paramEncode, null);
	}

	public static Map<String, Object> sendNonRestPost(String fileUrl, Map<String, Object> param, boolean paramEncode) {
		return sendNonRest(fileUrl, param, "POST", paramEncode, null);
	}

	public static Map<String, Object> sendNonRestGet(String fileUrl, Map<String, Object> param, boolean paramEncode, Map<String, String> headers) {
		return sendNonRest(fileUrl, param, "GET", paramEncode, headers);
	}

	public static Map<String, Object> sendNonRestPost(String fileUrl, Map<String, Object> param, boolean paramEncode, Map<String, String> headers) {
		return sendNonRest(fileUrl, param, "POST", paramEncode, headers);
	}

	public static Map<String, Object> sendNonRestGet(String fileUrl, Map<String, Object> param, Map<String, String> headers) {
		return sendNonRest(fileUrl, param, "GET", true, headers);
	}

	public static Map<String, Object> sendNonRestPost(String fileUrl, Map<String, Object> param, Map<String, String> headers) {
		return sendNonRest(fileUrl, param, "POST", true, headers);
	}

	public static Map<String, Object> sendNonRestGet(String fileUrl, Map<String, Object> param) {
		return sendNonRest(fileUrl, param, "GET", true, null);
	}

	public static Map<String, Object> sendNonRestPost(String fileUrl, Map<String, Object> param) {
		return sendNonRest(fileUrl, param, "POST", true, null);
	}

	public static Map<String, Object> sendNonRest(String fileUrl, Map<String, Object> param, String requestMethod, boolean paramEncode, Map<String, String> headers) {
		return sendNonRest(fileUrl, param, requestMethod, paramEncode, headers, BODY_TYPE_Query);
	}

	/**
	 *
	 * @param fileUrl
	 * @param param
	 * @param requestMethod POST, GET, ...
	 * @param paramEncode param 인코딩 여부
	 * @param headers
	 * @param bodyType
	 * @return
	 */
	public static Map<String, Object> sendNonRest(String fileUrl, Map<String, Object> param, String requestMethod, boolean paramEncode, Map<String, String> headers, String bodyType) {
		bodyType = StringUtils.defaultIfBlank(bodyType, BODY_TYPE_Query);

		Map<String, Object> result = new HashMap<String, Object>();

		URL url = null;
		HttpURLConnection conn = null;
		HttpsURLConnection sConn =null;

		MultiValueMap<String, String> mvm = new LinkedMultiValueMap<>();
		if (param != null) {
			Map<String, String> strMap = CollectionUtil.toStringMap(param);
			for (String item : strMap.keySet()) {
				String val = paramEncode ? urlEncode(strMap.get(item)) : strMap.get(item);
				mvm.add(item, val);
			}
		}

		try {
			UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(fileUrl).queryParams(mvm);

			if(logger.isDebugEnabled()) {
				logger.debug(String.format("url : %s, method : %s, param : %s, header : %s", fileUrl, requestMethod, param, headers));
			}

			url = new URL(builder.toUriString());
			boolean isLineAuth = false;
			if (StringUtils.startsWith(url.toString(), "https://auth.worksmobile.com/ba")) {
				isLineAuth = true;
			}

			/**
			 *신뢰할 수 없거나 잘못 구성된 HTTPS 사이트 처리
			 *https://rateye.tistory.com/845
			 */
			if (isLineAuth) {
				TrustManager[] trustAllCertificates = new TrustManager[]{
						new X509TrustManager() {
							@Override
							public X509Certificate[] getAcceptedIssuers() {
								return null; // Not relevant.
							}

							@Override
							public void checkClientTrusted(X509Certificate[] certs, String authType) {
								// Do nothing. Just allow them all.
							}

							@Override
							public void checkServerTrusted(X509Certificate[] certs, String authType) {
								// Do nothing. Just allow them all.
							}
						}
				};

				HostnameVerifier trustAllHostnames = new HostnameVerifier() {
					@Override
					public boolean verify(String hostname, SSLSession session) {
						return true; // Just allow them all.
					}
				};

				System.setProperty("jsse.enableSNIExtension", "false");
				SSLContext sc = SSLContext.getInstance("SSL");
				sc.init(null, trustAllCertificates, new SecureRandom());
				sConn = (HttpsURLConnection) url.openConnection();
				sConn.setDefaultSSLSocketFactory(sc.getSocketFactory());
				sConn.setDefaultHostnameVerifier(trustAllHostnames);
			} else {
				conn = (HttpURLConnection) url.openConnection();
				conn.setRequestMethod(requestMethod);
			}

			if (headers != null) {
				for (String item : headers.keySet()) {
					if (isLineAuth) {
						sConn.setRequestProperty(item, headers.get(item));
					} else {
						conn.setRequestProperty(item, headers.get(item));

					}
				}
			}

			int responseCode;
			if (isLineAuth) {
				responseCode = sConn.getResponseCode();
			} else {
				responseCode = conn.getResponseCode();
			}

			if (responseCode == HttpURLConnection.HTTP_OK || responseCode == HttpURLConnection.HTTP_CREATED) {
				BufferedReader in;
				if (isLineAuth) {
					in = new BufferedReader(new InputStreamReader(sConn.getInputStream(), "UTF-8"));
				} else {
					in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
				}
				String inputLine;
				StringBuffer response = new StringBuffer();

				while ((inputLine = in.readLine()) != null) {
					response.append(inputLine);
				}
				in.close();

				result = new ObjectMapper().readValue(response.toString(), LinkedHashMap.class);
				if (isLineAuth) {
					System.setProperty("jsse.enableSNIExtension", "");
				}
			} else {
				logger.error(String.format("ResponseCode Error : Code(%s)", responseCode));
			}
		} catch (Exception e) {
			logger.error("", e);
		}

		return result;
	}

	public static String sendSapRestPost(String sendUrl, String param) throws Exception {
		StringBuffer bufResult = new StringBuffer();
		URL url = null;
		HttpURLConnection conn = null;
		try {
			url = new URL(sendUrl);
			conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setDoOutput(true);

			OutputStream out = conn.getOutputStream();
			out.write(param.getBytes("UTF-8"));
			out.flush();
			out.close();

			int responseCode = conn.getResponseCode();
			if (responseCode == HttpURLConnection.HTTP_OK) {
				BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
				String inputLine;
				StringBuffer response = new StringBuffer();

				while ((inputLine = in.readLine()) != null) {
					response.append(inputLine);
				}
				in.close();

				bufResult.append(response.toString());

			}
		} catch (Exception e) {
			logger.error("", e);
		}

//      String tempResult = "{\"json_objects\":"
//            + "[{\"ITEMCD\":\"KSY0036A\",\"SCCITEMCD\":\"KSY0036A\",\"CHANNEL\":\"CH010\",\"ONHAND\":\"5827.000000\",\"TOTAQTY\":\"35.000000\",\"TOTFAQTY1\":\"5\",\"COONHAND\":\"5797\",\"TOTOPENQTY\":\"10031.000000\",\"COAVQTY\":\"-4234\",\"AQTY\":\"5.000000\",\"AFQTY\":\"5.000000\",\"CHAVQTY\":\"-4234\",\"AVQTY\":\"50\"},"
//            + "{\"ITEMCD\":\"KSY0037B\",\"SCCITEMCD\":\"KSY0037B\",\"CHANNEL\":\"CH140\",\"ONHAND\":\"5827.000000\",\"TOTAQTY\":\"35.000000\",\"TOTFAQTY1\":\"5\",\"COONHAND\":\"5797\",\"TOTOPENQTY\":\"10031.000000\",\"COAVQTY\":\"-4234\",\"AQTY\":\"30.000000\",\"AFQTY\":\"0.000000\",\"CHAVQTY\":\"-4204\",\"AVQTY\":\"40\"},"
//            + "{\"ITEMCD\":\"KSY0038C\",\"SCCITEMCD\":\"KSY0038C\",\"CHANNEL\":\"CH140\",\"ONHAND\":\"5827.000000\",\"TOTAQTY\":\"35.000000\",\"TOTFAQTY1\":\"5\",\"COONHAND\":\"5797\",\"TOTOPENQTY\":\"10031.000000\",\"COAVQTY\":\"-4234\",\"AQTY\":\"30.000000\",\"AFQTY\":\"0.000000\",\"CHAVQTY\":\"-4204\",\"AVQTY\":\"100\"},"
//            + "{\"ITEMCD\":\"KSY0039D\",\"SCCITEMCD\":\"KSY0039D\",\"CHANNEL\":\"CH140\",\"ONHAND\":\"5827.000000\",\"TOTAQTY\":\"35.000000\",\"TOTFAQTY1\":\"5\",\"COONHAND\":\"5797\",\"TOTOPENQTY\":\"10031.000000\",\"COAVQTY\":\"-4234\",\"AQTY\":\"30.000000\",\"AFQTY\":\"0.000000\",\"CHAVQTY\":\"-4204\",\"AVQTY\":\"100\"},"
//            + "{\"ITEMCD\":\"KSY0099Y\",\"SCCITEMCD\":\"KSY0099Y\",\"CHANNEL\":\"CH140\",\"ONHAND\":\"5827.000000\",\"TOTAQTY\":\"35.000000\",\"TOTFAQTY1\":\"5\",\"COONHAND\":\"5797\",\"TOTOPENQTY\":\"10031.000000\",\"COAVQTY\":\"-4234\",\"AQTY\":\"30.000000\",\"AFQTY\":\"0.000000\",\"CHAVQTY\":\"-4204\",\"AVQTY\":\"150\"},"
//            + "{\"ITEMCD\":\"KSY0099Z\",\"SCCITEMCD\":\"KSY0099Z\",\"CHANNEL\":\"CH140\",\"ONHAND\":\"5827.000000\",\"TOTAQTY\":\"35.000000\",\"TOTFAQTY1\":\"5\",\"COONHAND\":\"5797\",\"TOTOPENQTY\":\"10031.000000\",\"COAVQTY\":\"-4234\",\"AQTY\":\"30.000000\",\"AFQTY\":\"0.000000\",\"CHAVQTY\":\"-4204\",\"AVQTY\":\"110\"},"
//            + "{\"ITEMCD\":\"KSY0099X\",\"SCCITEMCD\":\"KSY0099X\",\"CHANNEL\":\"CH140\",\"ONHAND\":\"5827.000000\",\"TOTAQTY\":\"35.000000\",\"TOTFAQTY1\":\"5\",\"COONHAND\":\"5797\",\"TOTOPENQTY\":\"10031.000000\",\"COAVQTY\":\"-4234\",\"AQTY\":\"30.000000\",\"AFQTY\":\"0.000000\",\"CHAVQTY\":\"-4204\",\"AVQTY\":\"110\"},"
//            + "{\"ITEMCD\":\"TZAOA0035A\",\"SCCITEMCD\":\"TZAOA0035A\",\"CHANNEL\":\"CH140\",\"ONHAND\":\"5827.000000\",\"TOTAQTY\":\"35.000000\",\"TOTFAQTY1\":\"5\",\"COONHAND\":\"5797\",\"TOTOPENQTY\":\"10031.000000\",\"COAVQTY\":\"-4234\",\"AQTY\":\"30.000000\",\"AFQTY\":\"0.000000\",\"CHAVQTY\":\"-4204\",\"AVQTY\":\"110\"}],"
//            + "\"success\":true,\"message\":\"success\",\"count\":5}";
//      return tempResult;

		return bufResult.toString();
	}

	public static List<Map<String, Object>> getJsonToList(String jsonObjectStr){

		List<Map<String, Object>> data = new ArrayList<Map<String, Object>>();

		try {
			Gson gson = new Gson();
			JsonElement element = gson.fromJson (jsonObjectStr, JsonElement.class);
			JsonObject jsonObj = element.getAsJsonObject();
			ObjectMapper mapper = new ObjectMapper();
			data = mapper.readValue(jsonObj.get("json_objects").toString(), new TypeReference<List<Map<String, Object>>>(){});
		} catch (Exception e) {
			logger.error("", e);
		}
		return data;
	}

	public static String makeParam(Map<String, String> param) {
		StringBuffer buf = new StringBuffer();
		for (String key : param.keySet()) {
			buf.append(key);
			buf.append("=");
			buf.append(param.get(key));
			buf.append("&");
		}
		return buf.toString();
	}
}
// :)--