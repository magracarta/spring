<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 클레임보고서 작성
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-22 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGridTop;
		var auiGridBom;

		var rowNum = ${rowNum}
		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGridTop();
			createAUIGridBom();
		});

		// 의견추가내역 그리드
		function createAUIGridTop() {
			var gridPros = {
				rowIdField: "_$uid",
				showStateColumn: true,
				editable: true
			};

			var fixList = [
				{fix_yn: "F", fix_name: "임의"},
				{fix_yn: "R", fix_name: "실제"}
			];

			var columnLayout = [
				{
					headerText: "작성의견",
					dataField: "warranty_text",
					style: "aui-left",
					width: "30%"
				},
				{
					headerText: "F",
					dataField: "req_type_fr",
					style: "aui-center aui-editable",
					showEditorBtn: false,
					showEditorBtnOver: false,
					editable: true,
					editRenderer: {
						type: "DropDownListRenderer",
						list: fixList,
						keyField: "fix_yn",
						valueField: "fix_name"
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						var retStr = value;
						for (var j = 0; j < fixList.length; j++) {
							if (fixList[j]["fix_yn"] == value) {
								retStr = fixList[j]["fix_name"];
								break;
							} else if (value === null) {
								retStr = "- 선택 -";
								break;
							}
						}
						return retStr;
					}
				},
				{
					headerText: "관리번호",
					dataField: "warranty_no",
					style: "aui-center aui-editable"
				},
				{
					headerText: "AS워런티번호",
					dataField: "as_warranty_no",
					visible: false
				},
				{
					headerText: "작성일자",
					dataField: "warranty_dt",
					style: "aui-center aui-editable",
					dataType: "date",
					dataInputString: "yyyymmdd",
					formatString: "yyyy-mm-dd",
					editable: true,
					editRenderer: {
						type: "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat: "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar: false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength: 8,
						onlyNumeric: true, // 숫자만
						validator: function (oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver: true
					}
				},
				{
					headerText: "부품비",
					dataField: "rpt_part_amt",
					style: "aui-right aui-editable",
					dataType: "numeric",
					formatString: "#,##0",
				},
				{
					headerText: "출장비",
					dataField: "rpt_travel_amt",
					style: "aui-right aui-editable",
					dataType: "numeric",
					formatString: "#,##0",
				},
				{
					headerText: "공임",
					dataField: "rpt_work_amt",
					style: "aui-right aui-editable",
					dataType: "numeric",
					formatString: "#,##0",
				},
				{
					headerText: "행번호",
					dataField: "row_num",
					visible: false
				},
				{
					headerText: "삭제",
					dataField: "removeBtn",
					renderer: {
						type: "ButtonRenderer",
						onClick: function (event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridTop, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridTop, "selectedIndex");
							}
						}
					},
					labelFunction: function (rowIndex, columnIndex, value,
											 headerText, item) {
						return '삭제'
					},
					style: "aui-center",
					editable: false
				},
				{
					headerText: "사용여부",
					dataField: "use_yn",
					visible: false
				}
			];

			auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridTop, ${warrantyCurrList});

			$("#auiGridTop").resize();
		}

		// 과거 Warranty작성 자료 그리드
		function createAUIGridBom() {
			var gridPros = {
				rowIdField: "row",
				showRowNumColumn: true,
			};

			var columnLayout = [
				{
					headerText: "작성의견",
					dataField: "warranty_text",
					style: "aui-left",
					width: "30%"
				},
				{
					headerText: "F",
					dataField: "req_type_fr_name",
					style: "aui-center"
				},
				{
					headerText: "관리번호",
					dataField: "warranty_no",
					style: "aui-center",
					styleFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.as_no != "") {
							return "aui-popup";
						}
					}
				},
				{
					headerText: "AS워런티번호",
					dataField: "as_warranty_no",
					visible: false
				},
				{
					headerText: "작성일자",
					dataField: "warranty_dt",
					style: "aui-center",
					dataType: "date",
					formatString: "yyyy-mm-dd",
				},
				{
					headerText: "부품비",
					dataField: "rpt_part_amt",
					style: "aui-right",
					dataType: "numeric",
					formatString: "#,##0",
				},
				{
					headerText: "출장비",
					dataField: "rpt_travel_amt",
					style: "aui-right",
					dataType: "numeric",
					formatString: "#,##0",
				},
				{
					headerText: "공임",
					dataField: "rpt_work_amt",
					style: "aui-right",
					dataType: "numeric",
					formatString: "#,##0",
				},
				{
					headerText: "AS번호",
					dataField: "as_no",
					visible: false
				},
				{
					headerText: "AS타입",
					dataField: "as_type",
					visible: false
				}
			];

			auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridBom, ${warrantyList});

			$("#auiGridBom").resize();

			AUIGrid.bind(auiGridBom, "cellClick", function (event) {
				// 서비스일지 호출
				if (event.dataField == "warranty_no") {
					var params = {
						"s_as_no": event.item.as_no
					};

					if (event.item.as_type == "REPAIR") {
						var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=800, left=0, top=0";
						$M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});
					} else if (event.item.as_type == "CALL") {
						var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=800, left=0, top=0";
						$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
					}
				}
			});
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 저장
		function goSave() {
			var frm = document.main_form;
			if ($M.validation(frm,
					{field: []}) == false) {
				return;
			}

			var data = AUIGrid.getGridData(auiGridTop);
			for (var i = 0; i < data.length; i++) {
				if (data[i].warranty_text == "") {
					alert("작성의견은 필수 입력입니다.");
					return;
				}
			}

			var gridData = fnChangeGridDataToForm(auiGridTop, "use_yn");
			$M.copyForm(gridData, frm);

			$M.goNextPageAjaxSave(this_page + "/save", gridData, {method: "POST"},
					function (result) {
						if (result.success) {
							alert("처리가 완료되었습니다.");
							location.reload();
						}
					}
			);
		}

		// 행추가
		function fnAdd() {
			if (fnCheckGridEmpty(auiGridTop)) {
				var item = new Object();
				item.warranty_text = "";
				item.req_type_fr = "R";
				item.as_warranty_no = "";
				item.warranty_dt = "";
				item.rpt_part_amt = "";
				item.rpt_travel_amt = 0;
				item.rpt_work_amt = 0;
				item.row_num = rowNum;

				AUIGrid.addRow(auiGridTop, item, 'first');
				rowNum++;
			}
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGridTop, ["warranty_text"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="as_no" name="as_no" value="${inputParam.s_as_no}">
<input type="hidden" id="machine_seq" name="machine_seq" value="${inputParam.s_machine_seq}">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 폼테이블 -->
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">Warr Open</th>
						<td>${result.warranty_open_dt}</td>
						<th class="text-right">Warr Close</th>
						<td>${result.warranty_end_dt}</td>
						<th class="text-right">Warr Last</th>
						<td>-</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /폼테이블 -->
			<!-- 의견추가내역 -->
			<div class="title-wrap mt10">
				<h4>의견추가내역</h4>
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
			</div>
			<div id="auiGridTop" style="margin-top: 5px; height: 200px;"></div>
			<!-- /의견추가내역 -->
			<!-- 과거 Warranty작성 자료 -->
			<div class="title-wrap mt10">
				<h4>과거 Warranty작성 자료</h4>
			</div>
			<div id="auiGridBom" style="margin-top: 5px; height: 200px;"></div>
			<!-- /과거 Warranty작성 자료 -->
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>