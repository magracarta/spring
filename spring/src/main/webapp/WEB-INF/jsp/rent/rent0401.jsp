<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비현황 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
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
<div class="content-wrap">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /메인 타이틀 -->
			<div class="contents">
				<!-- 탭 -->
				<ul class="tabs-c">
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12   active" data-tab="inner1">센터별 장비현황</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12" data-tab="inner2" >연식별 장비현황</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12" data-tab="inner3" >가동시간별 장비현황</a>
					</li>
				</ul>
				<!-- 탭 -->
								
				<div id="inner1" class="tabs-inner active"  style="height: 700px;"> 
					<iframe src="/rent/rent040101" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="height: 700px;"> 
					<iframe src="/rent/rent040102" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner3" class="tabs-inner " style="height: 700px;"> 
					<iframe src="/rent/rent040103" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>	
			</div>
	<!-- /contents 전체 영역 -->	
	</div>	
	<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
</form>
</body>
</html>