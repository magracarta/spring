<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객관리 > 고객센터 > null > 고객불만사항상세
-- 작성자 : 성현우
-- 최초 작성일 : 2020-03-17 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			fnInit();
		});

		function fnInit() {
			var custCenterProcCd = "${result.cust_center_proc_cd}";
			if(custCenterProcCd == "3") {

				$("#body_no").prop("disabled", true);
				$("#req_memo").prop("disabled", true);
				$("#resp_memo").prop("disabled", true);
				$("#__goSearchMemberPopup").prop("disabled", true);

				$("#_goModify").addClass("dpn");
				$("#_goRemove").addClass("dpn");
				$("#_fnConfirm").addClass("dpn");
			}
		}

		// 직원조회 결과
		function fnSetMemberInfo(data) {
			$M.setValue("assign_mem_name", data.mem_name);
			$M.setValue("assign_mem_no", data.mem_no);
		}

		// 직원조회
		function goSearchMemberPopup() {

			var param = {
				"s_org_code" : ${SecureUser.org_code}
			};

			openSearchMemberPanel('fnSetMemberInfo', $M.toGetParam(param));
		}

		function fnSetDeviceHis(data) {
			// alert(JSON.stringify(data));

			$M.setValue("machine_seq", data.machine_seq);
			$M.setValue("body_no", data.body_no);
			$M.setValue("machine_name", data.machine_name);
			$M.setValue("sale_dt", data.sale_dt);

			$M.setValue("cust_no", data.cust_no);
			$M.setValue("cust_name", data.real_cust_name);
			$M.setValue("cust_hp_no", fnGetHPNum(data.real_hp_no));
			$M.setValue("sale_mem_name", data.sale_mem_name);
			$M.setValue("out_dt", data.out_dt);
			$M.setValue("center_org_code", data.center_org_code);
			$M.setValue("center_org_name", data.center_org_name);

		}

		function fnSendSms() {
			var param = {
				"name" : $M.getValue("cust_name"),
				"hp_no" : $M.getValue("cust_hp_no")
			};

			openSendSmsPanel($M.toGetParam(param));
		}

		// 완료처리
		function fnConfirm() {
			var frm = document.main_form;
			// validation check
			if ($M.validation(frm,
					{field: ["cust_center_seq", "assign_mem_no", "req_memo"]}) == false) {
				return;
			}

			var msg = "완료처리 하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/save/confirm", frm, {method: "POST"},
					function (result) {
						if (result.success) {
							alert("완료처리 되었습니다.");
							window.location.reload();
						}
					}
			);
		}

		// 수정
		function goModify() {
			var frm = document.main_form;
			// validation check
			if($M.validation(frm,
					{field:["cust_center_seq", "assign_mem_no", "req_memo"]}) == false) {
				return;
			};

			$M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(frm), {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("수정이 완료되었습니다.");
						window.location.reload();
					}
				}
			);
		}

		// 삭제
		function goRemove() {
			var frm = document.main_form;
			// validation check
			if($M.validation(frm,
					{field:["cust_center_seq"]}) == false) {
				return;
			};

			var memNo = '${SecureUser.mem_no}';
			$M.setValue("del_id", memNo);
			$M.setValue("use_yn", "N");

			var param = {
				"cust_center_seq" : $M.getValue("cust_center_seq"),
				"del_id" : $M.getValue("del_id"),
				"use_yn" : $M.getValue("use_yn"),
			}

			$M.goNextPageAjaxRemove(this_page + '/remove', $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("삭제가 완료되었습니다.");
						fnClose();
						window.opener.location.reload();
					}
				}
			);
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 수리내역
		function fixInfo() {
			// 보낼 데이터
			var machineSeq = $M.getValue("machine_seq");
			var params = {
				"s_machine_seq" : machineSeq
			};
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=920, left=0, top=0";
			$M.goNextPage('/comp/comp0506', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 거래원장
		function goLedgerPopUp() {
			var custNo = $M.getValue("cust_no");
			var param = {
				"s_cust_no" : custNo
			};

			openDealLedgerPanel($M.toGetParam(param));
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="cust_center_seq" name="cust_center_seq" value="${result.cust_center_seq}">
<input type="hidden" id="cust_center_proc_cd" name="cust_center_proc_cd" value="${result.cust_center_proc_cd}">
<input type="hidden" id="machine_seq" name="machine_seq" value="${result.machine_seq}">
<input type="hidden" id="upt_id" name="upt_id">
<input type="hidden" id="del_id" name="del_id">
<input type="hidden" id="use_yn" name="use_yn">
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
					<h4 class="primary">고객불만사항상세</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">접수일자</th>
						<td>
							<div class="form-row inline-pd pr">
								<div class="col-auto">
									<input type="text" class="form-control width120px" readonly="readonly" id="reg_dt" name="reg_dt" value="${result.reg_dt}">
								</div>
							</div>
						</td>
						<th class="text-right">접수자</th>
						<td>
							<input type="text" class="form-control width120px"  id="reg_mem_name" name="reg_mem_name" readonly="readonly" value="${result.reg_mem_name}">
							<input type="hidden" id="reg_mem_no" name="reg_mem_no" value="${result.reg_mem_no}">
						</td>
						<th class="text-right">접수부서</th>
						<td>
							<input type="text" class="form-control width140px" id="receipt_org_name" name="receipt_org_name" readonly="readonly" value="${result.receipt_org_name}">
							<input type="hidden" id="receipt_org_code" name="receipt_org_code" value="${result.receipt_org_code}">
						</td>
						<th class="text-right essential-item">처리자지정</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0 essential-bg width120px" name="assign_mem_name" id="assign_mem_name" readonly="readonly" required="required" alt="처리자지정" value="${result.assign_mem_name}">
								<input type="hidden" name="assign_mem_no" id="assign_mem_no" required="required" value="${result.assign_mem_no}" >
								<button type="button" id="__goSearchMemberPopup" name="__goSearchMemberPopup" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchMemberPopup()"><i class="material-iconssearch"></i></button>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">고객명</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-auto">
									<input type="text" class="form-control width120px" name="cust_name" id="cust_name" required="required" alt="고객명" readonly="readonly" value="${result.cust_name}">
									<input type="hidden" name="cust_no" id="cust_no" required="required" alt="고객명" value="${result.cust_no}">
								</div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goLedgerPopUp()">고객원장</button>
								</div>
							</div>
						</td>
						<th class="text-right">휴대폰</th>
						<td>
							<div class="input-group width140px">
								<input type="text" class="form-control border-right-0 width140px"  id="cust_hp_no" name="cust_hp_no" readonly="readonly" format="phone" value="${result.hp_no}">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
							</div>
						</td>
<%--						<th class="text-right">영업담당</th>--%>
<%--						<td>--%>
<%--							<input type="text" class="form-control width140px" name="sale_mem_name" id="sale_mem_name" readonly="readonly" value="${result.sale_mem_name}">--%>
<%--						</td>--%>
						<th class="text-right">담당센터</th>
						<td>
							<input type="text" class="form-control width140px" name="center_org_name" id="center_org_name" readonly="readonly" value="${result.center_org_name}">
							<input type="hidden" id="center_org_code" name="center_org_code" value="${result.center_org_code}">
						</td>
						<th class="text-right">처리자</th>
						<td>
							<input type="text" class="form-control width140px" id="proc_mem_name" name="proc_mem_name" readonly="readonly" value="${result.proc_mem_name}">
							<input type="hidden" id="proc_mem_no" name="proc_mem_no" value="${result.proc_mem_no}">
						</td>
					</tr>
					<tr>
						<th class="text-right">차대번호</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0 width240px" id="body_no" name="body_no" value="${result.body_no}">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchDeviceHisPanel('fnSetDeviceHis');"><i class="material-iconssearch"></i></button>
							</div>
						</td>
						<th class="text-right">장비명</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-auto">
									<input type="text" class="form-control width140px" readonly="readonly" id="machine_name" name="machine_name" value="${result.machine_name}">
								</div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:fixInfo()">수리내역</button>
								</div>
							</div>
						</td>
						<th class="text-right">출고일자</th>
						<td>
							<input type="text" class="form-control width140px" readonly="readonly" id="out_dt" name="out_dt" dateFormat="yyyy-MM-dd" value="${result.out_dt}">
						</td>
						<th class="text-right">처리일시</th>
						<td>
							<fmt:formatDate value="${result.proc_date}" pattern="yyyy-MM-dd" var="proc_dt"/>
							<input type="text" class="form-control width140px" name="proc_date" id="proc_date" value="${proc_dt}" readonly="readonly">
						</td>
					</tr>
					<tr>
						<th class="text-right">접수내용</th>
						<td colspan="7">
							<textarea style="height: 100px;" id="req_memo" name="req_memo" required="required" alt="접수내용">${result.req_memo}</textarea>
						</td>
					</tr>
					<tr>
						<th class="text-right">처리내용</th>
						<td colspan="7">
							<textarea style="height: 100px;"id="resp_memo" name="resp_memo" required="required" alt="처리내용">${result.resp_memo}</textarea>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
</form>
</body>
</html>