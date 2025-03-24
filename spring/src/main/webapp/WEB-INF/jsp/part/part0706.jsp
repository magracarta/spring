<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 출하시 지급품 관리 > null > null
-- 작성자 : 강명지
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			$('ul.tabs-c li a').click(function() {
			    var tab_id = $(this).attr('data-tab');
			 	
			    $('ul.tabs-c li a').removeClass('active');
			    $('.tabs-inner').removeClass('active');
			 
			    $(this).addClass('active');
			    $("#"+tab_id).addClass('active');
			});
		});
		
	</script>
</head>
<body>
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
	<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
	<!-- 탭 -->
	<div class="contents">
			<ul class="tabs-c">
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12 active"  data-tab="inner1">출하지급품</a>
				</li>
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12"  data-tab="inner2" id="commBtn">장비입고옵션</a>
				</li>
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12"  data-tab="inner3">RSP 관리</a>
				</li>
			</ul>
	<!-- /탭 -->	  
			
	<!-- /메인 타이틀 -->
			
				<div id="inner1" class="tabs-inner active"  style="height: 550px;"> 
					<iframe src="/part/part070601" id="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="height: 550px;"> 
					<iframe src="/part/part070602" id="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe> 
				</div>
				<div id="inner3" class="tabs-inner " style="height: 550px;">
					<iframe src="/part/part070603" id="content3Frame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
			</div>
		</div>		
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</body>
</html>