<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > null > null > 주간계획서 등록
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var rowNo;
		var hourList = ${hourList}; // 시작시간, 종료시간
		var planStatusList = ${planStatusList}; // 상태
		var weekCntMap = ${weekCntMap}; // 주차
		$(document).ready(function () {
			createAUIGrid();
			fnInit();
		});

		// 초기 Setting
		function fnInit() {
			fnChangeYearMon();
			// goSearch();
		}

		// 주차 Setting
		function fnChangeYearMon() {
			var yearMonth = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"));

			$("#s_week_of_month option").remove();

			if (weekCntMap.hasOwnProperty(yearMonth)) {
				var weekCntList = weekCntMap[yearMonth];
				for (var i = 0; i < weekCntList.length; i++) {
					if (weekCntList[i].week_of_mon == "${inputParam.week_of_mon}") {
						$("#s_week_of_month").append(new Option(weekCntList[i].week_of_mon_name, weekCntList[i].week_of_mon, '', true));
					} else {
						$("#s_week_of_month").append(new Option(weekCntList[i].week_of_mon_name, weekCntList[i].week_of_mon, '', false));
					}
				}
			}

			goSearch();
		}

		function goChangeYearMon() {
			var yearMonth = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"));
			var sStartDt = yearMonth + "15";
			
			var param = {
				"s_year_mon": yearMonth,
// 				"s_start_dt": sStartDt,
				"week_of_mon" : "1"
			};

			$M.goNextPage(this_page, $M.toGetParam(param), {method: "GET"});
		}

		// 조회
		function goSearch() {
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["s_week_of_month"]}) == false) {
				return;
			}

			var yearMonth = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"));

			var param = {
				"week_of_mon": $M.getValue("s_week_of_month"),
				"s_org_code": $M.getValue("s_org_code"),
				"s_mem_no": $M.getValue("s_mem_no"),
				"s_year_mon": yearMonth
			}

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							if (result.planWeekMap != undefined) {
								goDetailSearch(result.planWeekMap.plan_week_no);
								fnClose();
							} else {
								AUIGrid.setGridData(auiGrid, result.list);
								rowNo = result.total_cnt;
								$M.setValue("s_week_of_month", result.this_week);
							}
						}
					}
			);
		}

		// 주간계획 상세 조회
		function goDetailSearch(planWeekNo) {
			var param = {
				"plan_week_no": planWeekNo
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=300, left=0, top=0";
			$M.goNextPage('/mmyy/mmyy0108p02', $M.toGetParam(param), {popupStatus: popupOption});
		}

		// 체크 후 행추가
		function fnAdd() {
			var checkGridData = AUIGrid.getCheckedRowItems(auiGrid);

			if (checkGridData.length < 1) {
				alert("추가를 원하는 위치의 행을 먼저 체크해주세요.");
				return;
			} else {
				rowNo++;

				var rowIndex = checkGridData["length"] - 1 == -1 ? 0 : checkGridData[checkGridData["length"] - 1].rowIndex + 1;

				var item = new Object();

				var gridData = checkGridData[checkGridData["length"] - 1];
				var dayOfWeek = gridData.item.day_of_week;
				var week = gridData.item.week;
				var planDt = gridData.item.plan_dt;

				item.day_of_week = dayOfWeek; // 일자
				item.plan_status_cd = "01"; // 상태코드
				item.plan_status_name = "01"; // 상태코드
				item.extend_dt = ""; // 연장일자
				item.st_hour = ""; // 시작시간
				item.ed_hour = ""; // 종료시간
				item.plan_text = ""; // 업무내용
				item.remark = ""; // 기타사항
				item.plan_dt = planDt; // 예정날짜
				item.week = week; // 요일
				item.default_yn = 'N' // 기본데이터 여부
				item.row_no = rowNo; // 행번호

				AUIGrid.addRow(auiGrid, item, rowIndex);
			}
		}

		// 체크 후 행삭제
		function fnRemove() {
			var data = AUIGrid.getCheckedRowItems(auiGrid);
			if (data.length <= 0) {
				alert('삭제할 데이터가 없습니다.');
				return;
			}

			// 연장 or 기본으로 Setting된 데이터는 삭제 불가능.
			for (var i = 0; i < data.length; i++) {
				if (data[i].item.plan_status_cd == "02" || data[i].item.default_yn == "Y") {
					continue;
				}

				AUIGrid.removeRow(auiGrid, data[i].rowIndex);
			}

			AUIGrid.setCheckedRowsByIds(auiGrid, data);
		}

		// 작성완료
		function goProcessConfirm() {
			goSave("requestConfirm");
		}

		// 저장
		function goSave(isProcessConfirm) {
			var msg = fnSetMsg(isProcessConfirm);

			var data = AUIGrid.getGridData(auiGrid);
			if (data.length < 1) {
				alert("처리 할 데이터가 존재하지 않습니다.");
				return;
			}

			for (var i = 0; i < data.length; i++) {
				if ((data[i].st_hour != "" || data[i].ed_hour != "") && data[i].plan_text == "") {
					alert("시작시간 또는 종료시간을 입력한 경우 업무내용을 입력해야합니다.");
					return;
				}
			}

			var sYearMonth = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"));
			$M.setValue("plan_mon", sYearMonth);
			$M.setValue("week_cnt", $M.getValue("s_week_of_month"));

			var frm = $M.toValueForm(document.main_form);

			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxMsg(msg, this_page + "/save", gridFrm, {method: 'POST'},
					function (result) {
						if (result.success) {
							fnClose();
							window.opener.goSearch();
						}
					}
			);
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "주간계획서 등록");
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// Message Setting
		function fnSetMsg(isProcessConfirm) {
			if (isProcessConfirm != undefined) {
				$M.setValue("write_comp_yn", "Y");
				$M.setValue("modify_yn", "N");
				return "작성완료 처리를 하시겠습니까?";
			} else {
				return "저장 하시겠습니까?";
			}
		}

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		// Grid 데이터 Setting
		function fnGridAndFormData(gridObj) {
			var gridData = AUIGrid.getGridData(gridObj);
			var frm = $M.createForm();
			var columns = fnGetColumns(gridObj);

			for (var i = 0, n = gridData.length; i < n; i++) {
				var row = gridData[i];
				if (row.plan_text != "") {
					frm = fnToFormData(frm, columns, row);
				}

				var hasCmd = 'cmd' in row;
				if (hasCmd == false) {
					$M.setHiddenValue(frm, 'cmd', 'C');
				}
			}

			return frm;
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: false,
				showRowCheckColumn: true,
				enableCellMerge: true, // 셀병합 사용여부
				cellMergeRowSpan: true,
				editable: true,
				showStateColumn: true,

				rowStyleFunction : function(rowIndex, item) {
					if (item.aui_status_cd !== "") {
						if(item.aui_status_cd == "D") { // 기본
							return "aui-status-default";
						} else if(item.aui_status_cd == "R") { // 반려
							return "aui-color-red";
						} else if(item.aui_status_cd == "C") { // 완료
							return "aui-status-complete";
						}
					}
				}
			}

			var columnLayout = [
				{
					headerText: "일자",
					dataField: "day_of_week",
					width: "80",
					minWidth: "70",
					editable: false,
					cellMerge: true
				},
				{
					headerText: "상태",
					dataField: "plan_status_name",
					editable: true,
					width: "80",
					minWidth: "70",
					style: "aui-center aui-editable",
					editRenderer: {
						type: "DropDownListRenderer",
						showEditorBtn: false,
						showEditorBtnOver: false,
						list: planStatusList,
						keyField: "code_value",
						valueField: "code_name"
					},
					labelFunction: function (rowIndex, columnIndex, value) {
						for (var i = 0; i < planStatusList.length; i++) {
							if (value == planStatusList[i].code_value) {
								return planStatusList[i].code_name;
							}
						}
						return value;
					}
				},
				{
					headerText: "연장일자",
					dataField: "custom_extend_dt",
					dataType: "date",
					width: "80",
					minWidth: "70",
					style: "aui-center aui-editable",
					dataInputString: "yyyymmdd",
					formatString: "yy-mm-dd",
					editRenderer: {
						type: "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat: "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar: false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength: 8,
						onlyNumeric: true, // 숫자만
						validator: function (oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							//삭제는 가능해야함
							if (newValue != "") {
								return fnCheckDate(oldValue, newValue, rowItem);
							}
						},
						showEditorBtnOver: true
					}
				},
				{
					headerText: "시작시간",
					dataField: "st_hour",
					width: "80",
					minWidth: "70",
					postfix: "시",
					style: "aui-center aui-editable",
					editRenderer: {
						type: "DropDownListRenderer",
						list: hourList
					}
				},
				{
					headerText: "종료시간",
					dataField: "ed_hour",
					width: "80",
					minWidth: "70",
					postfix: "시",
					style: "aui-center aui-editable",
					editRenderer: {
						type: "DropDownListRenderer",
						list: hourList
					}
				},
				{
					headerText: "업무내용",
					dataField: "plan_text",
					width: "550",
					minWidth: "540",
					style: "aui-left aui-editable"
				},
				{
					headerText: "기타사항",
					dataField: "remark",
					width: "300",
					minWidth: "290",
					style: "aui-left aui-editable"
				},
				{
					headerText: "예정날짜",
					dataField: "plan_dt",
					visible: false
				},
				{
					headerText: "요일번호",
					dataField: "week",
					visible: false
				},
				{
					headerText: "상태",
					dataField: "plan_status_cd",
					visible: false
				},
				{
					headerText: "기본데이터여부",
					dataField: "default_yn",
					visible: false
				},
				{
					headerText: "행번호",
					dataField: "row_no",
					visible: false
				},
				{
					headerText: "extend_dt",
					dataField: "extend_dt",
					visible: false
				},
				{
					headerText: "그리드 row색상",
					dataField : "aui_status_cd",
					visible: false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				// 신규/연장 값이 신규인 경우 연장일자 입력 불가.
				if (event.item.plan_status_cd == "01") {
					if (event.dataField == "custom_extend_dt") {
						return false;
					}
				}

				// 연장인 경우 연장일자 이외의 컬럼 입력 불가.
				if (event.item.plan_status_cd == "02") {
					if (event.dataField == "st_hour" || event.dataField == "ed_hour"
							|| event.dataField == "plan_text" || event.dataField == "remark") {
						return false;
					}
				}
			});

			AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
				if (event.dataField == "custom_extend_dt") {
					AUIGrid.updateRow(auiGrid, {"extend_dt": event.item.custom_extend_dt}, event.rowIndex);
				}

				if (event.dataField == "plan_status_name") {
					AUIGrid.updateRow(auiGrid, {"plan_status_cd": event.item.plan_status_name}, event.rowIndex);

					var planStatusName = event.item.plan_status_name;
					var auiStatusCd = event.item.aui_status_cd;

					if(planStatusName == "02") {
						auiStatusCd = "R";
					} else if(planStatusName == "09") {
						auiStatusCd = "C";
					} else {
						auiStatusCd = "D";
					}

					AUIGrid.updateRow(auiGrid, { "aui_status_cd" : auiStatusCd }, event.rowIndex);
				}

				if(event.dataField == "ed_hour" || event.dataField == "st_hour") {
					var stHour = $M.toNum(event.item.st_hour);
					var edHour = $M.toNum(event.item.ed_hour);

					if(edHour > 0 && (edHour < stHour)) {
						AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "종료시간은 시작시간보다 빠를 수 없습니다.");
						var tempHour = $M.toNum(event.item.st_hour) + 1;
						tempHour = tempHour < 10 ? "0" + tempHour : tempHour;
						AUIGrid.setCellValue(auiGrid, event.rowIndex, "ed_hour", tempHour);
					}
				}

				// if(event.dataField == "plan_status_name") {
				// 	var planStatusCd = event.item.plan_status_cd;
				// 	var auiStatusCd = event.item.aui_status_cd;
				// 	if(planStatusCd == "02") {
				// 		auiStatusCd = "R";
				// 	} else if(planStatusCd == "09") {
				// 		auiStatusCd = "C";
				// 	}
				//
				// 	console.log(auiStatusCd);
				// 	AUIGrid.updateRow(auiGrid, { "aui_status_cd" : auiStatusCd }, event.rowIndex);
				// }
			});
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="s_org_code" name="s_org_code" value="${SecureUser.org_code}"/>
	<input type="hidden" id="s_mem_no" name="s_mem_no" value="${SecureUser.mem_no}"/>
	<input type="hidden" id="s_date" name="s_date" value="${inputParam.s_date}"/>
	<input type="hidden" id="write_comp_yn" name="write_comp_yn" value="N"/>
	<input type="hidden" id="modify_yn" name="modify_yn" value="Y"/>
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
					<h4 class="primary">주간계획서 등록</h4>
				</div>
			</div>
			<!-- 폼테이블 -->
			<div>
				<div class="title-wrap mt5">
					<div class="left">
						<select class="form-control mr3" style="width: 70px;" id="s_year" name="s_year" required="required" alt="작성 년도" onchange="javascript:goChangeYearMon();">
							<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
								<c:set var="year_option" value="${inputParam.s_current_year + 1 - i + 2000}"/>
								<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
							</c:forEach>
						</select>
						<select class="form-control mr3" style="width: 60px;" id="s_mon" name="s_mon" required="required" alt="작성 월" onchange="javascript:goChangeYearMon();">
							<c:forEach var="i" begin="1" end="12" step="1">
								<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_mon}">selected</c:if>>${i}월</option>
							</c:forEach>
						</select>
						<select class="form-control" style="width: 70px;" id="s_week_of_month" name="s_week_of_month" onchange="javascript:goSearch();">
						</select>
						<div class="right text-warning ml5">
							(※ 전주 예정사항 및 기본사항은 삭제가 불가능합니다.)
						</div>
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
			</div>
			<!-- /폼테이블-->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>