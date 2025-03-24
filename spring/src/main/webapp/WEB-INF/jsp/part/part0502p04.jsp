<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > HOMI관리 > null > HOMI관리상세
-- 작성자 : 박예진
-- 최초 작성일 : 2021-05-21 16:30:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var tab_id;
	
	$(document).ready(function() {
		$('ul.tabs-c li a').click(function() {
		    var tab_id = $(this).attr('data-tab');
		    $('ul.tabs-c li a').removeClass('active');
		    $('.tabs-inner').removeClass('active');
		    var url = '';
		    if(tab_id == 'inner1') {
		    	url = '/part/part0502p01?warehouse_cd=${inputParam.warehouse_cd}&homi_dt=${inputParam.homi_dt}&seq_no=${inputParam.seq_no}';
		    } else if(tab_id == 'inner2') {
			    url = '/part/part0502p0401?warehouse_cd=${inputParam.warehouse_cd}&homi_dt=${inputParam.homi_dt}&seq_no=${inputParam.seq_no}';
		    }
	    	$("#"+tab_id).html('<iframe src="' + url + '" id="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>');
		    $(this).addClass('active');
		    $("#" + tab_id).addClass('active');
		});
		
// 		$('ul.tabs-c li a').click(function() {
// 		    tab_id = $(this).attr('data-tab');
			
// 		    $('ul.tabs-c li a').removeClass('active');
// 		    $('.tabs-inner').removeClass('active');
		 
// 		    $(this).addClass('active');
// 		    $("#"+tab_id).addClass('active');
// 		});
	});
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <div class="popup-wrap width-100per">
		<div class="main-title">
      		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<div class="content-wrap">
<!-- 메인 타이틀 -->
	<!-- 탭 -->
			<ul class="tabs-c">
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12 active" data-tab="inner1">HOMI분출</a>
				</li>
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12" data-tab="inner2">HOMI미지정 부품 회수</a>
				</li>
			</ul>
	<!-- /탭 -->	  
	<!-- /메인 타이틀 -->
				<div id="inner1" class="tabs-inner active"  style="height: 550px; margin-top: 0px !important;"> 
					<iframe src="/part/part0502p01?warehouse_cd=${inputParam.warehouse_cd}&homi_dt=${inputParam.homi_dt}&seq_no=${inputParam.seq_no}" 
							id="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner" style="height: 550px; margin-top: 0px !important;"> 
				</div>
			</div>		
		</div>
<!-- /contents 전체 영역 -->
</form>	
</body>
</html>