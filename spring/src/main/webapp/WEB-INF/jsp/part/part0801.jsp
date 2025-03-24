<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 생산/선적오더관리 > 어테치먼트 발주관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2021-08-11 12:00:42
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
		});
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">	
<!-- 탭 -->			
					<ul class="tabs-c mt5">
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12 active" data-tab="inner1">마케팅</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12" data-tab="inner2">부품</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12" data-tab="inner3">출하</a>
						</li>
					</ul>
<!-- /탭 -->		
			
				<div id="inner1" class="tabs-inner active"  style="height: 740px;"> 
					<iframe src="/part/part080101" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="height: 740px;"> 
					<iframe src="/part/part080102" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe> 
				</div>
				<div id="inner3" class="tabs-inner " style="height: 830px;"> 
					<iframe src="/part/part080103" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="yes"></iframe> 
				</div>
			</div>
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>