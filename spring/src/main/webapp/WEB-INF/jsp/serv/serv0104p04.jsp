<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 new > 상세 > 엑셀업로드
-- 작성자 : jsk
-- 최초 작성일 : 2024-06-07 13:43:11
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var centerToolBoxList = ${center_tool_box_list};
		var centerToolCheckList = ${tool_check_list};
		var toolNameList = ${tool_name_list};

		$(document).ready(function () {
			$("#check_status_name").html("${check_status_name}");
			$("#total_cnt").html(centerToolCheckList.length);
			createAUIGrid();
		});

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				noDataMessage: "엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여 넣기(Ctrl+V) 하십시오.",
				showAutoNoDataMessage: true, // 데이터 없을 때 메세지 노출 여부
				editable: true, // 수정 모드
				enableRestore: false,
				showStateColumn: true
			};

			var columnLayout = [
				{
					headerText : "공구이름",
					dataField : "tool_name",
					style : "aui-left aui-editable",
					width : "18%",
					editable : true,
					editRenderer : {
						type : "InputEditRenderer",
						maxlength : 50,
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "이전수량",
					dataField : "before_check_qty_sum",
					style : "aui-center aui-editable",
					dataType: "numeric",
					formatString: "#,##0",
					width : "6%",
					editable : true,
					editRenderer: {
						type: "InputEditRenderer",
						onlyNumeric : true,
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "조사수량",
					dataField : "check_qty_sum",
					style : "aui-center aui-editable",
					dataType: "numeric",
					formatString: "#,##0",
					width : "6%",
					editable : true,
					editRenderer: {
						type: "InputEditRenderer",
						onlyNumeric : true,
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "차이수량",
					dataField : "gap_qty_sum",
					style : "aui-center aui-editable",
					dataType: "numeric",
					formatString: "#,##0",
					width : "6%",
					editable : true,
					editRenderer: {
						type: "InputEditRenderer",
						onlyNumeric : true,
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "차이발생이유",
					dataField : "gap_remark",
					style : "aui-left aui-editable",
					editable : true,
					editRenderer : {
						type : "InputEditRenderer",
						maxlength : 100,
						validator : AUIGrid.commonValidator
					}
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			for (var i = 0; i < centerToolBoxList.length; ++i) {
				var result = centerToolBoxList[i];
				var columnObj = {
					headerText : result.box_name,
					dataField : "box" + result.nsvc_tool_box_seq + "_cnt",
					style : "aui-center aui-editable",
					width : "6%",
					editable : true,
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "" ? 0 : AUIGrid.formatNumber(value, "#,##0");
					},
					editRenderer : {
						onlyNumeric : true,
						allowPoint : false
					}
				}
				AUIGrid.addColumn(auiGrid, columnObj, 'last');
			}
			var addColumnObj = [
				{
					headerText: "적합여부",
					dataField: "is_check_text",
					style: "aui-left",
					width : "15%",
					editable: false,
				},
				{
					dataField: "is_check",
					visible: false
				}
			];
			AUIGrid.addColumn(auiGrid, addColumnObj, 'last');

			AUIGrid.bind(auiGrid, "cellEditBegin", function( event ) {
				if(event.dataField == "gap_remark") {
					// 차이수량이 0아닌 경우에만 에디팅허용
					if(event.item.gap_qty_sum != 0) {
						return true;
					} else {
						return false;
					}
				}
			});

			AUIGrid.bind(auiGrid, "cellEditEnd", function( event ) {
				if (event.dataField.endsWith("_cnt") || event.dataField.endsWith("_sum") || event.dataField == "tool_name") {
					if (event.item.is_check != undefined) {
						AUIGrid.updateRow(auiGrid, { "is_check" : "",  "is_check_text": "" }, event.rowIndex );
					}
				}
				//공구함별 공구의 재고 변경시 조사수량 , 차이수량 변경하기
				if(event.dataField.endsWith("_cnt")) {
					//수량이 변결될때만
					if ( event.value != event.oldValue ) {
						var checkQty = 0;
						var beforeCheckQty = Number($M.nvl(event.item.before_check_qty_sum, 0));

						var keys = Object.keys(event.item);
						keys.forEach(key => {
							if (key.endsWith("_cnt")) {
								checkQty += Number($M.nvl(event.item[key], 0));
							}
						});
						var gapQtySum = checkQty - beforeCheckQty;
						// 조사수량,차이수량 갱신
						AUIGrid.updateRow(auiGrid, { "check_qty_sum" : checkQty }, event.rowIndex );
						AUIGrid.updateRow(auiGrid, { "gap_qty_sum"   : gapQtySum }, event.rowIndex );
						if(gapQtySum == 0) {
							AUIGrid.updateRow(auiGrid, { "gap_remark" : "" }, event.rowIndex );
						}
					}
				}
				//공구함별 공구의 재고 변경시 조사수량 , 차이수량 변경하기
				if(event.dataField.endsWith("_sum")) {
					var gapQtySum = Number($M.nvl(event.item.gap_qty_sum, 0));
					if(gapQtySum == 0) {
						AUIGrid.updateRow(auiGrid, { "gap_remark" : "" }, event.rowIndex );
					}
				}
			});

			// 붙여넣기 후 처리 이벤트
			AUIGrid.bind(auiGrid, "pasteEnd", function (event) {
				pasteEndCheckGridData();
			});

			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {
				// 제외항목
				exceptColumnFields : ["is_check_text", "is_check"]
			};
			fnExportExcel(auiGrid, "정비Tool관리", exportProps);
		}

		// 데이터 적합 검사
		function pasteEndCheckGridData() {
			var gridData = AUIGrid.getGridData(auiGrid);
			for (i = 0; i < gridData.length; i++) {
				var item = gridData[i];
				var isPass = false;
				for (j=i+1; j < gridData.length-1; j++) {
					if (item.tool_name == gridData[j].tool_name) {
						updateRow(item, "공구이름이 중복됩니다.", false, i);
						isPass = true;
						break;
					}
				}
				if (isPass) {
					continue;
				}

				if (item.tool_name == "") {
					updateRow(item, "공구이름이 없습니다.", false, i);
					continue;
				}
				if (!toolNameList.includes(item.tool_name.trim())) {
					updateRow(item, "관리하지 않는 공구이름입니다.", false, i);
					continue;
				}
				var checkQty = 0;
				var keys = Object.keys(item);
				keys.forEach(key => {
					if (key.endsWith("_cnt")) {
						checkQty += Number($M.nvl(item[key], 0));
					}
				});
				if (Number($M.nvl(item.check_qty_sum, 0)) !== checkQty) {
					updateRow(item, "조사수량이 올바르지 않습니다.", false, i);
					continue;
				}
				if (Number($M.nvl(item.gap_qty_sum, 0)) !== (Number($M.nvl(item.check_qty_sum, 0)) - Number($M.nvl(item.before_check_qty_sum, 0)))) {
					updateRow(item, "차이수량이 올바르지 않습니다.", false, i);
					continue;
				}
				if (Number($M.nvl(item.gap_qty_sum, 0)) > 0 && item.gap_remark == "") {
					updateRow(item, "차이발생이유 값은 필수값입니다.", false, i);
					continue;
				}

				updateRow(item, "적합", true, i);
			}
		}

		// row 업데이트 함수
		function updateRow(item, text, isCheck, idx) {
			item.is_check_text = text;
			item.is_check = isCheck;
			AUIGrid.updateRow(auiGrid, item, idx);
		}

		// 초기화
		function fnReset() {
			var gridData = AUIGrid.getGridData(auiGrid);
			if (gridData.length == 0) {
				alert('초기화할 데이터가 없습니다.');
				return;
			}
			if (confirm("데이터를 초기화 하시겠습니까?") == false) {
				return;
			}

			AUIGrid.clearGridData(auiGrid);
		}

		// 필수값 확인
		function fnConfirm() {
			pasteEndCheckGridData();
		}

		// 적용
		function goApply() {
			var gridData = AUIGrid.getGridData(auiGrid);
			if (gridData.length == 0) {
				alert('데이터가 없습니다.');
				return;
			}
			for (i = 0; i < gridData.length; i++) {
				if (gridData[i].is_check === undefined || gridData[i].is_check === "") {
					alert("필수 값 확인 후 진행해주세요.");
					return;
				}
			}

			<c:if test="${not empty inputParam.parent_js_name}">
			try {
				var result = {
					"center_org_code": $M.getValue("s_center_org_code"),
					"nsvc_tool_check_seq": $M.getValue("s_nsvc_tool_check_seq")
				};
				var list = [];
				gridData.map(item => {
					// 적합 상태 데이터만 전달
					if (item.is_check === true) {
						delete item.is_check;
						delete item.is_check_text;
						list.push(item);
					}
				});
				if (list.length < 1) {
					alert("적용할 데이터가 존재하지 않습니다.");
					return false;
				}
				if (gridData.length > list.length) {
					if (confirm("적합하지 않은 데이터가 존재합니다. 계속 진행하시겠습니까?") == false) {
						return false;
					}
				} else {
					if (confirm("적용하시겠습니까?") == false) {
						return false;
					}
				}

				result.list = list;
				opener.${inputParam.parent_js_name}(result);
				window.close();
			} catch (e) {
				console.log(e);
				alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
			}
			</c:if>
		}

		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" id="s_center_org_code" name="s_center_org_code" value="${inputParam.s_center_org_code}" />
	<input type="hidden" id="s_nsvc_tool_check_seq" name="s_nsvc_tool_check_seq" value="${inputParam.s_nsvc_tool_check_seq}" />
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<div class="content-wrap">
			<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="title-wrap mt10">
				<h4><span id="check_status_name" name="check_status_name"></span></h4>
				<div class="btn-group">
					<div>
						<div class="text-warning ml5">
							※ 엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여넣기(Ctrl+V) 하십시오.<br>
							※ 적합여부가 '적합'인 데이터만 적용됩니다.<br>
						</div>
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->
			<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>

			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
					</jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>