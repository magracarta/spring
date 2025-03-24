<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > 공통업무팝업 > null > 결재처리
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-02-05 16:47:04
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var apprMsg = "결재합니다.";
		var refuseMsg = "반려합니다.";
		var cancelMsg = "취소합니다.";
		var apprEndMsg = "종결합니다.";
		var apprCd = "02";
		var refuseCd = "03";
		var cancelCd = "04";
		var apprEndCd = "05";
	
		$(document).ready(function() {
			init();
		});
		
		function init() {
			if (typeof opener.${inputParam.parent_js_name} !== 'function') {
				alert("부모페이지에서 ${inputParam.parent_js_name} 함수를 선언하세요.");
				$("button[onclick='javascript:goSave();']").attr("disabled", true);
			}
			$("#_goSave").focus();
			if ("${inputParam.appr_reject_only}" == "Y") {
				apprCd = "03";
				apprMsg = "반려합니다.";
			}

			if ("${inputParam.appr_end_only}" == "Y") {
				$M.setValue("appr_status_cd", apprEndCd);
				$("#appr_memo").attr("placeholder", apprEndMsg);
				$("#writer_appr_div").css("display", "none");
				return;
			}

			if ("${inputParam.appr_cancel_yn}" == "Y") {
				$M.setValue("appr_status_cd", cancelCd);
				$($("#title").children()[0]).html("결재취소");
			} else {
				$M.setValue("appr_status_cd", apprCd);
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
			console.log(code);
			if (code == apprCd) {
				return apprMsg;
			} else if (code == refuseCd) {
				return refuseMsg;
			} else if (code == cancelCd) {
				return cancelMsg;
			}
		}
		
		function fnClose() {
			window.close();
		}
		
		function goSave() {
			if (opener == null) {
				alert("결재하려는 창을 닫으면 결재처리를 할 수 없습니다.");
				return false;
			}
			var appr_memo = $M.getValue("appr_memo");
			if ($M.getValue("appr_status_cd") == apprEndCd && appr_memo == "") {
				alert("종결사유를 입력해 주세요.");
				return;
			}
			var param = {
				"appr_job_seq" : '${inputParam.appr_job_seq}',	
				"seq_no" : '${inputParam.seq_no}',	
				"appr_status_cd" : $M.getValue("appr_status_cd"),
				"appr_memo" : appr_memo == "" ? fnGetApprMsg($M.getValue("appr_status_cd")) : appr_memo,
				"appr_cancel_yn" : "${inputParam.appr_cancel_yn}"
			}

			var msg = "저장하시겠습니까?";
			switch(param.appr_status_cd) {
			  case apprCd: // 결재
			    msg = "결재하시겠습니까?";
			    break;
			  case refuseCd: // 반려
				msg = "반려하시겠습니까?";
			    break;
			  case cancelCd: // 결재취소
				msg = "결재를 취소하시겠습니까?\n이미 발송된 결재요청 쪽지는 취소되지않습니다.\n이미 결재되었을 경우 취소할 수 없습니다.";
			    break;
			  case apprEndCd: // 결재종결
				msg = "결재를 종결처리하시겠습니까?";
			    break;
			  default:
				msg = "저장하시겠습니까?"; // 에러
			}
			
			// 전결 결재처리
			if ("${writer_appr_yn}" == "Y" && $M.getValue("writer_appr_yn") == "Y" && param.appr_status_cd == apprCd) {
				param["writer_appr_yn"] = "Y";
			}
			$M.goNextPageAjaxMsg(msg, this_page, $M.toGetParam(param) , { method : 'POST' },
				function(result) {
					if(result.success) {
						param.appr_job_seq = result.appr_job_seq;
						if ("${inputParam.parent_js_name}" != "") {
							opener.${inputParam.parent_js_name}(param);	
						}
						fnClose();
					} 
				}
			);
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" value="${writer_appr_yn}">
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
					<c:choose>
						<c:when test="${inputParam.appr_reject_only eq 'Y'}">
							<input type="radio" checked="checked" value="03" name="appr_status_cd" class="appr-cd" id="val03"><label for="val03">반려</label>
						</c:when>
						<c:when test="${inputParam.appr_end_only eq 'Y'}">
							<input type="radio" checked="checked" value="05" name="appr_status_cd" class="appr-cd" id="val05"><label for="val05">종결</label>
						</c:when>
						<c:otherwise>
							<c:if test="${inputParam.appr_cancel_yn ne 'Y'}">
								<input type="radio" value="02" name="appr_status_cd" class="appr-cd" onclick="javascript:fnSetApprCd(apprCd)" id="val02" ${inputParam.appr_cancel_yn eq 'Y' ? 'disabled="disabled"' : '' }><label for="val02">승인</label>
								<input type="radio" value="03" name="appr_status_cd" class="appr-cd" onclick="javascript:fnSetApprCd(refuseCd)" id="val03" ${inputParam.appr_cancel_yn eq 'Y' ? 'disabled="disabled"' : '' }><label for="val03">반려</label>
							</c:if>
							<c:if test="${inputParam.appr_cancel_yn eq 'Y'}">
								<input type="radio" value="04" name="appr_status_cd" class="appr-cd" onclick="javascript:fnSetApprCd(apprCd)" id="val04" checked="checked"><label for="val04">취소</label>
							</c:if>
						</c:otherwise>
					</c:choose>
				</span>
				<div class="mt10">
					<textarea style="width: 100%; height: 60px; resize: none" placeholder="결재합니다." id="appr_memo" name="appr_memo"></textarea>				
				</div>
			</div>
			<div class="btn-group mt5">
				<div class="left" style="position: relative;margin-top: -15px;margin-left: -3px;">
<%-- 					<c:choose> --%>
<%-- 						<c:if test="${'Y' eq inputParam.except_write_yn}"> --%>
							
<%-- 						</c:if> --%>
<%-- 						<c:otherwise> --%>
<%-- 							<c:if test="${writer_appr_yn eq 'Y' && empty inputParam.appr_reject_only}"> --%>
<!-- 								<label style="line-height: 2" id="writer_appr_div"><input type="checkbox" value="Y" name="writer_appr_yn" id="writer_appr_yn">전결</label> -->
<%-- 							</c:if> --%>
<%-- 						</c:otherwise> --%>
<%-- 					</c:choose> --%>
					<c:if test="${writer_appr_yn eq 'Y' && empty inputParam.appr_reject_only}">
						<label style="line-height: 2" id="writer_appr_div"><input type="checkbox" value="Y" name="writer_appr_yn" id="writer_appr_yn">전결</label>
					</c:if> 
				</div>						
				<div class="right">
					<!-- 임시 -->
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>			
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>