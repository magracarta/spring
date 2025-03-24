<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 일일현황판 > 일일현황판 상세
-- 작성자 : 정선경
-- 최초 작성일 : 2023-04-28 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function(){
			if (${empty result}) {
				alert("업무스케쥴 내용이 존재하지 않습니다. 확인 후 처리해주세요.");
				opener.goSearch();
				fnClose();
			}
			// 수정권한에 따른 버튼 노출
			if (${result.edit_yn eq 'Y'}) {
				$("#_goModify").show();
				// 삭제버튼 노출 여부 세팅
				if (${result.delete_yn eq 'Y'}) {
					$("#_goRemove").show();
				} else {
					$("#_goRemove").hide();
				}
			} else {
				$("#_goModify").hide();
				$("#_goRemove").hide();
			}
		});

		// 정비지시서 팝업
		function goJobReport(jobReportNo) {
			var param = {
				"s_job_report_no" : jobReportNo
			};
			$M.goNextPage("/serv/serv0101p01", $M.toGetParam(param), {popupStatus : ""});

			// 정비지시서 팝업 이동 후 일일현황상세 닫기
			fnClose();
		}

		// 저장
		function goModify() {
			var frm = document.main_form;

			// 입력폼 벨리데이션
			if($M.validation(frm) == false) {
				return false;
			}

			// 입력시간 체크
			if ($M.getValue("work_st_ti") >= $M.getValue("work_ed_ti")) {
				alert("종료시간은 시작시간 이후로 선택해주세요.");
				return false;
			}

			// 연속정비작업 업무일자, 정비입고일자 체크
			if ($M.getValue("day_board_type_cd") == "REPAIR_DAY" && $M.getValue("day_job_report_no") != "") {
				var dayInDt = $M.getValue("day_in_dt").replaceAll("-", "");
				if ($M.getValue("board_dt") <= dayInDt) {
					alert("연속정비작업 업무일자는 정비지시서 입고일자("+ $M.getValue("day_in_dt") +") 이후로 입력해주세요.");
					return false;
				}
			}


			// 일일현황 일정 중복체크 후 저장
			fnSaveBeforeCheckTime();
		}

		// 일일현황 시간 중복 체크
		function fnSaveBeforeCheckTime() {
			var param = {
				"day_board_seq": $M.getValue("day_board_seq"),
				"board_mem_no": $M.getValue("board_mem_no"),
				"board_dt": $M.getValue("board_dt"),
				"work_st_ti": $M.getValue("work_st_ti"),
				"work_ed_ti": $M.getValue("work_ed_ti")
			}

			$M.goNextPageAjax("/mmyy/mmyy0113p01/check/time", $M.toGetParam(param), {method : 'GET'},
					function(result) {
						if(result.success) {
							if (result.mem_work_yn == "N") {
								alert("근무 외 시간대입니다. 확인후 진행해주세요.");
								return false;
							}

							var msg = "";
							if (result.dup_yn == "Y") {
								msg = "해당 시간에 이미 지정된 작업이 설정되어 있습니다.\n";
							}
							msg += "수정하시겠습니까?";

							if (confirm(msg) == false) {
								return false;
							}
							fnSave();
						}
					}
			);
		}

		// 저장
		function fnSave() {
			var frm = document.main_form;
			$M.goNextPageAjax(this_page + "/modify", $M.toValueForm(frm) , {method : 'POST'},
					function(result) {
						if(result.success) {
							opener.goSearch();
							location.reload();
						}
					}
			);
		}

		// 삭제
		function goRemove() {
			if ($M.getValue("job_report_no") != "") {
				alert("정비업무는 삭제가 불가능합니다.");
				return false;
			}

			var frm = document.main_form;
			var msg = "삭제하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/remove", $M.toValueForm(frm) , {method : 'POST'},
					function(result) {
						if(result.success) {
							opener.goSearch($M.getValue("board_org_code"), $M.getValue("board_dt"));
							fnClose();
						}
					}
			);
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 시간포맷 세팅
		function fnSetHHmm(tiVal) {
			if (tiVal == null || tiVal == "") {
				tiVal = "0000";
			}

			if (tiVal.length == 4) {
				tiVal = tiVal.substr(0, 2) + ":" + tiVal.substr(2, 2);
			}

			return tiVal
		}
	</script>
