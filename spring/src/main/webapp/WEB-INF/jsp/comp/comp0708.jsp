<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > 공통업무팝업 > null > 결재요청(결재처리와 다름)
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-02-05 16:47:04
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var apprMsg = "결재요청합니다.";
		var apprCd = "02";
	
		$(document).ready(function() {
			console.log("${inputParam.writer_appr_yn}");
			init();
		});
		
		function init() {
			if (typeof opener.${inputParam.parent_js_name} !== 'function') {
				alert("부모페이지에서 ${inputParam.parent_js_name} 함수를 선언하세요.");
				$("button[onclick='javascript:goSave();']").attr("disabled", true);
			} 
			var code = $M.getValue("appr_status_cd");
			fnSetApprCd(code);
		}
		
		function fnSetApprCd(code) {
			$("#appr_memo").attr("placeholder", fnGetApprMsg(code));
			if ("${writer_appr_yn}" == "Y") {
				if (code != apprCd) {
					$("#writer_appr_div").css("display", "none");
				} else {
					$("#writer_appr_div").css("display", "inline-block");
				}
			}
		}
		
		function fnGetApprMsg(code) {
			if (code == apprCd) {
				return apprMsg;
			} 
		}
		
		function fnClose() {
			window.close();
		}
		
		function goRequest() {
			if (opener == null) {
				alert("결재하려는 창을 닫으면 결재처리를 할 수 없습니다.");
				return false;
			}
			var appr_memo = $M.getValue("appr_memo");
			var param = {
				"appr_job_seq" : '${inputParam.appr_job_seq}',	
				"seq_no" : '${inputParam.seq_no}',	
				"appr_status_cd" : $M.getValue("appr_status_cd"),
				"appr_memo" : appr_memo == "" ? fnGetApprMsg($M.getValue("appr_status_cd")) : appr_memo,
			}
			var msg = "결재요청하시겠습니까?";
			// 전결 결재처리
			if ($M.getValue("writer_appr_yn") == "Y" && param.appr_status_cd == apprCd) {
				param["writer_appr_yn"] = "Y";
				msg = "전결처리하시겠습니까?";
			} else {
				param["writer_appr_yn"] = "N";
			}
			if (confirm(msg) == false) {
				return false;
			}
			<c:if test="${not empty inputParam.parent_js_name}">
				opener.${inputParam.parent_js_name}(param);	
				fnClose();
			</c:if>
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
	<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title" id="title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 검색결과 -->
			<div>
				<span class="mt10">
					<input type="radio" value="02" name="appr_status_cd" class="appr-cd" onclick="javascript:fnSetApprCd(apprCd)" id="val02" checked="checked"><label for="val02">요청</label>
				</span>
				<div class="mt10">
					<textarea style="width: 100%; height: 60px; resize: none" placeholder="결재요청합니다." id="appr_memo" name="appr_memo"></textarea>				
				</div>
			</div>
			<div class="btn-group mt5">
				<div class="left" style="position: relative;margin-top: -15px;margin-left: -3px;">
					<c:if test="${inputParam.writer_appr_yn eq 'Y' }">
						<label style="line-height: 2" id="writer_appr_div"><input type="checkbox" value="Y" name="writer_appr_yn" id="writer_appr_yn">전결</label>
					</c:if> 
				</div>						
				<div class="right">
					<!-- 임시 -->
					<button type="button" class="btn btn-info" onclick="goRequest()">저장</button>
					<button type="button" class="btn btn-info" onclick="fnClose()">닫기</button>
					<%-- <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include> --%>
				</div>
			</div>			
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>