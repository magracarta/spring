<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 일계표 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var tab_id;
		
		$('iframe').load(function(){
			var stDt = $('iframe').contents().find("[name='s_start_dt']");
		});
		
		$(document).ready(function() {
			
			setTimeout(function() {
				$('ul.tabs-c li a').click(function() {
				    tab_id = $(this).attr('data-tab');
					
				    $('ul.tabs-c li a').removeClass('active');
				    $('.tabs-inner').removeClass('active');
				 
				    $(this).addClass('active');
				    $("#"+tab_id).addClass('active');
				    if(tab_id == 'inner2') {
						var startDt = $("#contentFrame1")[0].contentWindow.$("#s_start_dt").val();
						var endDt = $("#contentFrame1")[0].contentWindow.$("#s_end_dt").val();
						var orgCode = $("#contentFrame1")[0].contentWindow.$("#s_org_code").val();
						$("#contentFrame2")[0].contentWindow.$("#s_start_dt").val(startDt);
						$("#contentFrame2")[0].contentWindow.$("#s_end_dt").val(endDt);
						<%--if("${SecureUser.org_type}" == "BASE") {--%>
						if(${page.fnc.F00036_001 eq 'Y'}) {
							$("#contentFrame2")[0].contentWindow.$M.setValue("s_org_code", orgCode);
						}
						$("#contentFrame2")[0].contentWindow.goSearch();
				    } else {
				    	var startDt = $("#contentFrame2")[0].contentWindow.$("#s_start_dt").val();
						var endDt = $("#contentFrame2")[0].contentWindow.$("#s_end_dt").val();
						var orgCode = $("#contentFrame2")[0].contentWindow.$("#s_org_code").val();
						$("#contentFrame1")[0].contentWindow.$("#s_start_dt").val(startDt);
						$("#contentFrame1")[0].contentWindow.$("#s_end_dt").val(endDt);
						<%--if("${SecureUser.org_type}" == "BASE") {--%>
						if(${page.fnc.F00036_001 eq 'Y'}) {
							$("#contentFrame1")[0].contentWindow.$M.setValue("s_org_code", orgCode);
						}
// 						$("#contentFrame1")[0].contentWindow.goSearchRequirement();
						$("#contentFrame1")[0].contentWindow.goSearch();
				    }
				    
				});
			}, 1000);
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
							<a href="#" class="tabs-link font-12 active" data-tab="inner1">명세</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12" data-tab="inner2">집계</a>
						</li>
					</ul>
<!-- /탭 -->		
			
				<div id="inner1" class="tabs-inner active"  style="height: 750px;">
					<iframe src="/cust/cust030201" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="height: 850px;"> 
					<iframe src="/cust/cust030202" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe> 
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