</head>
<body class="bg-white" >
<form id="main_form" name="main_form">
	<input type="hidden" name="day_board_seq" value="${result.day_board_seq}">
	<input type="hidden" name="board_org_code" value="${result.board_org_code}">
	<input type="hidden" name="day_board_type_cd" value="${result.day_board_type_cd}">
	<input type="hidden" name="day_board_type_name" value="${result.day_board_type_name}">
	<input type="hidden" name="deal_mon" value="${result.deal_mon}">
	<input type="hidden" name="cust_no" value="${result.cust_no}">
	<input type="hidden" name="stat_mon" value="${result.stat_mon}">
	<input type="hidden" name="machine_seq" value="${result.machine_seq}">
	<input type="hidden" name="as_todo_seq" value="${result.as_todo_seq}">
	<input type="hidden" name="rental_doc_no" value="${result.rental_doc_no}">
	<input type="hidden" name="job_report_no" value="${result.job_report_no}">
	<input type="hidden" name="day_job_report_no" value="${result.day_job_report_no}">
	<input type="hidden" name="day_in_dt" value="${result.day_in_dt}">
	<input type="hidden" name="day_cnt" value="${result.day_cnt}">

	<div class="popup-wrap width-100per">
		<!-- contents 전체 영역 -->
		<div class="content-wrap" style="padding: 0">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /메인 타이틀 -->
			<div class="content-wrap">
				<div>
					<div class="title-wrap">
						<div class="left">
							<h4>업무스케쥴상세</h4>
						</div>
					</div>
					<!-- 폼테이블 -->
					<div>
						<table class="table-border mt5">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="90px">
								<col width="130px">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right essential-item">제목</th>
								<td colspan="3">
									<input type="text" class="form-control essential-bg" id="title" name="title" alt="제목" maxlength="200" required="required" value="${result.title}">
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">일자</th>
								<td colspan="3">
									<div class="input-group width120px">
										<input type="text" class="form-control border-right-0 calDate essential-bg" id="board_dt" name="board_dt" dateFormat="yyyy-MM-dd" value="${result.board_dt}" alt="지정일자">
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">업무시간</th>
								<td colspan="3">
									<div class="form-row inline-pd">
										<div class="col-auto text-center">시작시간</div>
										<div class="col-auto">
											<select class="form-control width120px essential-bg" id="work_st_ti" name="work_st_ti" required="required" alt="업무시작시간">
												<option value="">- 선택 -</option>
												<c:forEach var="item" items="${st_ti_list}">
													<option value="${item.code_value}" ${item.code_value == result.work_st_ti ? 'selected' : ''}>${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto text-center">종료시간</div>
										<div class="col-auto">
											<select class="form-control width120px essential-bg" id="work_ed_ti" name="work_ed_ti" required="required" alt="업무종료시간">
												<option value="">- 선택 -</option>
												<c:forEach var="item" items="${ed_ti_list}">
													<option value="${item.code_value}" ${item.code_value == result.work_ed_ti ? 'selected' : ''}>${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">업무참조</th>
								<td colspan="3">
									<div class="form-row inline-pd">
										<div class="${not empty result.job_report_no? 'col-9' : 'col-12'}">
											<input type="text" class="form-control" id="work_ref_text" name="work_ref_text" readonly value="${result.work_ref_text}">
										</div>
										<c:if test="${not empty result.job_report_no}">
											<div class="col-3">
												<button type="button" class="btn btn-primary-gra" name="btnGoJobReport" onclick="javascript:goJobReport('${result.job_report_no}');">정비지시서 이동</button>
											</div>
										</c:if>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">연속정비작업</th>
								<td colspan="3">
									<div class="form-row inline-pd">
										<div class="${not empty result.day_job_report_no? 'col-9' : 'col-12'}">
											<select class="form-control" id="day_job_report_no" name="day_job_report_no" alt="연속정비지시서" readonly>
												<option value=""></option>
												<c:forEach var="item" items="${job_report_list}">
													<option value="${item.job_report_no}" ${item.job_report_no == result.day_job_report_no ? 'selected' : ''}>${item.day_board_type_name} | ${item.title}</option>
												</c:forEach>
											</select>
											<input type="hidden" id="in_dt" name="in_dt">
										</div>
										<c:if test="${not empty result.day_job_report_no}">
											<div class="col-3">
												<button type="button" class="btn btn-primary-gra" name="btnGoJobReport" onclick="javascript:goJobReport('${result.day_job_report_no}');">정비지시서 이동</button>
											</div>
										</c:if>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">원담당자</th>
								<td colspan="${not empty result.job_report_no? '' : '3'}">
									<input type="text" class="form-control width120px readonly" id="origin_mem_name" name="origin_mem_name" alt="원담당자" readonly value="${result.origin_mem_name}">
									<input type="hidden" id="origin_mem_no" name="origin_mem_no" value="${result.origin_mem_no}">
								</td>
								<c:if test="${not empty result.job_report_no}">
									<th class="text-right">예상정비시간</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-auto">
												<input type="text" class="form-control width80px readonly" id="except_repair_hour" name="except_repair_hour" alt="예상정비시간" readonly value="${result.except_repair_hour}">
											</div>
											<div class="col-auto text-center">hr</div>
										</div>
									</td>
								</c:if>
							</tr>
							<tr>
								<th class="text-right essential-item">지정담당자</th>
								<td colspan="3">
									<input type="text" class="form-control width120px readonly" id="board_mem_name" name="board_mem_name" alt="지정담당자" readonly value="${result.board_mem_name}" required="required">
									<input type="hidden" id="board_mem_no" name="board_mem_no" value="${result.board_mem_no}">
								</td>
							</tr>
							<tr>
								<th class="text-right">비고</th>
								<td colspan="3">
									<textarea class="form-control" style="height: 100px;" id="remark" name="remark" maxlength="300">${result.remark}</textarea>
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
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>