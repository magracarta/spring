<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 개인고과평가 > 고과평가상세 > 인사고과
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-01 10:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		.aui-status-disable {
			background-color: #eee;
			color : black;
			text-align: left !important;
			vertical-align: middle !important;
		}
		.aui-status-disable:hover > td {
			background-color:#FFFACD !important;
			color:#000 !important;
		}
	</style>
	<script type="text/javascript">

		/**
		 * 저장 가능 여부<br>
		 * 저장 가능 조건 : 현재년도 / 권한보유자 / 작성중
		 */
		var canModify;

		// 현재 날짜가 연봉종료일자로부터 한달 이내 여부
		var isWithinOneMonth = ${isWithinOneMonth};
		var hasAuth = ${hasAuth}; // 저장 권한 보유 여부
		var isCurrentYear; // 저장가능한 년도 여부
		var auiGridAbility; // 취득사항 그리드
		var auiGridAwardAndPenalty; // 상벌사항 그리드

		var abilityList = ${abilityList};

		$(document).ready(function() {
			createAUIGridAbility();
			createAUIGridAwardAndPenalty();
			goSearch();
			fnInit();
		});

		// 페이지 진입 시 세팅
		function fnInit() {
			// 최종평점은 25점을 넘을 수 없음
			document.getElementById("total_eval_point").addEventListener('blur', (event) => {
				let value = parseInt((event.target.value).replace('\,', ''));
				let maxPoint = 100;
				if (!isNaN(value) && value > maxPoint) {
					alert("최종 평점은 " + maxPoint + "점을 넘을 수 없습니다.");
					event.target.value = maxPoint;
				}
			});
		}

        // 결재요청
		function goRequestApproval() {
			// 결재요청 시 필수항목 체크
			if ($M.validation(document.main_form) == false) {
				return;
			}
			goModify(true);
		}

		// 결재취소
		function goApprCancel() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}",
				appr_cancel_yn : "Y"
			};
			openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
		}

		// 결재취소 callback
		function goApprovalResultCancel(result) {
			$M.goNextPageAjax('/session/check', '', {method : 'GET'}, (result) => {
				if (result.success) {
					alert("결재취소가 완료됐습니다.");
					location.reload();
				}
			});
		}

		// 결재처리
		function goApproval() {
			var param = {
				appr_job_seq: "${apprBean.appr_job_seq}",
				seq_no: "${apprBean.seq_no}"
			};
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}

		// 결재처리 결과 callback
		function goApprovalResult(result) {
			// 반려이면 페이지 리로딩
			if (result.appr_status_cd == '03') {
				$M.goNextPageAjax('/session/check', '', {method: 'GET'},
						function (result) {
							if (result.success) {
								alert("반려가 완료되었습니다.");
								location.reload();
							}
						}
				);
			} else {
				// 결재 승인 후처리
				setTimeout(function() {
					$M.setValue("save_mode", "approval"); // 승인
					var frm = $M.toValueForm(document.main_form);
					$M.goNextPageAjax(this_page + "/modify", frm, {method: "POST"}, (result) => {
						if (result.success) {
							window.location.reload();
						}
					});
				}, 600);
			}
		}

		/**
		 * 저장 / 결재요청
		 * @param {boolean} isRequestAppr 결재요청 여부
		 */
		function goModify(isRequestAppr) {
			var msg = "";

			if (isRequestAppr) {
				$M.setValue("save_mode", "appr");
				msg = "결재요청 하시겠습니까?";
			} else {
				$M.setValue("save_mode", "save");
				msg = "저장 하시겠습니까?";
			}

			if (!confirm(msg)) {
				return false;
			}

			if (!fnValidateAbility()) {
				fnAjaxModify(isRequestAppr);
			} else {
				// 취득사항 파라미터
				var param = fnMakeAbilityParam();
				param.show_result = false;

				$M.goNextPageAjax(this_page + "/save/ability", $M.toGetParam(param), {method : "POST"}, (result) => {
					if (result.success) {
						fnAjaxModify(isRequestAppr);
					}
				});
			}

			function fnAjaxModify(isRequestAppr) {
				var frm = $M.toValueForm(document.main_form);
				$M.goNextPageAjax(this_page + "/modify", frm, {method: "POST"}, (result) => {
					if (result.success) {
						if (isRequestAppr) {
							window.location.reload();
						} else {
							goSearch();
						}
					}
				});
			}
		}

		// 닫기
		function fnClose() {
			top.window.close();
		}

		// 상벌사항 그리드 생성
		function createAUIGridAwardAndPenalty() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
			};

			var columnLayout = [
				{
					headerText: "반영일자",
					dataField: "apply_dt",
					width: "100",
					style: "aui-center",
					dataType: "date",
					formatString: "yyyy-mm-dd",
				},
				{
					headerText: "구분",
					dataField: "gubun_name",
					width: "70",
					style: "aui-center",
				},
				{
					headerText: "등급",
					dataField: "grade_name",
					width: "100",
					style: "aui-center",
				},
				{
					headerText: "속성",
					dataField: "prop_val",
					width: "100",
					style: "aui-right",
					dataType: "numeric",
					formatString: "#,###",
				},
				{
					headerText: "비고",
					dataField: "remark",
					style: "aui-left",
				},
				{
					headerText: "사유서",
					dataField: "doc_file_seq",
					width: "70",
					renderer : {
						type : "TemplateRenderer"
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						var html = '';
						html += '<div>';
						html += 	'<a href="javascript:fileDownload(' + value + ');" style="color: blue;">사유서</a>&nbsp;';
						html += '</div>';
						return value ? html : '';
					},
				},
			];

			auiGridAwardAndPenalty = AUIGrid.create("#auiGridAwardAndPenalty", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridAwardAndPenalty, []);
			$("#auiGridAwardAndPenalty").resize();
		}

		// 취득사항 그리드 생성
		function createAUIGridAbility() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
				editable: true,
				showStateColumn : true,
			};

			var columnLayout = [
				{
					headerText: "취득일자",
					dataField: "last_proc_dt",
					width: "120",
					style: "aui-center",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					editable: false,
					headerTooltip: {
						show: true,
						tooltipHtml: "자격취득신청의 결재완료 일자"
					}
				},
				{
					headerText: "취득자격",
					dataField: "hr_code_ability_seq",
					style: "aui-left",
					editRenderer: {
						type: "DropDownListRenderer",
						list: ${filteredAbilityList},
						listAlign: "left", // 왼쪽정렬
						required: false,
						keyField: 'hr_code_ability_seq',
						valueField: 'ability_name',
					},
					labelFunction: function(rowIndex, columnIndex, value, headerText, item) {
						return abilityList
								.filter(obj => Number(obj.hr_code_ability_seq) === Number(value))
								.map(obj => obj.ability_name)[0];
					},
					styleFunction: function(rowIndex, columnIndex, value, headerText, item, dataField) {
						// 능력이 아닌 경우 편집 불가
						if (item.hr_ability_cd !== '01') {
							return "aui-status-disable";
						}
						return "aui-left";
					},
				},
				{
					headerText: "금액",
					dataField: "ability_amt",
					width: "100",
					style: "aui-right",
					dataType: "numeric",
					formatString: "#,###",
					editable: false,
				},
				{
					headerText: "금액반영",
					dataField: "salary_apply_yn",
					width: "80",
					style: "aui-center",
					editable: false,
					renderer: {
						type: "CheckBoxEditRenderer",
						editable: true,
						checkValue: "Y",
						unCheckValue: "N"
					},
				},
				{
					dataField: "hr_ability_cd",
					visible: false,
				},
				{
					dataField: "doc_no",
					visible: false,
				}
			];

			auiGridAbility = AUIGrid.create("#auiGridAbility", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridAbility, []);
			$("#auiGridAbility").resize();

			AUIGrid.bind(auiGridAbility, "cellEditBegin", (event) => {
				// 취득자격 편집 바인딩
				if (event.dataField === "hr_code_ability_seq") {
					// 능력 이외는 수정 불가
					if (event.item.hr_ability_cd !== '01') {
						return false;
					}
				}
			});

			AUIGrid.bind(auiGridAbility, "cellEditEnd", (event) => {
				// 취득자격(능력) 세팅 시 금액 및 시퀀스 반영
				if (event.dataField === "hr_code_ability_seq") {
					var data = abilityList.find(obj => obj.hr_code_ability_seq == event.value);
					AUIGrid.setCellValue(auiGridAbility, event.rowIndex, "ability_amt", data.ability_amt);
					AUIGrid.setCellValue(auiGridAbility, event.rowIndex, "hr_code_ability_seq", data.hr_code_ability_seq);
					fnSetAmt();
				}
				// 금액반영여부 수정 시 고과결과 취득사항 반영
				else if (event.dataField === "salary_apply_yn") {
					fnSetAmt();
				}
			});
		}

		// 해당년도 하단 고과결과 세팅
		function fnSetAmt() {
			// 취득사항 산출
			var abilityAmt = AUIGrid.getGridData(auiGridAbility)
					.filter(row => row.salary_apply_yn === 'Y')
					.map(row => row.ability_amt)
					.reduce((a, b) => a + b, 0);
			$("#ability_amt").text($M.numberFormat(abilityAmt));

			var baseAmt = Number($M.getValue("base_salary_amt").replaceAll("\,", "")); // 기본
			var abAmt = Number(abilityAmt); // 취득
			var apAmt = Number($M.getValue("award_penalty_amt").replaceAll("\,", "")); // 상벌사항

			// 합계 산출
			var totalAmt = baseAmt + abAmt + apAmt;
			$("#total_amt").text($M.numberFormat(totalAmt));
		}

		// 조회
		function goSearch() {
			var params = {
				"s_eval_year": $M.getValue("s_eval_year"),
				"s_mem_no": $M.getValue("s_mem_no"),
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: "GET"}, (result) => {
				if (result.success) {
					// 작성 가능 여부 세팅
					isCurrentYear = result.isCurrentYear;
					var isWriting = $M.getValue("appr_proc_status_cd") == 1;
					canModify = hasAuth && isCurrentYear && isWriting;

					fnSetBtn();
					fnSetQtrEvalData(result.qtrEvalMap);
					fnSetMemResultData(result.evalResultMap)
					// 상벌사항 데이터 세팅
					AUIGrid.setGridData(auiGridAwardAndPenalty, result.awardAndPenalty);
					// 취득사항 데이터 세팅
					AUIGrid.setGridData(auiGridAbility, result.hrAbilityList);
					fnSetAmt();

					// 근로계약서 세팅
					$("#btn_mng_salary").hide();
					$("#contract_info").hide();
					var salaryInfoMap = result.salaryInfoMap;
					$M.setValue("mem_year_salary_no", salaryInfoMap.mem_year_salary_no);
					// 계약완료일이 있을 경우 계약완료일 노출, 계약진행버튼 hide
					if (salaryInfoMap.upt_date) {
						$("#contract_info").show();
						$("#contract_ed_dt").text(salaryInfoMap.upt_date);
					} else if (isCurrentYear) {
						$("#btn_mng_salary").show();
					}
				}
			});
		}

		/**
		 * 하단 버튼 세팅
		 */
		function fnSetBtn() {
			// 저장 버튼 제어
			if (canModify) {
				$("#_goModify").removeClass("dpn");
			} else {
				$("#_goModify").addClass("dpn");
			}
			// 결재요청 버튼 제어
			if (canModify && isWithinOneMonth) {
				$("#_goRequestApproval").removeClass("dpn");
			} else {
				$("#_goRequestApproval").addClass("dpn");
			}
			// 결재취소 버튼 제어
			if (isCurrentYear && hasAuth) {
				$("#_goApprCancel").removeClass("dpn");
			} else {
				$("#_goApprCancel").addClass("dpn");
			}
			// 결재처리 버튼 제어
			if (isCurrentYear) {
				$("#_goApproval").removeClass("dpn");
			} else {
				$("#_goApproval").addClass("dpn");
			}
			// 작성중인 경우 버튼 제어
			var procStatusCd = $M.toNum($M.getValue("appr_proc_status_cd"));
			if (procStatusCd === 1) {
				$("#_goApprCancel").addClass("dpn");
				$("#_goApproval").addClass("dpn");
			}
		}

		/**
		 * 고과결과 데이터 세팅
		 * @param data Map
		 */
		function fnSetMemResultData(data) {
			// hidden input 존재 컬럼
			var hasInputCol = ['base_salary_amt', 'award_penalty_amt'];

			Object.keys(data).forEach(key => {
				var value = key.includes("eval_year") ? data[key] + "년" : data[key];
				var selector = $("#" + key);
				switch (selector.prop("tagName")) {
					case 'TH':
					case 'TD':
						selector.text(value);
						if (hasInputCol.includes(key)) {
							$M.setValue(key, value);
						}
						break;
					case 'INPUT':
						selector.val(value);
						break;
				}
			});
			// 현재년도 최종연봉 저장 가능 로직
			// 연봉협상 1개월 전, 작성 권한 보유, 현재년도
			$("#last_salary_amt").prop("readonly", !(hasAuth && isWithinOneMonth && isCurrentYear));
		}

		/**
		 * 분기 별 평가결과 데이터 세팅
		 * @param data
		 */
		function fnSetQtrEvalData(data) {
			if (data) {
				for (let i = 1; i <= 4; i++) {
					var prefix = "q" + String(i);
					var evalPointColName = prefix + "_eval_point";
					var remarkColName = prefix + "_remark";
					var evalPointCol = $("#" + evalPointColName);
					var remarkCol = $("#" + remarkColName);
					// set value
					evalPointCol.val(data[evalPointColName]);
					remarkCol.val(data[remarkColName]);
				}

				// 종합 평점 및 비고 세팅
				var totalEvalPointCol = $("#total_eval_point");
				var totalRemarkCol = $("#total_remark");
				totalEvalPointCol.val(data.total_eval_point);
				totalRemarkCol.val(data.total_remark);
				// set readonly according to auth
				totalEvalPointCol.prop("readonly", !canModify);
				totalRemarkCol.prop("readonly", !canModify);
			}
		}

		/**
		 * 계약진행 버튼 클릭 시 연봉관리 팝업 호출
		 * 결재완료 이후에 직원연봉 데이터가 자동생성 됨
		 */
		function goPopupMngSalary() {
			if ($M.getValue("appr_proc_status_cd") != "05") {
				alert("결재 완료 후 가능합니다.");
				return false;
			}

			var param = {
				mem_year_salary_no : $M.getValue("mem_year_salary_no"),
			};
			$M.goNextPage('/acnt/acnt0606p01', $M.toGetParam(param), {popupStatus : ""});
		}

		/**
		 * 취득사항 > 능력 행 추가
		 */
		function fnAddAbility() {
			if (!hasAuth) {
				alert("권한이 없습니다.");
				return false;
			}

			if (!isCurrentYear) {
				alert("현재 년도만 추가 및 저장할 수 있습니다.");
				return false;
			}

			var item = {
				"last_proc_dt" : "${inputParam.s_current_dt}",
				"ability_name" : "",
				"ability_amt" : "",
				"hr_ability_cd" : "01",
				"salary_apply_yn" : "N",
				"hr_code_ability_seq" : "",
			};
			AUIGrid.addRow(auiGridAbility, item, 'last');
		}

		/**
		 * 취득사항 > 능력 저장
		 */
		function fnSaveAbility() {
			if (!hasAuth) {
				alert("권한이 없습니다.");
				return false;
			}

			if (!isCurrentYear) {
				alert("현재 년도만 추가 및 저장할 수 있습니다.");
				return false;
			}

			var addData = AUIGrid.getAddedRowItems(auiGridAbility); // 추가내역
			var data = AUIGrid.getEditedRowItems(auiGridAbility); // 수정내역
			data = data.concat(addData);

			if (!fnValidateAbility()) {
				alert("저장 할 데이터가 없습니다.");
				return false;
			}

			var param = fnMakeAbilityParam();
			param.show_result = true;

			$M.goNextPageAjaxMsg("능력을 저장하시겠습니까?", this_page + "/save/ability", $M.toGetParam(param), {method : "POST"}, (result) => {
				if (result.success) {
					if (opener != null && opener.goSearch) {
						opener.goSearch();
					}
					goSearch();
				}
			});
		}

		/**
		 * 취득사항 그리드 validation
		 * @returns {boolean} 유효하면 true / 유효하지 않으면 false
		 */
		function fnValidateAbility() {
			var addData = AUIGrid.getAddedRowItems(auiGridAbility); // 추가내역
			var data = AUIGrid.getEditedRowItems(auiGridAbility); // 수정내역
			data = data.concat(addData);

			var notExistRow = data.length === 0;
			var notExistSelectedRow = data.filter(row => row.hr_code_ability_seq).length === 0;
			return !(notExistRow || notExistSelectedRow);
		}

		/**
		 * @returns {{doc_no_str, salary_apply_yn_str, hr_code_ability_seq_str}|null}
		 * 능력 저장에 필요한 파라미터, 그리드 값이 없을 경우 null return
		 */
		function fnMakeAbilityParam() {
			var docNoArr = [];
			var hrCodeAbilitySeqArr = [];
			var salaryApplyYnArr = [];
			var data = AUIGrid.getGridData(auiGridAbility);
			if (data.length === 0) {
				return null;
			}

			data.forEach(row => {
				docNoArr.push(row.doc_no);
				hrCodeAbilitySeqArr.push(row.hr_code_ability_seq);
				salaryApplyYnArr.push(row.salary_apply_yn);
			});

			var option = {
				isEmpty : true // 빈값 허용
			};

			return {
				"doc_no_str": $M.getArrStr(docNoArr, option),
				"hr_code_ability_seq_str": $M.getArrStr(hrCodeAbilitySeqArr, option),
				"salary_apply_yn_str": $M.getArrStr(salaryApplyYnArr, option),
				"s_mem_no" : $M.getValue("s_mem_no"),
			};
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="s_mem_no" name="s_mem_no" value="${memInfo.mem_no}"/>
	<input type="hidden" id="s_mem_name" name="s_mem_name" value="${memInfo.kor_name}"/>
	<input type="hidden" id="s_org_code" name="s_org_code" value="${memInfo.org_code}"/>
	<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${apprBean.appr_proc_status_cd}"/><!-- 결재진행상태 -->
	<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${appr_job_seq}"/> <!-- 업무결재번호 -->
	<input type="hidden" id="mem_result_eval_no" name="mem_result_eval_no" value="${mem_result_eval_no}" /> <!-- 직원인사고과번호 -->
	<input type="hidden" id="mem_year_salary_no" name="mem_year_salary_no" /> <!-- 계약진행 버튼 -->
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 조회조건 -->
		<div class="tabs-inner-line">
			<div class="boxing bd0 pd0 vertical-line mt5">
				<div class="tabs-search-wrap">
					<table class="table table-fixed">
						<colgroup>
							<col width="60px">
							<col width="80px">
							<col width="*">
						</colgroup>
						<tbody>
						<tr>
							<th>조회년도</th>
							<td>
								<select class="form-control" id="s_eval_year" name="s_eval_year" required="required" title="조회년도">
									<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
										<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
										<option value="${year_option}" <c:if test="${year_option eq inputParam.s_eval_year}">selected</c:if>>${year_option}년</option>
									</c:forEach>
								</select>
							</td>
							<td>
								<button type="button" class="btn btn-important ml5" style="width: 50px;" onclick="goSearch();">조회</button>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<!-- /조회조건 -->
		<!-- 분기 별 평가결과 -->
		<div>
			<div class="title-wrap mt5">
				<div class="left approval-left">
					<div style="width:200px;">
						<h4>분기 별 평가결과</h4>
					</div>
					<!-- 결재영역 -->
					<div class="p10" style="margin-left: 10px;">
						<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
					</div>
					<!-- /결재영역 -->
				</div>
			</div>
			<table class="table-border mt5 widthfix">
				<colgroup>
					<col width="100px">
					<col width="100px">
					<col width="*">
				</colgroup>
				<tbody>
				<tr>
					<th class="title-bg text-center">분기</th>
					<th class="title-bg text-center">최종 평점</th>
					<th class="title-bg text-center">비고</th>
				</tr>
				<tr>
					<th class="title-bg text-center">1/4분기</th>
					<td>
						<input type="text" class="form-control text-center"
							   id="q1_eval_point" name="q1_eval_point"
							   title="1/4분기 평점" format="num" readonly="readonly"
						/>
					</td>
					<td>
						<input type="text" class="form-control text-left"
							   id="q1_remark" name="q1_remark"
							   title="1/4분기 비고" readonly="readonly"
						/>
					</td>
				</tr>
				<tr>
					<th class="title-bg text-center">2/4분기</th>
					<td>
						<input type="text" class="form-control text-center"
							   id="q2_eval_point" name="q2_eval_point"
							   title="2/4분기 평점" format="num" readonly="readonly"
						/>
					</td>
					<td>
						<input type="text" class="form-control text-left"
							   id="q2_remark" name="q2_remark"
							   title="2/4분기 비고" readonly="readonly"
						/>
					</td>
				</tr>
				<tr>
					<th class="title-bg text-center">3/4분기</th>
					<td>
						<input type="text" class="form-control text-center"
							   id="q3_eval_point" name="q3_eval_point"
							   title="3/4분기 평점" format="num" readonly="readonly"
						/>
					</td>
					<td>
						<input type="text" class="form-control text-left"
							   id="q3_remark" name="q3_remark"
							   title="3/4분기 비고" readonly="readonly"
						/>
					</td>
				</tr>
				<tr>
					<th class="title-bg text-center">4/4분기</th>
					<td>
						<input type="text" class="form-control text-center"
							   id="q4_eval_point" name="q4_eval_point"
							   title="4/4분기 평점" format="num" readonly="readonly"
						/>
					</td>
					<td>
						<input type="text" class="form-control text-left"
							   id="q4_remark" name="q4_remark"
							   title="4/4분기 비고" readonly="readonly"
						/>
					</td>
				</tr>
				<tr>
					<th class="title-bg text-center">종합</th>
					<td>
						<input type="text" class="form-control text-center"
							   id="total_eval_point" name="total_eval_point"
							   title="종합분기 평점" required="required"
							   format="num"
						/>
					</td>
					<td>
						<input type="text" class="form-control text-left"
							   id="total_remark" name="total_remark"
							   title="종합분기 비고" required="required"
							   maxlength="50"
						/>
					</td>
				</tr>
				</tbody>
			</table>
		</div>
		<!-- /분기 별 평가결과 -->

		<!-- 상벌사항 & 취득사항 라인 -->
		<div class="row mt10">
			<!-- 상벌사항 -->
			<div class="col-6">
				<div class="title-wrap mt5">
					<h4>상벌사항</h4>
				</div>
				<div>
					<div id="auiGridAwardAndPenalty" style="height: 400px; margin-top: 11px;"></div>
				</div>
			</div>
			<!-- 취득사항 -->
			<div class="col-6">
				<div class="title-wrap mt5">
					<div class="btn-group">
						<h4>취득사항</h4>
						<div class="right">
							<button type="button" class="btn btn-primary-gra" onclick="fnAddAbility()">능력추가</button>
							<button type="button" class="btn btn-primary-gra" onclick="fnSaveAbility()">능력저장</button>
						</div>
					</div>
				</div>
				<div>
					<div id="auiGridAbility" style="height: 400px; margin-top: 5px;"></div>
				</div>
			</div>
		</div>
		<!-- /상벌사항 & 취득사항 라인 -->

		<!-- 세번째 라인 -->
		<div class="row mt10">
			<!-- 고과결과 & 근로계약서 -->
			<div class="col-6">
				<!-- 고과결과 -->
				<div>
					<div class="title-wrap mt5" style="display: flex; justify-content: space-between; align-items: center;">
						<div class="left">
							<h4>고과결과</h4>
						</div>
						<div class="text-warning ml5">
							<span>※ 조정금액은 +,- 400만원을 넘을 수 없습니다.</span>
						</div>
					</div>
					<table class="table-border mt5 m5 widthfix">
						<colgroup>
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="title-bg text-center">구분</th>
							<th class="title-bg text-center">기본</th>
							<th class="title-bg text-center">취득</th>
							<th class="title-bg text-center">상벌사항</th>
							<th class="title-bg text-center">합계</th>
							<th class="title-bg text-center">조정(최종연봉)</th>
						</tr>
						<tr>
							<th class="title-bg text-center" id="last_eval_year"></th>
							<td class="text-center" id="last_base_salary_amt"></td>
							<td class="text-center" id="last_ability_amt"></td>
							<td class="text-center" id="last_award_penalty_amt"></td>
							<td class="text-center" id="last_total_amt"></td>
							<td class="text-center" id="last_last_salary_amt"></td>
						</tr>
						<tr>
							<th class="title-bg text-center" id="eval_year"></th>
							<td class="text-center" id="base_salary_amt">
								<input type="hidden" name="base_salary_amt"/>
							</td>
							<td class="text-center" id="ability_amt"></td>
							<td class="text-center" id="award_penalty_amt">
								<input type="hidden" name="award_penalty_amt"/>
							</td>
							<td class="text-center" id="total_amt"></td>
							<td>
								<input type="text" class="form-control text-center"
									   id="last_salary_amt" name="last_salary_amt"
									   required="required" format="num" alt="조정(최종연봉)" />
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- 근로계약서 -->
				<div>
					<div class="title-wrap mt5">
						<h4>근로계약서</h4>
					</div>
					<table class="table-border m5 mt5 widthfix">
						<tbody>
						<tr>
							<td>
								<div class="row">
									<div class="col">
										<button type="button" class="btn btn-primary-gra"
												id="btn_mng_salary" name="btn_mng_salary"
												onclick="goPopupMngSalary()">계약진행</button>
									</div>
									<div class="col">
										<div id="contract_info">
											<span>계약완료일 : </span>
											<span id="contract_ed_dt"></span>
										</div>
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
			</div>
			<!-- /고과결과 & 근로계약서 -->
			<!-- 결재자 의견 -->
			<div class="col-6">
				<div>
					<div class="title-wrap mt10">
						<h4>결재자의견</h4>
					</div>
					<table class="table mt5">
						<colgroup>
							<col width="40px">
							<col width="">
							<col width="60px">
							<col width="">
						</colgroup>
						<tr>
							<td colspan="5">
								<div class="fixed-table-container" style="width: 100%; height: 170px;">
									<!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
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
											<tr>
												<th class="th" style="font-size: 12px !important">구분</th>
												<th class="th" style="font-size: 12px !important">결재일시</th>
												<th class="th" style="font-size: 12px !important">담당자</th>
												<th class="th" style="font-size: 12px !important">특이사항</th>
											</tr>
											</thead>
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
					</table>
				</div>
			</div>
			<!-- /결재자의견 -->
		</div>
		<!-- /세번째 라인 -->
		<div class="btn-group mt10">
			<div class="right">
				<c:choose>
					<%-- 결재요청 이후 --%>
					<c:when test="${apprBean.appr_proc_status_cd >= 3}">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
							<jsp:param name="pos" value="BOM_R"/>
							<jsp:param name="appr_yn" value="Y"/>
						</jsp:include>
					</c:when>
					<c:otherwise>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
							<jsp:param name="pos" value="BOM_R"/>
						</jsp:include>
					</c:otherwise>
				</c:choose>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>