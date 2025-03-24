<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 부품부 업무일지 상세
-- 작성자 : 박예진
-- 최초 작성일 : 2021-04-29 09:40:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
		var auiGridinner5;
		/* $(document).ready(function() {
			createauiGridinner5();
		}); */


		function createauiGridinner5() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "처리일자",
				    dataField: "complete_date",
				    dataType : "date",   
					width : "95",
					minWidth : "95",
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
// 				{
// 				    headerText: "이동요청번호",
// 				    dataField: "part_trans_req_no",
// 					width : "120",
// 					minWidth : "120",
// 					style : "aui-center",
// 					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
// 						if (value != "") {
// 							return "aui-popup"
// 						};
// 						return null;
// 					},
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						var docNo = value;
// 						return docNo.substring(4, 16);
// 					}
// 				},
				{
				    headerText: "이동처리번호",
				    dataField: "part_trans_no",
					width : "120",
					minWidth : "120",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value != "") {
							return "aui-popup"
						};
						return null;
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					}
				},
// 				{
// 				    headerText: "부품명",
// 				    dataField: "part_name",
// 					width : "270",
// 					minWidth : "270",
// 					style : "aui-left"
// 				},
// 				{
// 				    headerText: "요청센터",
// 				    dataField: "to_warehouse_name",
// 					width : "75",
// 					minWidth : "75",
// 					style : "aui-center"
// 				},
// 				{
// 				    headerText: "이동요청<br>상태",
// 				    dataField: "end_yn",
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						var result = "미마감";
// 						if(item["end_yn"] == "Y") {
// 							result = "마감";
// 						} else if (item["end_yn"] == "" && item["part_trans_status_cd"] == "04") {
// 							result = "마감";
// 						}
// 				    	return result;
// 					},
// 					width : "55",
// 					minWidth : "55",
// 					style : "aui-center"
// 				},
				{
				    headerText: "From",
				    dataField: "from_warehouse_name",
					width : "100",
					minWidth : "100",
					style : "aui-center"
				},
				{
				    headerText: "To",
				    dataField: "to_warehouse_name",
					width : "100",
					minWidth : "100",
					style : "aui-center"
				},
				{
				    headerText: "처리자",
				    dataField: "reg_mem_name",
					width : "80",
					minWidth : "80",
					style : "aui-center"
				},
// 				{
// 				    headerText: "발송구분",
// 				    dataField: "invoice_send_name",
// 					width : "75",
// 					minWidth : "75",
// 					style : "aui-center aui-popup"
// 				},
// 				{
// 				    headerText: "발송구분 code",
// 				    dataField: "invoice_send_cd",
// 				    visible : false,
// 					style : "aui-center"
// 				},
// 				{
// 				    headerText: "송장타입코드",
// 				    dataField: "invoice_type_cd",
// 				    visible : false,
// 					style : "aui-center"
// 				},
				{
				    headerText: "비고",
				    dataField: "remark",
					width : "370",
					minWidth : "370",
					style : "aui-left"
				},
// 				{
// 				    headerText: "이동처리<br>상태",
// 				    dataField: "part_trans_status_name",
// 				    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 				    	return $M.nvl(value, '00') == '00' ? "요청전" : value;
// 					},
// 					width : "55",
// 					minWidth : "55",
// 					style : "aui-center"
// 				},
				{
				    dataField: "part_trans_status_cd",
				    visible : false,
				},
				{
				    dataField: "send_invoice_seq",
				    visible : false,
				},
				{
				    dataField: "invoice_send_cd",
				    visible : false,
				},
				{
				    dataField: "invoice_type_cd",
				    visible : false,
				},
				{
				    dataField: "invoice_warehouse",
				    visible : false,
				},
				{
				    dataField: "invoice_no",
				    visible : false,
				},
				{
				    dataField: "invoice_qty",
				    visible : false,
				},
				{
				    dataField: "receive_tel_no",
				    visible : false,
				},
				{
				    dataField: "receive_hp_no",
				    visible : false,
				},
				{
				    dataField: "invoice_remark",
				    visible : false,
				},
				{
				    dataField: "invoice_money_cd",
				    visible : false,
				},
				{
				    dataField: "invoice_post_no",
				    visible : false,
				},
				{
				    dataField: "invoice_addr1",
				    visible : false,
				},
				{
				    dataField: "invoice_addr2",
				    visible : false,
				},
				{
				    dataField: "receive_name",
				    visible : false,
				},
			];
			auiGrid = AUIGrid.create("#auiGridinner5", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGridinner5").resize();
			
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(event.value == "") {
 					return;
 				};
 				
 				if(event.dataField == "part_trans_no") {
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=600, left=0, top=0";
 					var param = {
 						"part_trans_no" : event.item.part_trans_no,
 					}
					$M.goNextPage("/part/part0202p03", $M.toGetParam(param), {popupStatus : popupOption});
 					
 				} else if(event.dataField == "part_trans_req_no") {
 					if(event.item.part_trans_no == '' && event.item.end_yn == 'Y') {
 						alert('마감된 자료는 열람이 불가능 합니다.');
 						return;
 					};
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=620, left=0, top=0";
 					var param = {
 						"part_trans_req_no" : event.item.part_trans_req_no,
 					}
					$M.goNextPage("/part/part0202p01", $M.toGetParam(param), {popupStatus : popupOption});
 				}
 				else if(event.dataField == "invoice_send_name") {
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=660, left=0, top=0";
 					var param = {
		    			invoice_type_cd 	: event.item.invoice_type_cd,
		    			invoice_money_cd	: event.item.invoice_money_cd,
		    			invoice_send_cd 	: event.item.invoice_send_cd,
		    			receive_name 		: event.item.receive_name,
		    			invoice_no 			: event.item.invoice_no,
		    			receive_hp_no 		: event.item.receive_hp_no,
		    			receive_tel_no 		: event.item.receive_tel_no,
		    			qty 				: event.item.invoice_qty,
		    			remark 				: event.item.invoice_remark,
		    			post_no 			: event.item.invoice_post_no,
		    			addr1				: event.item.invoice_addr1,
		    			addr2				: event.item.invoice_addr2,
		    			show_yn				: 'Y',
					}

					$M.goNextPage("/cust/cust0201p02", $M.toGetParam(param), {popupStatus : popupOption});
 				};
			});
		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner5" style="margin-top: 5px;"></div>
	</div>
