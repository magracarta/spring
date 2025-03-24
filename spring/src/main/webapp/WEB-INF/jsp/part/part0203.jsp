<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품발송-출고처리 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-05 17:06:42
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
		    
		    // 발송대장인쇄 버튼 처리
			if (tab_id == 'inner1' || tab_id == undefined) {
				$("#_goPrint").show();
			} else {
				$("#_goPrint").hide();
			}
		});
	});
	
	function goPrint() {
		var iframe;
		var rows;
 		
		iframe = document.getElementById("contentFrame1");
		rows = iframe.contentWindow.fnGetPageData();
		if (rows.length == 0) {
			alert("조회된 결과가 없습니다.");
			return false
		}
		var param = {
			"data" : rows
		}
		openReportPanel('part/part0203_01.crf', param);	
	}

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
							<a href="#" class="tabs-link font-12 active"  data-tab="inner1">부품출고처리</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12"  data-tab="inner2">정비부품 입/출고처리</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12"  data-tab="inner3">부품입고처리</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12"  data-tab="inner4">출하부품처리</a>
						</li>
						<li class="tabs-c-right-btn" style="margin-right:2%">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</li>
					</ul>
	<!-- /탭 -->	  
			
	<!-- /메인 타이틀 -->
			
				<div id="inner1" class="tabs-inner active"  style="height: 700px;">
					<iframe src="/part/part020301" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="height: 700px;">
					<iframe src="/part/part020302" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe> 
				</div>
				<div id="inner3" class="tabs-inner " style="height: 700px;">
					<iframe src="/part/part020303" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe> 
				</div>
				<div id="inner4" class="tabs-inner " style="height: 700px;">
					<iframe src="/part/part020304" id="contentFrame4" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe> 
				</div>
			</div>
						
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->
</div>	
</body>
</html>