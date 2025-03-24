<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고품관리 > 고품관리 > 고품결재등록 > null
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
			goSearch();
		});

		// 조회
		function goSearch() {
			var sYearMon = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_month"));
			var param = {
				"s_year_mon": sYearMon
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, []);
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						}
					}
			);
		}

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
			fnExportExcel(auiGrid, "고품결재등록");
		}

		// 결재요청
		function goRequestApproval() {
			goSave('requestAppr');
		}

		// 저장
		function goSave(isRequestAppr) {
			// 2022-11-18 jsk 부품목록 없으면 저장 부락
			var data = AUIGrid.getTreeFlatData(auiGrid);
			if (data.length == 0) {
				alert("고품을 추가해주세요.");
				return;
			}
			for (var i = 0; i < data.length; i++) {
				if (data[i].old_part_proc_status_cd == "") {
					alert("처리상태를 확인해주세요.");
					return;
				}
			}

			var msg = "";
			if (isRequestAppr != undefined) {
				$M.setValue("save_mode", "appr"); // 결재요청
				msg = "결재요청 하시겠습니까?";
			} else {
				$M.setValue("save_mode", "save"); // 저장
				msg = "저장 하시겠습니까?";
			}

			var sYearMonth = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_month"));
			$M.setValue("part_old_mon", sYearMonth);

			var frm = $M.toValueForm(document.main_form);
			var gridFrm = fnGridDataToForm(auiGrid);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxMsg(msg, this_page + "/save", gridFrm, {method: 'POST'},
					function (result) {
						if (result.success) {
							fnList();
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

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		// 목록
		function fnList() {
			window.history.back();
		}

		// 고품추가
		function goOldStuffPopup() {
			var params = {
				"s_year": $M.getValue("s_year"),
				"s_month": $M.getValue("s_month")
			};

			console.log(params);

			$M.goNextPage('/serv/serv060101p01', $M.toGetParam(params), {popupStatus: ""});
		}

		// 그리드 생성
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
							return value;
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
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
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
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" id="part_old_mon" name="part_old_mon"/>
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left approval-left">
						<div class="left">
							<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
							<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
						</div>
					</div>
					<!-- 결재영역 -->
					<div class="p10" style="margin-left: 10px;">
						<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
					</div>
					<!-- /결재영역 -->
				</div>
				<!-- /상세페이지 타이틀 -->
				<div class="contents">
					<!-- 폼테이블 -->
					<div>
						<div class="title-wrap">
							<div class="left">
								<select class="form-control mr3" style="width: 70px;" id="s_year" name="s_year" onchange="javascript:goSearch();">
									<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
										<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}" />
										<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
									</c:forEach>
								</select>
								<select class="form-control" style="width: 60px;" id="s_month" name="s_month" onchange="javascript:goSearch();">
									<c:forEach var="i" begin="1" end="12" step="1">
										<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_month}">selected</c:if>>${i}월</option>
									</c:forEach>
								</select>
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
					<!-- /폼테이블 -->
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>