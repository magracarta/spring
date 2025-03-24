<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<!-- 
사용안함 -> comp0707 사용할것.
 -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<% 
	//request.setCharacterEncoding("UTF-8");  //한글깨지면 주석제거
	//request.setCharacterEncoding("EUC-KR");  //해당시스템의 인코딩타입이 EUC-KR일경우에
	String inputYn = request.getParameter("inputYn"); 
	String roadFullAddr = request.getParameter("roadFullAddr");   
	String roadAddrPart1 = request.getParameter("roadAddrPart1");  
	String roadAddrPart2 = request.getParameter("roadAddrPart2"); 
	String engAddr = request.getParameter("engAddr");             
	String jibunAddr = request.getParameter("jibunAddr");        
	String zipNo = request.getParameter("zipNo");                
	String addrDetail = request.getParameter("addrDetail");      
	String admCd    = request.getParameter("admCd");             
	String rnMgtSn = request.getParameter("rnMgtSn");            
	String bdMgtSn  = request.getParameter("bdMgtSn");           
	String detBdNmList  = request.getParameter("detBdNmList");	 
	/** 2017년 2월 추가제공 **/                                   
	String bdNm  = request.getParameter("bdNm");                   
	String bdKdcd  = request.getParameter("bdKdcd");             
	String siNm  = request.getParameter("siNm");                 
	String sggNm  = request.getParameter("sggNm");               
	String emdNm  = request.getParameter("emdNm");               
	String liNm  = request.getParameter("liNm");                 
	String rn  = request.getParameter("rn");                     
	String udrtYn  = request.getParameter("udrtYn");             
	String buldMnnm  = request.getParameter("buldMnnm");         
	String buldSlno  = request.getParameter("buldSlno");         
	String mtYn  = request.getParameter("mtYn");                 
	String lnbrMnnm  = request.getParameter("lnbrMnnm");         
	String lnbrSlno  = request.getParameter("lnbrSlno");         
	/** 2017년 3월 추가제공 **/
	String emdNo  = request.getParameter("emdNo");
	
%>
</head>
<script language="javascript">
// opener관련 오류가 발생하는 경우 아래 주석을 해지하고, 사용자의 도메인정보를 입력합니다. ("주소입력화면 소스"도 동일하게 적용시켜야 합니다.)
//document.domain = "localhost:8090";

/*
		모의 해킹 테스트 시 팝업API를 호출하시면 IP가 차단 될 수 있습니다. 
		주소팝업API를 제외하시고 테스트 하시기 바랍니다.
		
		**변수명 정의(https://www.juso.go.kr/addrlink/devAddrLinkRequestGuide.do?menu=roadApi)
		roadFullAddr		전체 도로명주소
		roadAddrPart1		도로명주소(참고항목 제외)
		roadAddrPart2		도로명주소 참고항목
		jibunAddr			지번주소
		engAddr				도로명주소(영문)
		zipNo				우편번호A
		addrDetail			고객 입력 상세 주소
		admCd				행정구역코드
		rnMgtSn				도로명코드
		bdMgtSn				건물관리번호
		detBdNmList			상세건물명
		bdNm				건물명
		bdKdcd				공동주택여부(1 : 공동주택, 0 : 비공동주택)
		siNm				시도명
		sggNm				시군구명
		emdNm				읍면동명
		liNm				법정리명
		rn					도로명
		udrtYn				지하여부(0 : 지상, 1 : 지하)
		buldMnnm			건물본번
		buldSlno			건물부번
		mtYn				산여부(0 : 대지, 1 : 산)
		lnbrMnnm			지번본번(번지)
		lnbrSlno			지번부번(호)
		emdNo				읍면동일련번호
*/

function init(){
	var url = location.href;
	// 2020-03 만료, 그 전에 운영 키 받아서 바꿔야함
	var confmKey = "U01TX0FVVEgyMDIwMDEyOTE2MDc0MDEwOTQyMjY=";
	var resultType = "4"; // 도로명주소 검색결과 화면 출력내용, 1 : 도로명, 2 : 도로명+지번, 3 : 도로명+상세건물명, 4 : 도로명+지번+상세건물명
	var inputYn= "<%=inputYn%>";
	var type = location.search.replace("?type=","");
	
	if(inputYn != "Y"){
		document.form.confmKey.value = confmKey;
		document.form.returnUrl.value = url;
		document.form.resultType.value = resultType;
		document.form.action="http://www.juso.go.kr/addrlink/addrLinkUrl.do"; //인터넷망
		//document.form.action="http://www.juso.go.kr/addrlink/addrMobileLinkUrl.do"; //모바일 웹인 경우, 인터넷망
		document.form.submit();
	}else{
		var resultJson = {
			roadFullAddr:"<%=roadFullAddr%>",
			roadAddrPart1:"<%=roadAddrPart1%>",
			addrDetail:"<%=addrDetail%>",
			roadAddrPart2:"<%=roadAddrPart2%>",
			engAddr:"<%=engAddr%>",
			jibunAddr:"<%=jibunAddr%>",
			zipNo:"<%=zipNo%>", 
			admCd:"<%=admCd%>", 
			rnMgtSn:"<%=rnMgtSn%>", 
			bdMgtSn:"<%=bdMgtSn%>", 
			detBdNmList:"<%=detBdNmList%>", 
			bdNm:"<%=bdNm%>", 
			bdKdcd:"<%=bdKdcd%>", 
			siNm:"<%=siNm%>", 
			sggNm:"<%=sggNm%>", 
			emdNm:"<%=emdNm%>", 
			liNm:"<%=liNm%>", 
			rn:"<%=rn%>", 
			udrtYn:"<%=udrtYn%>", 
			buldMnnm:"<%=buldMnnm%>", 
			buldSlno:"<%=buldSlno%>", 
			mtYn:"<%=mtYn%>", 
			lnbrMnnm:"<%=lnbrMnnm%>", 
			lnbrSlno:"<%=lnbrSlno%>", 
			emdNo:"<%=emdNo%>",
			type:type
		}
		opener.${inputParam.execFuncName}(resultJson);
		window.close();
		}
}
</script>
<body onload="init();">
	<form id="form" name="form" method="post">
		<input type="hidden" id="confmKey" name="confmKey" value=""/>
		<input type="hidden" id="returnUrl" name="returnUrl" value=""/>
		<input type="hidden" id="resultType" name="resultType" value=""/>
		<!-- 해당시스템의 인코딩타입이 EUC-KR일경우에만 추가 START-->
		<!-- 
		<input type="hidden" id="encodingType" name="encodingType" value="EUC-KR"/>
		 -->
		<!-- 해당시스템의 인코딩타입이 EUC-KR일경우에만 추가 END-->
	</form>
</body>
</html>