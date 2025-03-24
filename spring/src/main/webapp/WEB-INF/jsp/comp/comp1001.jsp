<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>리포트팝업</title>
<link rel="stylesheet" type="text/css" href="/ClipReport4/css/clipreport.css">
<link rel="stylesheet" type="text/css" href="/ClipReport4/css/UserConfig.css">
<link rel="stylesheet" type="text/css" href="/ClipReport4/css/font.css">
<script type='text/javascript' src='/ClipReport4/js/jquery-1.11.1.js'></script>
<script type='text/javascript' src='/ClipReport4/js/clipreport.js'></script>
<script type='text/javascript' src='/ClipReport4/js/UserConfig.js'></script>
<script type='text/javascript' src='/static/js/jquery.mfactory-2.2.js'></script>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 팝업 > 리포트 출력
-- 작성자 : 이종술
-- 최초 작성일 : 2020-09-01 14:23:37
------------------------------------------------------------------------------------------------------------------%>
<script>
var urlPath = document.location.protocol + "//" + document.location.host;
function report() {
	var jsonStr = unescape('${report_data}');
	console.log('report_path : ${report_path}');
	console.log('report_data : ' + jsonStr);

	var oof = "<?xml version='1.0' encoding='utf-8'?>"
			+ "<oof version='3.0'>"
			+ "<document title='report' enable-thread='0'>"
			+ "    <file-list>"
			+ "        <file type='reb.root' communicationType='local' path='%root%/newcrf/${report_path}'>"
			+ "            <connection-list>" 
			+ "                <connection type='memo' namespace='*'>"
			+ "                    <config-param-list>"
			+ "                        <config-param name='data'><![CDATA[" + jsonStr + "]]></config-param>"
			+ "                    </config-param-list>"
			+ "                    <content content-type='json' namespace='*'>"
			+ "                        <content-param name='encoding'>utf-8</content-param>"
			+ "                    </content>"
			+ "                </connection>"
			+ "            </connection-list>"
			+ "        </file>"
			+ "    </file-list>"
			+ "</document>"
			+ "</oof>";
	/* var dataUrl = urlPath + "${report_data}";
	console.log(dataUrl);
	var data = {};		
	var oof = "<?xml version='1.0' encoding='utf-8'?>"
		+ "<oof version='3.0'>"
		+ "<document title='report' enable-thread='0'>"
		+ "    <file-list>"
		+ "        <file type='reb.root' path='%root%/crf/${report_path}'>"
		+ "            <connection-list>" 
		+ "                <connection type='http' namespace='JSON'>"
		+ "                    <config-param-list>"
		//+ "                        <config-param name='path'>http://localhost:8080/static/report.json</config-param>"
		+ "                        <config-param name='path'><![CDATA[" + dataUrl + "]]></config-param>"
		+ "                        <config-param name='method'>get</config-param>"
		+ "                    </config-param-list>"
		+ "                    <content content-type='json'>"
		+ "                        <content-param name='encoding'>utf-8</content-param>"
		+ "                        <content-param name='root'>${root_key}</content-param>"
		+ "                    </content>"
		+ "                </connection>"
		+ "            </connection-list>"
		+ "        </file>"
		+ "    </file-list>"
		+ "</document>"
		+ "</oof>"; */
	//console.log(oof);
    var report = createReport(urlPath + "/ClipReport4/Clip.jsp", oof, document.getElementById('reportDiv'));
    //리포트 뷰어의 옵션
    //report.setSlidePage(true);
    
    //report.setStartSaveButtonEvent(function(){
    //	alert('save');
    //	return true;
    //});
    
    //report.setStartPrintButtonEvent(function(){ 
    //	printHistory(data, function(){
    //		return true;
    //	});
    //});
    var data = JSON.parse(jsonStr);
    
    report.setEndDrawPageEvent(function(){
    	$('.report_menu_close_button_svg_dis').hide();
    });
    
    report.setStartExcelButtonEvent(function(){
    	printHistory(data);
    	return true;
    });
    report.setStartHWPButtonEvent(function(){
    	printHistory(data);
    	return true;
    });
    report.setStartPDFButtonEvent(function(){
    	printHistory(data);
    	return true;
    });
    report.setEndPrintProgressEvent(function(){
    	printHistory(data);
    	return true;
    });
    
    //리포트 뷰어 실행
    report.view();
    //버튼 Disabled 설정
    report.buttonDisabled("close_button", true);
    if(!data.save){
    	report.buttonDisabled("save_button", true);
    }
    if(!data.hwp){
    	report.buttonDisabled("hwp_button", true);
    }
    if(!data.pdf){
    	report.buttonDisabled("pdf_button", true);
    }
    if(!data.excel){
    	report.buttonDisabled("excel_button", true);
    }
}

/**
 * 리포트 프린터 출력 수정
 */
function printHistory(data){
	if(data.hasOwnProperty('report_print_seq')){
		var param = {
			report_print_seq : data.report_print_seq	
		}
		
		$M.goNextPageAjax('/comp/comp1001/modify', $M.toGetParam(param) , {method : 'post'}, function(result){});
	}
}
</script>
</head>
<body onload="report();">
<div id='reportDiv' style='position:absolute;top:5px;left:5px;right:5px;bottom:5px;'></div>
</body>
</html>