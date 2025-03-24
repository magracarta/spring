<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객관리 > 홈페이지 문의관리 > null > 문의내역상세
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 완결 시 문자발송, 완결처리 버튼 숨김
			hideBtn();
			
		});
		
		// 완결처리
		function goComplete(sendYn) {
			var frm = document.main_form;
			if($M.validation(frm) == false) { 
				return;
			};
			// 문자 발송 후 -> Y값 가지고 완결처리 (공통팝업 문자발송 개발 완료 후 수정)
			if(sendYn != null) {
				if(sendYn == 'Y') {
					$M.setValue("sms_send_yn", sendYn);
					$M.goNextPageAjax(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
							function(result) {
								if(result.success) {
									fnClose();
									if (opener != null && opener.goSearch) {
										opener.goSearch();
									};
								}
							}
						);
				}
			// 문자 발송 X -> N값 가지고 완결처리
			} else {
				$M.setValue("sms_send_yn", "N");
				$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
						function(result) {
							if(result.success) {
								fnClose();
								if (opener != null && opener.goSearch) {
									opener.goSearch();
								}
							}
						}
					);
			}
		}
		
		// 문자발송, 완결처리 버튼 처리
		function hideBtn() {
			if('${inputParam.proc_gubun_cd}' == '완결') {
				$("#btnHide").children().eq(1).attr('id','btnComplete');
		       	$("#btnComplete").css({
		            display: "none"
		        });
			}
			var smsYn = '${result.sms_send_yn}';
			if(smsYn == 'Y') {
				$("#btnHide").children().eq(0).attr('id','btnSms');
		       	$("#btnSms").css({
		            display: "none"
		        });
			}
		}
	
		 // 문자발송
		function fnSendSms() {
			var frm = document.main_form;
			if($M.validation(frm) == false) { 
				return;
			};
			 var msg = confirm("문자 발송 시 자동으로 완결처리됩니다.\n진행하시겠습니까?");
			 
			 if(msg) {
				 var param = {
				   "name" : $M.getValue("cust_name"),
				   "hp_no" : $M.getValue("hp_no"),
				   "parent_js_name" : "goComplete"
				 }
				 openSendSmsPanel($M.toGetParam(param));
				 
			 } else {
				 return false;
			 }
		}
		 
		
		// 닫기
		function fnClose() {
			window.close();
		}
	
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="sms_send_yn" name="sms_send_yn" value="${result.sms_send_yn}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4 class="primary">문의내역상세</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">접수번호</th>
							<td>${result.seq_no}
								<input type="hidden" id="seq_no" name="seq_no" value="${result.seq_no}">
							</td>									
							<th class="text-right">게시판구분</th>
							<td>
								<input type="hidden" id="home_cs_type_cd" name="home_cs_type_cd" value="${result.home_cs_type_cd}">
								${result.home_cs_type_name}
							</td>
							<th class="text-right">장비</th>
							<td>${result.maker_name}</td>
						</tr>
						<tr>
							<th class="text-right">고객명</th>
							<td>${result.reg_name}
								<input type="hidden" id="cust_name" name="cust_name" value="${result.reg_name}">
							</td>									
							<th class="text-right">연락처</th>
							<td>${result.hp_no}
							<input type="hidden" id="hp_no" name="hp_no" value="${result.hp_no}">
							</td>
							<th class="text-right">모델</th>
							<td>${result.model_name}</td>
						</tr>
						<tr>
						<th class="text-right">제목</th>
							<td colspan="5" class="v-align-top">
								${result.title}
							</td>
						</tr>
						<tr>
							<th class="text-right">내용</th>
							<td colspan="5" class="v-align-top" style="height: 100px;">
								${result.content}
							</td>	
						</tr>								
						<tr>
							<th class="text-right essential-item">처리내용</th>
							<td colspan="5">										
								<textarea class="essential-bg" style="height: 100px;" placeholder="처리내용 입력필수" alt="처리내용" id="remark" name="remark" maxlength="650" required="required">${result.remark}</textarea>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->	
			<div class="btn-group mt10">
				<div class="right" id="btnHide">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>