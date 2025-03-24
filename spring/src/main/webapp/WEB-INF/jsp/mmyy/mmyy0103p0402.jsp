<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 부품부 업무일지 상세
-- 작성자 : 박예진
-- 최초 작성일 : 2021-04-29 09:40:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
		var auiGridinner2;
		/* $(document).ready(function() {
			createauiGridinner2();
		}); */

		function createauiGridinner2() {
			//그리드 생성 _ 선택사항
			var gridPros = {
				rowIdField : "_$uid",
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				// rowNumber 
				showRowNumColumn: true,
				editable : false,
				showSelectionBorder : false
			};
			var columnLayout = [
				{ 
					headerText : "전표번호", 
					dataField : "inout_doc_no",
					width : "100",
					minWidth : "100",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					},
					style : "aui-center aui-popup"
				},
				{ 
					headerText : "부품명", 
					dataField : "item_name",
					width : "250",
					minWidth : "250",
					style : "aui-left",
				},
				{
					headerText : "매입처", 
					dataField : "client_cust_name", 
					width : "150",
					minWidth : "150",
					style : "aui-center",
				},
				{ 
					headerText : "금액", 
					dataField : "amt", 
					dataType : "numeric",
					formatString : "#,##0", 
					width : "95",
					minWidth : "95",
					style : "aui-right",
				},
				{ 
					headerText : "비고", 
					dataField : "desc_text",
					width : "400",
					minWidth : "400",
					style : "aui-left",
				},
				{ 
					headerText : "매입자", 
					dataField : "reg_mem_name",
					width : "75",
					minWidth : "75",
					style : "aui-center",
				},
				{ 
					headerText : "계약납기일", 
					dataField : "delivary_dt",
					dataType : "date",
					formatString : "yy-mm-dd", 
					width : "75",
					minWidth : "75",
					style : "aui-center",
				},
				{ 
					headerText : "발주일자", 
					dataField : "order_proc_dt",
					dataType : "date",
					formatString : "yy-mm-dd", 
					width : "75",
					minWidth : "75",
					style : "aui-center",
				},
				{ 
					headerText : "발주번호", 
					dataField : "part_order_no", 
					width : "110",
					minWidth : "110",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var orderNo = value;
						return orderNo.substring(4, 16);
					},
				},
			];

			auiGrid = AUIGrid.create("#auiGridinner2", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			$("#auiGridinner2").resize();
			
			AUIGrid.bind("#auiGridinner2", "cellClick", function(event) {
				if(event.dataField == "inout_doc_no") {
					var params = {
						"inout_doc_no" : event.item.inout_doc_no
					};

					var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1060, height=690, left=0, top=0";
					$M.goNextPage("/part/part0302p05", $M.toGetParam(params), {popupStatus : poppupOption});
				} 
// 				else if (event.dataField == "part_order_no") {
// 					var param = {
// 							part_order_no : event.item.part_order_no
// 					};
// 					var poppupOption = "";
// 					$M.goNextPage('/part/part0403p01', $M.toGetParam(param), {popupStatus : poppupOption});
// 				}
 			});
		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner2" style="margin-top: 5px;"></div>
	</div>
