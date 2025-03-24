<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고품관리 > 고품관리 > null > 고품관리상세
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();

			if ("${result.appr_proc_status_cd}" != "01") {
				$("#_goOldStuffPopup").prop("disabled", true);
			}
		});

		// 이동
		function fnMove() {
			var orgName = $("#s_org_code option:selected").text();
			var oldPartProcStatusName = "이동(" + orgName + ")";
			var item = {
				"old_part_proc_status_cd": "01",
				"old_part_proc_status_name": oldPartProcStatusName,
				"trans_org_code": $M.getValue("s_org_code")
			};
			fnProcess(item);
		}

		// 보관
		function fnKeep() {
			var item = {"old_part_proc_status_cd": "02", "old_part_proc_status_name": "보관", "trans_org_code": ""};
			fnProcess(item);
		}

		// 폐기
		function fnAbrogate() {
			var item = {"old_part_proc_status_cd": "03", "old_part_proc_status_name": "폐기", "trans_org_code": ""};
			fnProcess(item);
		}

		// 고객회수
		function fnRecovery() {
			var item = {"old_part_proc_status_cd": "04", "old_part_proc_status_name": "고객회수", "trans_org_code": ""};
			fnProcess(item);
		}

		// 처리상태 (이동, 보관, 폐기, 고객회수)
		function fnProcess(item) {
			var data = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (data.length == 0) {
				alert("체크된 행이 없습니다.");
				return;
			}

			var params = {
				"old_part_proc_status_cd": item.old_part_proc_status_cd,
				"old_part_proc_status_name": item.old_part_proc_status_name,
				"trans_org_code": item.trans_org_code
			}

			for (var i = 0; i < data.length; i++) {
				var index = AUIGrid.rowIdToIndex(auiGrid, data[i]._$uid);
				AUIGrid.updateRow(auiGrid, params, index);
			}

			AUIGrid.setCheckedRowsByIds(auiGrid, data);
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "고품관리상세");
		}

		// 결재취소
		function goApprCancel() {
			var param = {
				appr_job_seq: "${apprBean.appr_job_seq}",
				seq_no: "${apprBean.seq_no}",
				appr_cancel_yn: "Y"
			};
			openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
		}

		function goApprovalResultCancel(result) {
			$M.goNextPageAjax('/session/check', '', {method: 'GET'},
					function (result) {
						if (result.success) {
							alert("결재취소가 완료됐습니다.");
							location.reload();
						}
					}
			);
		}

		// 결재처리
		function goApproval() {
			var param = {
				appr_job_seq: "${apprBean.appr_job_seq}",
				seq_no: "${apprBean.seq_no}"
			};
			$M.setValue("save_mode", "approval"); // 승인
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}

		// 결재처리 결과
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
				$M.goNextPageAjax('/session/check', '', {method: 'GET'},
						function (result) {
							if (result.success) {
								goModify('approval'); // [정윤수] Q&A 17965 결재승인 시 변경한 값 저장하기 위하여 추가
								// alert("처리가 완료되었습니다.");
								// location.reload();
							}
						}
				);
			}
		}

		// 결재요청
		function goRequestApproval() {
			goModify('requestAppr');
		}

		// 수정
		function goModify(isRequestAppr) {
			var frm = document.main_form;
			// validationcheck
			if ($M.validation(frm,
					{field: []}) == false) {
				return;
			}

			var msg = "";
			if (isRequestAppr != undefined) {
				if (isRequestAppr == "approval") {
					$M.setValue("save_mode", "approval"); // [정윤수] Q&A 17965 결재승인 시 변경한 값 저장하기 위하여 추가
				} else {
					// 결재요청 Setting
					$M.setValue("save_mode", "appr");
					msg = "결재요청 하시겠습니까?";
					if(confirm(msg) == false){
						return false;
					};
				}
			} else {
				$M.setValue("save_mode", "modify");
				msg = "수정 하시겠습니까?";
				if(confirm(msg) == false){
					return false;
				};
			}

			var data = AUIGrid.getTreeFlatData(auiGrid);
			for (var i = 0; i < data.length; i++) {
				if (data[i].old_part_proc_status_cd == "") {
					alert("처리상태를 확인해주세요.");
					return;
				}
			}

			var frm = $M.toValueForm(document.main_form);
			var gridFrm = fnGridDataToForm(auiGrid);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjax(this_page + "/modify", gridFrm, {method: "POST"},
					function (result) {
						if (result.success) {
							alert("처리가 완료되었습니다.");
							fnReload();
						}
					}
			);
		}

		function fnGridDataToForm(gridObj, onlyColumns) {
			var gridData = AUIGrid.getTreeFlatData(gridObj);

			var frm = $M.createForm();

			// 그리드에 명시된 행만 추출함
			var columns = fnGetColumns(gridObj);
			if (onlyColumns != undefined) {
				columns = onlyColumns;
			}

			for (var i = 0, n = gridData.length; i < n; i++) {
				var row = gridData[i];
				frm = fnToFormData(frm, columns, row);

				var hasCmd = 'cmd' in row;
				if (hasCmd == false) {
					$M.setHiddenValue(frm, 'cmd', 'C');
				}
			}

			return frm;
		}

		function goRemove() {
			var frm = document.main_form;
			// validationcheck
			if ($M.validation(frm,
					{field: ["part_old_no"]}) == false) {
				return;
			}

			var frm = $M.toValueForm(document.main_form);
			var gridFrm = fnGridDataToForm(auiGrid);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxRemove(this_page + "/remove", gridFrm, {method: "POST"},
					function (result) {
						if (result.success) {
							alert("처리가 완료되었습니다.");
							window.opener.goSearch();
							fnClose();
						}
					}
			);
		}

		function fnClose(searchYn) {
			searchYn = (searchYn == undefined? "N" : searchYn);
			window.close();
			if (searchYn == "Y" && opener.goSearch) {
				opener.goSearch();
			}
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid", // 행 구별 필드명 지정
				showRowNumColumn: true, // 행 번호 출력 여부
				showRowCheckColumn: true, // 체크박스 출력 여부
				showRowAllCheckBox: true, // 전체선택 체크박스 표시 여부
				displayTreeOpen: true, // 최초 보여질 때 모두 열린 상태로 출력 여부
				treeColumnIndex: 9
			};

			var columnLayout = [
				{
					headerText: "관리번호",
					dataField: "job_report_no",
					width: "80",
					minWidth: "70",
					style: "aui-center",
					styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
						if (item.job_report_no_depth == "1") {
							return "aui-popup";
						} else {
							return null;
						}
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return value.substring(4, 16);
						} else {
							return "";
						}
					}
				},
				{
					headerText: "뎁스",
					dataField: "job_report_no_depth",
					visible: false
				},
				{
					headerText: "정비일자",
					dataField: "job_dt",
					dataType: "date",
					formatString: "yy-mm-dd",
					width: "70",
					minWidth: "60",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return $M.formatDate($M.toDate(value)).substr(2);
						} else {
							return "";
						}
					}
				},
				{
					headerText: "부서",
					dataField: "org_name",
					width: "70",
					minWidth: "60",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return value;
						} else {
							return "";
						}
					}
				},
				{
					headerText: "부서코드",
					dataField: "org_code",
					visible: false
				},
				{
					headerText: "고객명",
					dataField: "cust_name",
					width: "150",
					minWidth: "140",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return value;
						} else {
							return "";
						}
					}
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width: "150",
					minWidth: "140",
					style: "aui-left",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return value;
						} else {
							return "";
						}
					}
				},
				{
					headerText: "S/N",
					dataField: "body_no",
					width: "150",
					minWidth: "140",
					style: "aui-left",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return value;
						} else {
							return "";
						}
					}
				},
				{
					headerText: "가동시간",
					dataField: "op_hour",
					width: "80",
					minWidth: "70",
					style: "aui-center",
					dataType: "numeric",
					formatString: "#,##0",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return $M.setComma(value);
						} else {
							return "";
						}
					}
				},
				{
					headerText: "부품명",
					dataField: "part_name",
					width: "180",
					minWidth: "170",
					style: "aui-left"
				},
				{
					headerText: "부품번호",
					dataField: "part_no",
					width: "150",
					minWidth: "140",
					style: "aui-left"
				},
				{
					headerText: "고장부위",
					dataField: "old_part_trouble",
					width: "260",
					minWidth: "250",
					style: "aui-left"
				},
				{
					headerText: "수량",
					dataField: "qty",
					width: "50",
					minWidth: "40",
					style: "aui-center"
				},
				{
					headerText: "처리상태",
					dataField: "old_part_proc_status_name",
					width: "80",
					minWidth: "70",
					style: "aui-center"
				},
				{
					headerText: "처리상태코드",
					dataField: "old_part_proc_status_cd",
					visible: false
				},
				{
					headerText: "이동조직",
					dataField: "trans_org_code",
					visible: false
				},
				{
					headerText: "정비지시서부품 순번",
					dataField: "seq_no",
					visible: false
				},
				{
					headerText: "부품고품번호",
					dataField: "part_old_no",
					visible: false
				},
				{
					headerText: "업무결재번호",
					dataField: "appr_job_seq",
					visible: false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();

			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "job_report_no" && event.item.job_report_no_depth == "1") {
					var params = {
						"s_job_report_no": event.item.job_report_no
					};
					var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
					$M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
				}
			});
		}

		// 고품추가
		function goOldStuffPopup() {
			var yearMon = '${result.year_mon}';
			var year = yearMon.substring(0,4);
			var month = yearMon.substring(4,6);

			var params = {
				"s_year": year,
				"s_month": month,
				"s_org_code" : '${result.org_code}',
				"part_old_no" : $M.getValue("part_old_no"),
				"appr_job_seq" : $M.getValue("appr_job_seq")
			};

			$M.goNextPage('/serv/serv060101p01', $M.toGetParam(params), {popupStatus: ""});
		}

		// 2022-11-11 jsk 16492 화면 새로고침 - 고품추가 팝업에서 호출
		function fnReload() {
			window.location.reload();
			if (opener.goSearch) {
				opener.goSearch();
			}
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="part_old_no" name="part_old_no" value="${result.part_old_no}" />
	<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${result.appr_job_seq}" />
	<input type="hidden" id="cmd" name="cmd" value="U" />
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<div class="left approval-left">
					<h4 class="primary">고품관리상세</h4>
				</div>
				<!-- 결재영역 -->
				<div class="pl10">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
				<!-- /결재영역 -->
			</div>
			<!-- 폼테이블 -->
			<div>
				<div class="title-wrap mt5">
					<div class="left">
						<h4>${result.part_old_mon}월 ${result.org_name} 고품관리<span class="text-primary">(${result.last_proc_dt}<c:if test="${result.last_proc_dt ne ''}"> </c:if>${result.appr_proc_status_name})</span></h4>
					</div>
					<div class="right dpf">
						<div class="dpf mr5">
							<span class="mr3">이동센터</span>
							<select class="form-control" style="width: 60px;" id="s_org_code" name="s_org_code">
								<c:forEach var="item" items="${codeMap['WAREHOUSE']}">
									<c:if test="${item.code_value ne '5010' and item.code_value ne '6000'}">
										<option value="${item.code_value}">${item.code_name.substring(0,2)}</option>
									</c:if>
								</c:forEach>
							</select>
						</div>
						<div>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
			</div>
			<!-- /폼테이블-->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/><jsp:param name="appr_yn" value="Y"/></jsp:include>
				</div>
			</div>
			<!-- 폼테이블 -->
			<div>
				<!-- 결재의견 -->
				<div class="title-wrap mt10">
					<div class="left">
						<h4>결재자의견</h4>
					</div>
				</div>
				<table class="table mt5">
					<colgroup>
						<col width="40px">
						<col width="">
						<col width="60px">
						<col width="">
					</colgroup>
					<thead>
					<tr>
						<td colspan="5">
							<div class="fixed-table-container" style="width: 100%; height: 110px;">
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
												<td class="td"
													style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
												<td class="td"
													style="font-size: 12px !important">${list.proc_date }</td>
												<td class="td"
													style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
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
				<!-- /결재의견 -->
			</div>
			<!-- /폼테이블-->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>