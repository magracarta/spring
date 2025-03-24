<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > CAP Call > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-21 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
	<script type="text/javascript">
		$(document).ready(function() {
		});

		// 저장
		function goSave() {
			var frm = document.main_form;
			//validationcheck
			if($M.validation(frm,
					{field:["as_call_result_cd", "remark", "change_plan_dt"]})==false) {
				return;
			};

			$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm), {method : 'POST'},
					function (result) {
						if(result.success) {
							alert("저장이 완료되었습니다.");
							
							goMachineCapCallDetail();
							window.opener.goSearch();
							
							fnClose();

						}
					}
				);
		}

		function goMachineCapCallDetail() {
			var params = {
				"s_machine_seq" : $M.getValue("machine_seq"),
				"s_cap_cnt" : $M.getValue("cap_cnt")
			};

			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
			$M.goNextPage('/serv/serv040407p02', $M.toGetParam(params), {popupStatus: popupOption});
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 고객대장
		function goLedgerPopUp() {
			var param = {
				"cust_no" : $M.getValue("cust_no")
			};

			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
			$M.goNextPage('/cust/cust0102p01/', $M.toGetParam(param), {popupStatus : poppupOption});
		}

		// 장비대장
		function goMachineDetail() {
			var machineSeq = $M.getValue("machine_seq");

			// 보낼 데이터
			var params = {
				"s_machine_seq" : machineSeq
			};
			
			var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
			$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 21.08.25 (SR:11607) CAP CALL 문자 템플릿 적용
		// 문자발송
		function fnSendSms() {
			console.log($M.getValue("center_org_code"));
			var param = {
					"name" : $M.getValue("cust_name"),
					"hp_no" : $M.getValue("hp_no"),
					"template_use_yn" : "Y",
					"s_machine_seq" : $M.getValue("machine_seq"),
					"s_as_call_type_cd" : "4",
					"s_cap_yn" : $M.getValue("cap_yn"),
					"s_mch_type_cad" : $M.getValue("mch_type_cad"),
					"s_org_code" : $M.getValue("center_org_code")
			}
			openSendSmsPanel($M.toGetParam(param));
		}
</script>
</head>
<body class="bg-white">
	<form id="main_form" name="main_form">
	<input type="hidden" id="machine_seq" name="machine_seq" value="${result.machine_seq}">
	<input type="hidden" id="cust_no" name="cust_no" value="${result.cust_no}">
	<input type="hidden" id="cap_cnt" name="cap_cnt" value="${result.cap_cnt}">
	<input type="hidden" id="cap_yn" name="cap_yn" value="${result.cap_yn}">
	<input type="hidden" id="mch_type_cad" name="mch_type_cad" value="${result.mch_type_cad}">
	<input type="hidden" id="center_org_code" name="center_org_code" value="${result.center_org_code}">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<!-- 상단 폼테이블 -->
				<div>
					<div class="title-wrap">
						<h4>CAP CALL</h4>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">고객명</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<input type="text" class="form-control width120px" name="cust_name" id="cust_name" required="required" alt="고객명" readonly="readonly" value="${result.cust_name}">
										</div>
										<div class="col-auto">
											<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goLedgerPopUp()">고객대장</button>
										</div>
									</div>
								</td>
								<th class="text-right">연락처</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0 width140px" id="hp_no" name="hp_no" format="phone" readonly="readonly" value="${result.hp_no}">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"> <i class="material-iconsforum"></i> </button>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">모델명</th>
								<td>
									<input type="text" class="form-control width120px" id="machine_name" name="machine_name" readonly="readonly" value="${result.machine_name}">
								</td>
								<th class="text-right">차대번호</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-8">
											<input type="text" class="form-control width180px" name="body_no" id="body_no" readonly="readonly" value="${result.body_no}">
										</div>
										<div class="col-auto">
											<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goMachineDetail()">장비대장</button>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">예정일자</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="plan_dt" name="plan_dt" dateFormat="yyyy-MM-dd" disabled="disabled" value="${result.plan_dt}">
									</div>
								</td>
								<th class="text-right essential-item">통화구분</th>
								<td>
									<select class="form-control width100px essential-bg" id="as_call_result_cd" name="as_call_result_cd" required="required" alt="통화구분">
										<option value="">- 선택 -</option>
										<c:forEach items="${codeMap['AS_CALL_RESULT']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
								</select>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">내용</th>
								<td colspan="3">
									<textarea class="form-control essential-bg" style="height: 300px;" id="remark" name="remark" maxlength="500" required="required" alt="내용"></textarea>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">예정일자 변경</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0 essential-bg calDate" id="change_plan_dt" name="change_plan_dt" dateFormat="yyyy-MM-dd" required="required" alt="예정일자 변경">
									</div>
								</td>
								<th class="text-right">처리자</th>
								<td>
									<input type="text" class="form-control width120px" id="kor_name" name="kor_name" disabled="disabled" value="${SecureUser.kor_name}">
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- /상단 폼테이블 -->
				<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R" /></jsp:include>
					</div>
				</div>
				<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>