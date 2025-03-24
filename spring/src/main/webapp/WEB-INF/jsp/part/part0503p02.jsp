<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 바코드출력관리 > null > 인쇄 시작위치지정
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		// 체크박스 세팅
		$(document).ready(function() {
			for (var i = 0; i < 27; i++) {
				$("#check").append( "<input type='checkbox' id='view"+i+"' style='width:24px;height:18px' "
									+ "onclick='fnChecked("+i+")''><label for='view"+i+"'><span style='font-size:16px'>&nbsp;작성</span></label>");
					
				if((i+1) % 3 == 0) { 
					$("#check").append("<br><br><br>"); 
				}else {
					$("#check").append("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
				}
			}
		});

		// 시작위치 체크
		function fnChecked(num) {
			document.main_form.reset();
			var i = 0; 
			// 현재 체크 위치 지정
			$M.setValue("checkNum", num);
			
			// 체크박스 체크설정
			for(i=0;i<27;i++) {
				if( i >= num ) { 
					$("#view"+i).attr("checked" , true) 
				} else {
					$("#view"+i).attr("checked" , false) 
				}
			}
		}
		
		function goBarcodePrint() {
			// TODO : 리포트 연계 필요.
			alert("리포트 연계 필요... barcodePrint03.jsp");
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form" style="height : 100%;">
	<input type="hidden" name="checkNum"/>
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			<button type="button" class="btn btn-info" style="width: 50px;" onclick="javascript:goBarcodePrint();">선택</button>
        </div>
     	<div style="width:100%;text-align:center" id="check">
			<br><br>
		</div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>