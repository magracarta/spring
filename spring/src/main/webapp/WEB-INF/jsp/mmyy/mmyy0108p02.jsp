<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > null > null > 주간계획서 상세
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var rowNo = ${rowNo};
		var hourList = ${hourList}; // 시작시간, 종료시간
		var planStatusList = ${planStatusList}; // 상태
		var weekCntMap = ${weekCntMap}; // 주차
		$(document).ready(function () {
			createAUIGrid();
			fnInit();
		});

		// 초기 Setting
		function fnInit() {
			var writeCompYn = "${result.write_comp_yn}";
			var secureOrgCode = "${SecureUser.org_code}";
			var orgCode = "${result.org_code}";

			var secureMemNo = "${SecureUser.mem_no}";
			var memNo = "${result.mem_no}";

			// 버튼 권한
			fnSettingButtonAuth();

			fnChangeYearMon();
		}

		// 버튼 권한
		function fnSettingButtonAuth() {
			var currentDt = $M.getCurrentDate();
			var weekEdDt = $M.getValue("week_ed_dt");
			var writeCompYn = "${result.write_comp_yn}";
			var secureOrgCode = "${SecureUser.org_code}";
			var orgCode = "${result.org_code}";

			var secureMemNo = "${SecureUser.mem_no}";
			var memNo = "${result.mem_no}";

			// 지나간 주 버튼 권한
			if(weekEdDt < currentDt) {
				$("#_fnAdd").prop("disabled", true);
				$("#_fnRemove").prop("disabled", true);
				$("#_goRemove").addClass("dpn");
			}

			// 작성완료 시 버튼 disabled 처리
			if (writeCompYn == "Y" || (secureOrgCode != orgCode)) {
				$("#_fnAdd").prop("disabled", true);
				$("#_fnRemove").prop("disabled", true);

				$("#_goProcessConfirm").addClass("dpn");
				$("#_goModify").addClass("dpn");
				$("#_goRemove").addClass("dpn");
			} else {
				$("#_goCancelConfirm").addClass("dpn");
			}

			// 본인여부 판단
			if(secureMemNo != memNo) {
				$("#_goProcessConfirm").addClass("dpn");
				$("#_goModify").addClass("dpn");
				$("#_goRemove").addClass("dpn");
				$("#_fnAdd").prop("disabled", true);
				$("#_fnRemove").prop("disabled", true);
			}
		}

		// 주차 Setting
		function fnChangeYearMon() {
			var yearMonth = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"));

			$("#s_week_of_month option").remove();

			if (weekCntMap.hasOwnProperty(yearMonth)) {
				var weekCntList = weekCntMap[yearMonth];
				for (var i = 0; i < weekCntList.length; i++) {
					if (weekCntList[i].week_of_mon == ${inputParam.week_of_mon}) {
						$("#s_week_of_month").append(new Option(weekCntList[i].week_of_mon_name, weekCntList[i].week_of_mon, '', true));
					} else {
						$("#s_week_of_month").append(new Option(weekCntList[i].week_of_mon_name, weekCntList[i].week_of_mon, '', false));
					}
				}
			}
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
				item.extend_dt = ""; // 연장일자
				item.st_hour = ""; // 시작시간
				item.ed_hour = ""; // 종료시간
				item.plan_text = ""; // 업무내용
				item.remark = ""; // 기타사항
				item.plan_dt = planDt; // 예정날짜
				item.week = week; // 요일
				item.seq_no = -1 // 순번
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

			// 연장 데이터는 삭제 불가능.
			for (var i = 0; i < data.length; i++) {
				if (data[i].item.plan_status_cd == "02") {
					continue;
				}

				AUIGrid.removeRow(auiGrid, data[i].rowIndex);
			}

			AUIGrid.setCheckedRowsByIds(auiGrid, data);
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "주간계획서 상세");
		}

		//작성완료
		function goProcessConfirm() {
			goModify("requestConfirm");
		}

		// 저장
		function goModify(isProcessConfirm) {
			var msg = fnSetMsg(isProcessConfirm);

			var data = AUIGrid.getGridData(auiGrid);
			for (var i = 0; i < data.length; i++) {
				if ((data[i].st_hour != "" || data[i].ed_hour != "") && data[i].plan_text == "") {
					alert("시작시간 또는 종료시간을 입력한 경우 업무내용을 입력해야합니다.");
					return;
				}
				
				// 21.08.20 (SR:12294) 
				// 수정일경우 연장일자 체크 x // 작성완료일경우엔 연장일자 필수 체크함.
				if (isProcessConfirm != undefined) {
					if(data[i].plan_status_cd == "02" && data[i].extend_dt == "") {
						alert("상태가 연장일 경우 연장일자를 지정해야합니다.");
						return;
					}
				}
			}
			
			// 21.08.20 (SR:12294) 
			// 수정일경우 연장일자 체크 x // 작성완료일경우엔 연장일자 필수 체크함.
			// 연장이지만 내용이 수정안되었으면 연장일자를 필수 입력 하지 않도록 수정.
			//         내용이 수정되었다면, 연장일자 필수로 입력.
			var editedRowItems = AUIGrid.getEditedRowItems(auiGrid);
			if (isProcessConfirm == undefined) {
				for (var i = 0; i < editedRowItems.length; i++) {
					if (editedRowItems[i].plan_status_cd == "02" && editedRowItems[i].extend_dt == "") {
						alert("상태가 연장이고 내용이 수정되었을 경우 연장일자를 지정해야합니다.");
						return;
					}
				}
			}

			if (isProcessConfirm == undefined) {
				if (fnChangeGridDataCnt(auiGrid) < 1) {
					alert("수정할 데이터가 존재하지 않습니다.");
					return;
				}
			}

			var frm = $M.toValueForm(document.main_form);
			var gridFrm = fnChangeGridDataToForm(auiGrid);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxMsg(msg, this_page + "/modify", gridFrm, {method: 'POST'},
					function (result) {
						if (result.success) {
							window.location.reload();
							if (opener != null && opener.goSearch) {
								opener.goSearch();
							}
						}
					}
			);
		}

		function goCancelConfirm() {
			var secureMemNo = "${SecureUser.mem_no}";
			var memNo = "${result.mem_no}";

			if(secureMemNo != memNo) {
				alert("완료취소는 본인만 가능합니다.");
				return;
			}

			var param = {
				"plan_week_no": $M.getValue("plan_week_no"),
				"write_comp_yn": "N",
				"modify_yn": "Y"
			};

			$M.goNextPageAjaxMsg("완료취소를 진행하시겠습니까?", this_page + "/removeOrCancel", $M.toGetParam(param), {method: 'POST'},
					function (result) {
						if (result.success) {
							window.location.reload();
							if (opener != null && opener.goSearch) {
								opener.goSearch();
							}
						}
					}
			);
		}

		// 삭제
		function goRemove() {
			var currentDt = $M.getCurrentDate();
			var weekEdDt = $M.getValue("week_ed_dt");

			if(weekEdDt < currentDt) {
				alert("지나간 주는 삭제가 불가능합니다.");
				return;
			}

			var param = {
				"plan_week_no": $M.getValue("plan_week_no"),
				"use_yn": "N",
				"cmd": "U"
			};

			$M.goNextPageAjaxRemove(this_page + "/removeOrCancel", $M.toGetParam(param), {method: 'POST'},
					function (result) {
						if (result.success) {
							fnClose();
// 							window.opener.goSearch();
							if (opener != null && opener.goSearch) {
								opener.goSearch();
							}
						}
					}
			);
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
				return "수정 하시겠습니까?";
			}
		}

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
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
						} else if(item.aui_status_cd == "R") { // 연장
							return "aui-color-red";
						} else if(item.aui_status_cd == "C") { // 완료
							return "aui-status-complete";
						}
					}
				}
			}

			// 수정여부가 N이면 editable = false
			if ($M.getValue("modify_yn") == "N") {
				gridPros.editable = false;
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
					dataField: "plan_status_cd",
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
					dataField: "extend_dt",
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
					width: "500",
					minWidth: "490",
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
					headerText: "순번",
					dataField: "seq_no",
					visible: false
				},
				{
					headerText: "행번호",
					dataField: "row_no",
					visible: false
				},
				{
					headerText: "그리드 row색상",
					dataField : "aui_status_cd",
					visible: false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				var currentDt = $M.getCurrentDate();
				var weekEdDt = $M.getValue("week_ed_dt");

				// 신규/연장 값이 신규인 경우 연장일자 입력 불가.
				if (event.item.plan_status_cd == "01" || event.item.plan_status_cd == "09") {
					if (event.dataField == "extend_dt") {
						return false;
					}
				}

				// 연장인 경우 연장일자 이외의 컬럼 입력 불가.
				if (event.item.plan_status_cd == "02" || weekEdDt < currentDt) {
					if (event.dataField == "st_hour" || event.dataField == "ed_hour"
							|| event.dataField == "plan_text" || event.dataField == "remark") {
						return false;
					}
				}

				// 지난 주 일 경우, 신규등록은 불가능
				if ((weekEdDt < currentDt) && event.item.plan_text == "") {
					if (event.dataField == "plan_status_cd") {
						return false;
					}
				}
			});

			AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
				if(event.dataField == "plan_status_cd") {
					var planStatusCd = event.item.plan_status_cd;
					var auiStatusCd = event.item.aui_status_cd;
					if(planStatusCd == "02") {
						auiStatusCd = "R";
					} else if(planStatusCd == "09") {
						auiStatusCd = "C";
					} else if(planStatusCd == "01") {
						auiStatusCd = "D";
					}

					AUIGrid.updateRow(auiGrid, { "aui_status_cd" : auiStatusCd }, event.rowIndex);
				}
				
				// 21.08.20 (SR:12294) 
				// 연장일자 입력시 해당주차의 과거날짜 입력 불가능하게 체크.
				if (event.dataField == "extend_dt") {
					if (event.value <= $M.getValue("week_ed_dt")) {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "연장일자는 해당주차 이후의 날짜로 선택해 주세요.");
						}, 1);
						
						AUIGrid.updateRow(auiGrid, { "extend_dt" : ""}, event.rowIndex);
					} 
				}		
			});
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="plan_week_no" name="plan_week_no" value="${result.plan_week_no}" />
	<input type="hidden" id="write_comp_yn" name="write_comp_yn" value="${result.write_comp_yn}" />
	<input type="hidden" id="modify_yn" name="modify_yn" value="${result.modify_yn}" />
	<input type="hidden" id="week_ed_dt" name="week_ed_dt" value="${inputParam.week_ed_dt}" />
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
					<h4 class="primary">주간계획서 상세</h4>
				</div>
			</div>
			<!-- 폼테이블 -->
			<div>
				<div class="title-wrap mt5">
					<div class="left">
						<select class="form-control mr3" style="width: 70px;" id="s_year" name="s_year" required="required" disabled="disabled" alt="작성 년도" onchange="javascript:fnChangeYearMon();">
							<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
								<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
								<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
							</c:forEach>
						</select>
						<select class="form-control mr3" style="width: 60px;" id="s_mon" name="s_mon" required="required" disabled="disabled" alt="작성 월" onchange="javascript:fnChangeYearMon();">
							<c:forEach var="i" begin="1" end="12" step="1">
								<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_mon}">selected</c:if>>${i}월</option>
							</c:forEach>
						</select>
						<select class="form-control" style="width: 70px;" id="s_week_of_month" name="s_week_of_month" disabled="disabled" onchange="javascript:goSearch();">
						</select>
						<div class="right text-warning ml5">
							(※ 전주 예정사항은 삭제가 불가능합니다. 또한 전주 예정사항 수정 시 [상태, 연장일자]만 변경이 가능합니다.)
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