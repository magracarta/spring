<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 서비스관련코드 > 고장부위코드관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-03-16 10:48:19
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
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
	<!-- 탭 -->
			<div class="contents">
					<ul class="tabs-c">
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12"  data-tab="inner1">고장부위</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12"  data-tab="inner2">고장현상</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12"  data-tab="inner3">고장원인</a>
						</li>
					</ul>
	<!-- /탭 -->	  
			
	<!-- /메인 타이틀 -->
			
				<div id="inner1" class="tabs-inner active"  style="height: 630px;"> 
					<iframe src="/comm/comm040101" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="height: 630px;"> 
					<iframe src="/comm/comm040102" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner3" class="tabs-inner " style="height: 630px;"> 
					<iframe src="/comm/comm040103" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
			</div>		
						
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</body>
</html>