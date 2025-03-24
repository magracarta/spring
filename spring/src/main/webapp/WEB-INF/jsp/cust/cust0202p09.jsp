<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업고객 > 부품판매 > 매출처리 > null > 매출처리상세 > 전표분리
-- 작성자 : 황빛찬
-- 최초 작성일 : 2024-05-17 10:42:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var vatTreatJson = ${vatTreatList};
		var auiGrid;

		$(document).ready(function() {
			createAUIGrid();

			vatTreatJson.unshift({code_value : '', code_name : "선택　▼"});
		});

		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "_$uid",
				editable : true,
				showStateColumn : true,
				// rowNumber
				showRowNumColumn: true,
				showFooter : true,
				footerPosition : "top",
				footerRowCount : 2,
			};
			var columnLayout = [
				{
					dataField : "seq_no",
					visible : false
				},
				{
					headerText : "처리구분",
					dataField : "vat_treat_name",
					style : "aui-center aui-editable",
					width : "120",
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : vatTreatJson,
						keyField : "code_value",
						valueField  : "code_name"
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						for(var j = 0; j < vatTreatJson.length; j++) {
							if(vatTreatJson[j]["code_value"] == value) {
								retStr = vatTreatJson[j]["code_name"];
								break;
							}
						}
						return retStr;
					},
				},
				{
					headerText : "물품대",
					dataField : "doc_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "130",
					minWidth : "100",
					style : "aui-right aui-editable",
					editRenderer : {
						type : "InputEditRenderer",
						min : 1,
						onlyNumeric : true,
						// 에디팅 유효성 검사
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "세액(VAT)",
					dataField : "vat_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "130",
					minWidth : "100",
					style : "aui-right aui-editable",
					editRenderer : {
						type : "InputEditRenderer",
						min : 1,
						onlyNumeric : true,
						// 에디팅 유효성 검사
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "합계",
					dataField : "total_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "130",
					minWidth : "100",
					style : "aui-right",
					editable : false,
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "80",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGrid,{"inout_cmd":"D"},event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
								AUIGrid.update(auiGrid);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
								AUIGrid.update(auiGrid);
								AUIGrid.updateRow(auiGrid,{"inout_cmd":""},event.rowIndex);
							}
							$M.setValue("sum_doc_amt", AUIGrid.getFooterData(auiGrid)[1][2].text);
							$M.setValue("sum_vat_amt", AUIGrid.getFooterData(auiGrid)[1][3].text);
							$M.setValue("sum_total_amt", AUIGrid.getFooterData(auiGrid)[1][4].text);
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
											 headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				},
				{
					dataField : "inout_cmd",
					visible : false,
				},
				{
					dataField : "vat_treat_cd",
					visible : false
				},
			];

			var footerColumnLayout = [];
			// 푸터레이아웃
			footerColumnLayout[0] = [
				{
					labelText : "원 전표",
					positionField : "#base"
				},
				{
					labelText : "무증빙",
					positionField : "vat_treat_name",
					style : "aui-center aui-footer",
				},
				{
					dataField : "",
					positionField : "doc_amt",
					// operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					expFunction : function() {
						var originDocAmt = $M.getValue("origin_doc_amt");
						return originDocAmt;
					}
				},
				{
					dataField : "",
					positionField : "vat_amt",
					// operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					expFunction : function() {
						var originVatAmt = $M.getValue("origin_vat_amt");
						return originVatAmt;
					}
				},
				{
					dataField : "",
					positionField : "total_amt",
					// operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					expFunction : function() {
						var originTotalAmt = $M.getValue("origin_total_amt");
						return originTotalAmt;
					}
				}
			];

			footerColumnLayout[1] = [
				{
					labelText : "합계",
					positionField : "#base"
				},
				{
					labelText : "",
					positionField : "vat_treat_name",
					style : "aui-center aui-footer",
				},
				{
					dataField : "doc_amt",
					positionField : "doc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var rowIdField = AUIGrid.getProp(auiGrid, "rowIdField");
						var item;
						var sum = 0;
						for(var i=0, len=gridData.length; i<len; i++) {
							item = gridData[i];
							if(!AUIGrid.isRemovedById(auiGrid, item[rowIdField])) {
								sum += item.doc_amt;
							}
						}
						return sum;
					}
				},
				{
					dataField : "vat_amt",
					positionField : "vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var rowIdField = AUIGrid.getProp(auiGrid, "rowIdField");
						var item;
						var sum = 0;
						for(var i=0, len=gridData.length; i<len; i++) {
							item = gridData[i];
							if(!AUIGrid.isRemovedById(auiGrid, item[rowIdField])) {
								sum += item.vat_amt;
							}
						}
						return sum;
					}
				},
				{
					dataField : "total_amt",
					positionField : "total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var rowIdField = AUIGrid.getProp(auiGrid, "rowIdField");
						var item;
						var sum = 0;
						for(var i=0, len=gridData.length; i<len; i++) {
							item = gridData[i];
							if(!AUIGrid.isRemovedById(auiGrid, item[rowIdField])) {
								sum += item.total_amt;
							}
						}
						return sum;
					}
				}
			];

			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${list});

			$M.setValue("sum_doc_amt", AUIGrid.getFooterData(auiGrid)[1][2].text);
			$M.setValue("sum_vat_amt", AUIGrid.getFooterData(auiGrid)[1][3].text);
			$M.setValue("sum_total_amt", AUIGrid.getFooterData(auiGrid)[1][4].text);

			AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
				if (event.dataField == "vat_treat_name") {
					var gridData = AUIGrid.getGridData(auiGrid);

					for (var i = 0; i < gridData.length; i++) {
						if (gridData[i].vat_treat_cd == event.value) {
							setTimeout(function() {
								AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "해당 처리구분이 이미 존재합니다.");
							}, 1);
							AUIGrid.updateRow(auiGrid, { "vat_treat_name" : ""}, event.rowIndex);
							AUIGrid.updateRow(auiGrid, { "vat_treat_cd" : ""}, event.rowIndex);
							return false;
						}
					}
					AUIGrid.updateRow(auiGrid, { "vat_treat_cd" : event.value}, event.rowIndex);
				}

				var originDocAmt = $M.getValue("origin_doc_amt");
				var originVatAmt = $M.getValue("origin_vat_amt");
				var docAmt = event.item.doc_amt;
				var sumDocAmt = $M.getValue("sum_doc_amt");
				var sumVatAmt = $M.getValue("sum_vat_amt");
				var sumTotalAmt = $M.getValue("sum_total_amt");

				// var gridData = AUIGrid.getGridData(auiGrid);
				// console.log("gridData : ", gridData);
				// for (var i = 0; i < gridData.length; i++) {
				// 	sumDocAmt += gridData[i].doc_amt;
				// 	sumVatAmt += gridData[i].vat_amt;
				// 	sumTotalAmt += gridData[i].total_amt;
				// }

				console.log("sumDocAmt : ", sumDocAmt);
				if (event.dataField == 'doc_amt') {
					sumDocAmt = $M.toNum(sumDocAmt) + $M.toNum(event.item.doc_amt) - $M.toNum(event.oldValue);

					console.log("sumDocAmt2 : ", sumDocAmt);

					if (sumDocAmt > originDocAmt) {
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "분리전표의 물품대 합계는 원 전표의 물품대보다 클 수 없습니다.");
						}, 1);

						AUIGrid.updateRow(auiGrid, { "doc_amt" : ""}, event.rowIndex);
					} else {
						AUIGrid.updateRow(auiGrid, { "vat_amt" : Math.round(docAmt * 0.1), "total_amt" : docAmt + Math.round((docAmt * 0.1))}, event.rowIndex);
					}
					$M.setValue("sum_doc_amt", AUIGrid.getFooterData(auiGrid)[1][2].text);
				}

				if (event.dataField == 'vat_amt') {
					sumVatAmt = $M.toNum(sumVatAmt) + $M.toNum(event.item.vat_amt) - $M.toNum(event.oldValue);

					if (sumVatAmt > originVatAmt) {
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "분리전표의 세액 합계는 원 전표의 세액보다 클 수 없습니다.");
						}, 1);

						AUIGrid.updateRow(auiGrid, { "vat_amt" : ""}, event.rowIndex);
					} else {
						AUIGrid.updateRow(auiGrid, { "total_amt" : docAmt + event.value}, event.rowIndex);
					}

					$M.setValue("sum_vat_amt", AUIGrid.getFooterData(auiGrid)[1][3].text);
				}
			});

			$("#auiGrid").resize();

		}

		// 행추가
		function fnAdd() {
			if (fnCheckGridEmpty(auiGrid)) {
				var item = new Object();
				item.vat_treat_cd = "";
				item.vat_treat_name = "";
				item.doc_amt = null;
				item.vat_amt = null;
				item.total_amt = null;
				item.seq_no = AUIGrid.getGridData(auiGrid).length+1,
				item.inout_cmd = 'C';
				AUIGrid.addRow(auiGrid, item, 'last');
			}
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["vat_treat_name", "doc_amt", "vat_amt", "total_amt"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		//팝업 끄기
		function fnClose() {
			window.close();
		}

		function goSave() {
			if(fnCheckGridEmpty(auiGrid) == false) {
				return;
			}

			var originDocAmt = $M.toNum($M.getValue("origin_doc_amt"));
			var originVatAmt = $M.toNum($M.getValue("origin_vat_amt"));
			var totalDocAmt = $M.toNum(AUIGrid.getFooterData(auiGrid)[1][2].text);
			var totalVatAmt = $M.toNum(AUIGrid.getFooterData(auiGrid)[1][3].text);

			if (totalDocAmt != originDocAmt) {
				alert("분리전표의 물품대 합계는 원 전표의 물품대와 같아야 합니다.");
				return;
			}

			if (totalVatAmt != originVatAmt) {
				alert("분리전표의 세액 합계는 원 전표의 세액과 같아야 합니다.");
				return;
			}

			if (confirm("저장 하시겠습니까 ?") == false) {
				return;
			}

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

			console.log("gridFrm : ", gridFrm);

			$M.goNextPageAjax(this_page + "/save" , gridFrm , {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("저장이 완료되었습니다.");
						window.location.reload();
					}
				}
			);
		}

		function goRemove() {
			if (confirm("삭제 하시겠습니까 ?") == false) {
				return;
			}

			var param = {
				"inout_doc_no" : $M.getValue("origin_inout_doc_no")
			};

			$M.goNextPageAjax(this_page + "/remove", $M.toGetParam(param) , {method : 'POST'},
				function(result) {
					if(result.success) {
						if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
						alert("삭제가 완료되었습니다.");
						window.close();
					}
				}
			);
		}

	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" id="origin_inout_doc_no" name="origin_inout_doc_no" value="${originInoutDocInfo.origin_inout_doc_no}">
<input type="hidden" id="origin_doc_amt" name="origin_doc_amt" value="${originInoutDocInfo.origin_doc_amt}">
<input type="hidden" id="origin_vat_amt" name="origin_vat_amt" value="${originInoutDocInfo.origin_vat_amt}">
<input type="hidden" id="origin_total_amt" name="origin_total_amt" value="${originInoutDocInfo.origin_total_amt}">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<div class="doc-info" style="flex: 1;">
					<h4>전표분리</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px;"></div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5" style="margin-top: 50px;">
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