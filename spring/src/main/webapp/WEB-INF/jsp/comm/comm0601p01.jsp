<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 근무관리 > 부서근로시간정산표 > null > 근로시간조정신청서
-- 작성자 : 성현우
-- 최초 작성일 : 2020-03-27 09:24:19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function () {
			fnInit();
		});

		// 저장
		function goSave(isRequestAppr) {
			var frm = document.main_form;

			//validationcheck
			if($M.validation(frm)==false) {
				return;
			};

			if($M.getValue("mem_no") != '${SecureUser.mem_no}') {
				alert("결재요청 및 저장은 본인만 할 수 있습니다.");
				return;
			}

			if(isRequestAppr != undefined) {
				$M.setValue("save_mode", "appr"); // 결재요청
				if(confirm("결재요청 하시겠습니까?") == false) {
					return false;
				}
			} else {
				$M.setValue("save_mode", "save"); // 저장
				if(confirm("저장하시겠습니까?") == false) {
					return false;
				}
			}

			$M.goNextPageAjax(this_page + "/save", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("처리가 완료되었습니다.");
						location.reload();
					}
				}
			)
		}

		function fnInit() {
			var apprProcStatusCd = "${result.appr_proc_status_cd}";
			if(apprProcStatusCd != "00" && apprProcStatusCd != "01") {
				$("#adjust_time").prop("disabled", true);
				$("#adjust_remark").prop("disabled", true);
			}

			if(apprProcStatusCd == "00") {
				$("#_goApproval").addClass("dpn");
			}
		}

		// 결재요청
		function goRequestApproval() {
			console.log("mem_no : " + $M.getValue("mem_no"));
			console.log("SecureUser.mem_no : " + '${SecureUser.mem_no}');

			if($M.getValue("appr_proc_status_cd") == "03") {
				alert("이미 결재요청을 했습니다.");
				return;
			}
			goSave('requestAppr');
		}

		// 결재처리
		function goApproval() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}"
			};
			$M.setValue("save_mode", "approval"); // 승인
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}

		// 결재처리 결과
		function goApprovalResult(result) {
			console.log(result);
			if(result.appr_status_cd == "03") {
				$M.goNextPageAjax('/session/check', '', {method : 'GET'},
						function(result) {
							if(result.success) {
								alert("반려가 완료되었습니다.");
								location.reload();
							}
						}
				);
			} else if (result.appr_status_cd == '04') {
				$M.goNextPageAjax('/session/check', '', {method : 'GET'},
						function(result) {
							if(result.success) {
								alert("결재취소가 완료됐습니다.");
								location.reload();
							}
						}
				);
			} else {
				$M.goNextPageAjax('/session/check', '', {method : 'GET'},
						function(result) {
							if(result.success) {
								alert("처리가 완료되었습니다.");
								location.reload();
							}
						}
				);
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
<input type="hidden" id="save_mode" name="save_mode"> <!-- appr(결재요청 후 저장), save(저장) -->
<input type="hidden" id="mem_work_mon_seq" name="mem_work_mon_seq" value="${result.mem_work_mon_seq}">
<input type="hidden" id="mem_no" name="mem_no" value="${result.mem_no}">
<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${result.appr_proc_status_cd}">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${result.appr_job_seq}">
<div class="popup-wrap width-100per">
	<!-- 메인 타이틀 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"></jsp:include>
	</div>
	<!-- /메인 타이틀 -->
	<div class="content-wrap">
		<div class="title-wrap half-print" style="min-width: 1000px;">
			<div class="doc-info" style="flex: 1;">
				<h4>근로시간조정신청서</h4>
			</div>
			<!-- 결재영역 -->
			<div class="p10" style="margin-left: 10px;">
				<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
			</div>
			<!-- /결재영역 -->
		</div>
		<table class="table-border mt10">
			<colgroup>
				<col width="140px">
				<col width="">
				<col width="140px">
				<col width="">
				<col width="140px">
				<col width="">
			</colgroup>
			<tbody>
			<tr>
				<th class="text-right">근무일수</th>
				<td>
					<div class="form-row inline-pd widthfix">
						<div class="col width60px">
							<input type="text" class="form-control text-right" id="work_day" name="work_day" readonly="readonly" value="${result.work_day}">
						</div>
						<div class="col width28px">
							일
						</div>
					</div>
				</td>
				<th class="text-right">근무시간</th>
				<td colspan="3">
					<div class="form-row inline-pd widthfix">
						<div class="col width60px">
							<input type="text" class="form-control text-right" id="plan_work_time" name="plan_work_time" readonly="readonly" value="${result.plan_work_time}">
						</div>
						<div class="col width28px">
							시간
						</div>
					</div>
				</td>
			</tr>
			<tr>
				<th class="text-right">월 근로시간</th>
				<td>
					<div class="form-row inline-pd widthfix">
						<div class="col width60px">
							<input type="text" class="form-control text-right" id="work_time" name="work_time" readonly="readonly" value="${result.work_time}">
						</div>
						<div class="col width28px">
							시간
						</div>
					</div>
				</td>
				<th class="text-right">월 연장근로시간</th>
				<td>
					<div class="form-row inline-pd widthfix">
						<div class="col width60px">
							<input type="text" class="form-control text-right" id="add_work_time" name="add_work_time" readonly="readonly" value="${result.add_work_time}">
						</div>
						<div class="col width28px">
							시간
						</div>
					</div>
				</td>
				<th class="text-right">초과(+) / 미달(-)근로시간</th>
				<td>
					<div class="form-row inline-pd widthfix">
						<div class="col width60px">
							<input type="text" class="form-control text-right" id="result_work_time" name="result_work_time" readonly="readonly" value="${result.result_work_time}">
						</div>
						<div class="col width28px">
							시간
						</div>
					</div>
				</td>
			</tr>
			<tr>
				<th class="text-right">조정요청시간</th>
				<td colspan="5">
					<div class="form-row inline-pd widthfix">
						<div class="col width60px">
							<input type="text" class="form-control text-right" id="adjust_time" name="adjust_time" value="${result.adjust_time}">
						</div>
						<div class="col width28px">
							시간
						</div>
					</div>
				</td>
			</tr>
			<tr>
				<th class="text-right">사유</th>
				<td colspan="5">
					<textarea class="form-control" placeholder="근무시간 조정을 요청합니다." style="height: 70px;" id="adjust_remark" name="adjust_remark">${result.adjust_remark}</textarea>
				</td>
			</tr>
			<tr>
				<th class="text-right">결재의견</th>
				<td colspan="5">
					<div class="fixed-table-container" style="width: 100%; height: 100px;"> <!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
						<div class="fixed-table-wrapper">
							<table class="table-border doc-table md-table">
								<colgroup>
									<col width="40px">
									<col width="140px">
									<col width="55px">
									<col width="">
								</colgroup>
								<thead>
								<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
								<tr><th class="th" style="font-size: 12px !important">구분</th>
									<th class="th" style="font-size: 12px !important">결재일시</th>
									<th class="th" style="font-size: 12px !important">담당자</th>
									<th class="th" style="font-size: 12px !important">특이사항</th>
								</tr></thead>
								<tbody>
								<c:forEach var="list" items="${apprMemoList}">
									<tr>
										<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
										<td class="td" style="font-size: 12px !important">${list.proc_date }</td>
										<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
										<td class="td" style="font-size: 12px !important">${list.memo }</td>
									</tr>
								</c:forEach>
								</tbody>
							</table>
						</div>
					</div>
				</td>
			</tr>
			</tbody>
		</table>
		<div class="btn-group mt10">
			<div class="right">
				<c:choose>
					<c:when test="${result.appr_proc_status_cd ne '00'}">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/><jsp:param name="appr_yn" value="Y"/></jsp:include>
					</c:when>
					<c:otherwise>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</c:otherwise>
				</c:choose>
			</div>
		</div>
	</div>
</div>
</form>
</body>
</html>