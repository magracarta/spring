<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 일일현황판 > 일일현황판 등록
-- 작성자 : 정선경
-- 최초 작성일 : 2023-04-28 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function(){
			// 목록 본창이 아닌 업무리스트 팝업에서 들어온 경우
			if('${inputParam.list_yn}' == 'Y') {
				$("#board_dt").prop("disabled", false);
				$("#board_mem_no").removeAttr("readonly");
				// map하나
				if(${not empty inputParam.list_data}) {
					var list = "${inputParam.list_data}".split("##?");
					var data = {};
					list.forEach(str => {
						if(str != "") {
							var keyValue = str.split("?|#");
							data[keyValue[0]] = keyValue[1];
						}
					});
					fnSetWortRefInfo(data);
				}
			}
		});

		// 업무참조 팝업
		function goWorkRefPop() {
			var param = {
				"board_org_code": $M.getValue("board_org_code"),
				"board_dt": $M.getValue("board_dt"),
				"parent_js_name": "fnSetWortRefInfo"
			};
			$M.goNextPage("/mmyy/mmyy0113p0101", $M.toGetParam(param), {popupStatus : ""});
		}

		// 업무참조 정보 세팅
		function fnSetWortRefInfo(data) {
			var title = data.cust_name
							+ (data.machine_name? " | "+data.machine_name : "")
							+ (data.body_no? " | "+data.body_no : "");
			$M.setValue("title", title);
			$M.setValue("work_ref_text", data.day_board_type_name + " | "  + title);
			$M.setValue("day_board_type_cd", data.day_board_type_cd);
			$M.setValue("day_board_type_name", data.day_board_type_name);
			$M.setValue("cust_no", data.cust_no);
			$M.setValue("stat_mon", data.stat_mon);
			$M.setValue("machine_seq", data.machine_seq);
			$M.setValue("as_todo_seq", data.as_todo_seq);
			$M.setValue("rental_doc_no", data.rental_doc_no);
			$M.setValue("origin_mem_no", data.origin_mem_no);
			$M.setValue("origin_mem_name", data.origin_mem_name);
			$M.setValue("cap_cnt", data.cap_cnt);
			$M.setValue("area_name", data.area_name);
			$M.setValue("todo_text", data.todo_text);
			$M.setValue("job_report_no", data.job_report_no);
			$M.setValue("day_job_report_no", "");
		}

		// 연속 정비작업 참조 변경
		function fnChangeJobReport(jobReportNo) {
			fnClearWorkRef();
			var title = "";
			if (jobReportNo != "") {
				var jobReportList = ${jobReportList};
				for (var i=0; i<jobReportList.length; i++) {
					if (jobReportList[i].job_report_no == jobReportNo) {
						title = jobReportList[i].day_board_type_name + " | " + jobReportList[i].title;
						break;
					}
				}
				$("#btnWorkRefPop").attr("disabled", true);
			} else {
				$("#btnWorkRefPop").attr("disabled", false);
			}
			$M.setValue("title", title);
		}

		function fnClearWorkRef() {
			$M.setValue("title", "");
			$M.setValue("day_board_type_cd", "");
			$M.setValue("work_ref_text", "");
			$M.setValue("cust_no", "");
			$M.setValue("stat_mon", "");
			$M.setValue("machine_seq", "");
			$M.setValue("as_todo_seq", "");
			$M.setValue("rental_doc_no", "");
			$M.setValue("job_report_no", "");
			$M.setValue("origin_mem_no", "");
			$M.setValue("origin_mem_name", "");
			$M.setValue("cap_cnt", "");
			$M.setValue("area_name", "");
			$M.setValue("todo_text", "");
		}

		// 시간중복 체크 후 저장
		function goSave() {
			var frm = document.main_form;

			// 입력폼 벨리데이션
			if($M.validation(frm) == false) {
				return;
			}

			// 입력시간 체크
			if ($M.getValue("work_st_ti") >= $M.getValue("work_ed_ti")) {
				alert("종료시간은 시작시간 이후로 선택해주세요.");
				return false;
			}

			// 일일현황 일정 중복체크 후 저장
			fnSaveBeforeCheckTime();
		}

		// 일일현황 시간 중복 체크
		function fnSaveBeforeCheckTime() {
			var param = {
				"board_mem_no": $M.getValue("board_mem_no"),
				"board_dt": $M.getValue("board_dt"),
				"work_st_ti": $M.getValue("work_st_ti"),
				"work_ed_ti": $M.getValue("work_ed_ti")
			}

			$M.goNextPageAjax(this_page + "/check/time", $M.toGetParam(param), {method : 'GET'},
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
							msg += "저장하시겠습니까?";

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
			$M.goNextPageAjax(this_page + "/save", $M.toValueForm(frm) , {method : 'POST'},
					function(result) {
						if(result.success) {
							// 목록 본창이 아닌 업무리스트 팝업에서 들어온 경우
							if('${inputParam.list_yn}' == 'Y') {
								opener.goSearch();
							} else {
								opener.goSearch($M.getValue("board_org_code"), $M.getValue("board_dt"));
							}
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

		// 지정담당자 변경한 경우 연속정비작업 변경
		function fnChangeBoardMem() {
			var param = {
				"board_mem_no" : $M.getValue("board_mem_no"),
				"board_dt" : $M.getValue("board_dt")
			}

			$M.goNextPageAjax(this_page + "/job_report_list", $M.toGetParam(param) , {method : 'GET'},
					function(result) {
						if(result.success) {
							$("select#day_job_report_no option").remove();
							$('#day_job_report_no').append('<option value="">' + "- 전체 -" + '</option>');

							result.job_report_list.forEach(data => {
								const value = data.ms_maker_cd;
								const text = data.day_board_type_name + data.job_report_no;
								$('#day_job_report_no').append('<option value="' + value + '">' + text + '</option>');
							});
						} else {

						}
					}
			);
		}
	</script>
</head>
<body class="bg-white" >
<form id="main_form" name="main_form">
	<input type="hidden" name="board_org_code" value="${inputParam.board_org_code}">
	<input type="hidden" name="day_board_type_cd" value="">
	<input type="hidden" name="day_board_type_name" value="">
	<input type="hidden" name="deal_mon" value="">
	<input type="hidden" name="cust_no" value="">
	<input type="hidden" name="stat_mon" value="">
	<input type="hidden" name="machine_seq" value="">
	<input type="hidden" name="as_todo_seq" value="">
	<input type="hidden" name="rental_doc_no" value="">
	<input type="hidden" name="job_report_no" value="">
	<input type="hidden" name="cap_cnt" value="">
	<input type="hidden" name="area_name" value="">
	<input type="hidden" name="todo_text" value="">

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
							<h4>업무스케쥴등록</h4>
						</div>
					</div>
					<!-- 폼테이블 -->
					<div>
						<table class="table-border mt5">
							<colgroup>
								<col width="110px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right essential-item">제목</th>
								<td>
									<input type="text" class="form-control essential-bg" id="title" name="title" alt="제목" maxlength="200" required="required">
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">일자</th>
								<td>
									<div class="input-group width120px">
										<input type="text" class="form-control border-right-0 calDate" id="board_dt" name="board_dt" dateFormat="yyyy-MM-dd" value="${inputParam.board_dt}" alt="지정일자" onchange="javascript:fnChangeBoardMem();"
											   required="required" <c:if test="${not empty inputParam.board_dt}">disabled="disabled"</c:if>>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">업무시간</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto text-center">시작시간</div>
										<div class="col-auto">
											<select class="form-control width120px ${not empty inputParam.work_st_ti? '' : 'essential-bg'}" id="work_st_ti" name="work_st_ti" required="required" alt="업무시작시간"
													<c:if test="${not empty inputParam.work_st_ti}">readonly</c:if>>
												<option value="">- 선택 -</option>
												<c:forEach var="item" items="${st_ti_list}">
													<option value="${item.code_value}" ${item.code_value == inputParam.work_st_ti ? 'selected' : ''}>${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto text-center">종료시간</div>
										<div class="col-auto">
											<select class="form-control width120px essential-bg" id="work_ed_ti" name="work_ed_ti" required="required" alt="업무종료시간">
												<option value="">- 선택 -</option>
												<c:forEach var="item" items="${ed_ti_list}">
													<option value="${item.code_value}" ${item.code_value == inputParam.work_ed_ti ? 'selected' : ''}>${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">업무참조</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-10">
											<input type="text" class="form-control" id="work_ref_text" name="work_ref_text" readonly="readonly">
										</div>
										<div class="col-2">
											<button type="button" class="btn btn-primary-gra" id="btnWorkRefPop" name="btnWorkRefPop" onclick="javascript:goWorkRefPop();" >업무참조</button>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">연속정비작업</th>
								<td>
									<select class="form-control" id="day_job_report_no" name="day_job_report_no" alt="연속정비지시서" onchange="javascript:fnChangeJobReport(this.value);">
										<option value="">- 선택 -</option>
										<c:forEach var="item" items="${job_report_list}">
											<option value="${item.job_report_no}">${item.day_board_type_name} | ${item.title}</option>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<th class="text-right">원담당자</th>
								<td>
									<input type="text" class="form-control width120px readonly" id="origin_mem_name" name="origin_mem_name" alt="원담당자" readonly>
									<input type="hidden" id="origin_mem_no" name="origin_mem_no">
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">지정담당자</th>
								<td>
									<select class="form-control width120px" id="board_mem_no" name="board_mem_no" alt="지정담당자" required="required" onchange="javascript:fnChangeBoardMem();"
											<c:if test="${not empty inputParam.board_mem_no}">readonly</c:if>>
										<option value="">- 선택 -</option>
										<c:forEach var="item" items="${mem_list}">
											<option value="${item.mem_no}" ${item.mem_no == inputParam.board_mem_no ? 'selected' : ''}>${item.mem_name}</option>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<th class="text-right">비고</th>
								<td>
									<textarea class="form-control" style="height: 100px;" id="remark" name="remark" maxlength="300"></textarea>
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