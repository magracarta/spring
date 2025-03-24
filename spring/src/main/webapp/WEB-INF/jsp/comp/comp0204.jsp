 <%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 문자발송 > null > 견본문자
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var tab_id;
		
		$(document).ready(function() {
			$('ul.tabs-c li a').click(function() {
			    tab_id = $(this).attr('data-tab');
			    $('ul.tabs-c li a').removeClass('active');
			    $('.tabs-inner').removeClass('active');
			    $(this).addClass('active');
			    $("#"+tab_id).addClass('active');
			});
			if('${inputParam.tapType}' == 'comm') {
				$('#commBtn').trigger("click");
			}
		});
		
		//견본문자
		function setSampleSMSInfo(row) {
			opener.setSampleSMSInfo(row);
			window.close();	
		}
		
		function fnClose() {
			window.close();
		}
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap" style="padding-bottom:0px;">
<!-- 탭 -->
			<ul class="tabs-c">
				<li class="tabs-item">
					<a href="#" class="tabs-link active"  data-tab="inner1">개별</a>
				</li>
				<li class="tabs-item">
					<a href="#" class="tabs-link"  data-tab="inner2" id="commBtn">공통</a>
				</li>
			</ul>
<!-- /탭 -->	  
			<div class="title-wrap mt10">
				<div id="inner1" class="tabs-inner active"  style="height: 400px; width:100%;"> 
					<iframe src="/comp/comp020401?parent_js_name=${inputParam.parent_js_name}" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="height: 400px; width:100%;"> 
					<iframe src="/comp/comp020402?parent_js_name=${inputParam.parent_js_name}" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe> 
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>