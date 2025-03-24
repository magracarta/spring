<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 부품부 업무일지 상세
-- 작성자 : 박예진
-- 최초 작성일 : 2021-04-29 09:40:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
		var auiGridinner6;

		function createauiGridinner6() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColum : true,
				headerHeight : 40
			};
			
			var columnLayout = [
				{ 
					headerText : "처리일시", 
					dataField : "reg_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "65",
					minWidth : "65",
				},
				{
					headerText : "전표번호",
					dataField : "doc_no",
					width : "60",
					minWidth : "60",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						var docNoArr = docNo.split('-');
						docNo = docNoArr[docNoArr.length-1];
						
						return docNo;
					},
					style : "aui-center aui-popup"
				},
				{
					headerText : "고객명<br>(받는사람)",
					dataField : "send_name",
					width : "110",
					minWidth : "110",
					style : "aui-center"
				},
				{
					headerText : "휴대폰<br>(받는사람)",
					dataField : "receive_hp_no",
					width : "100",
					minWidth : "100",
					style : "aui-center"
				},
				{
					headerText : "발송지",
					dataField : "send_addr",
					width : "250",
					minWidth : "250",
					style : "aui-left"
				},
				{
					headerText : "송장번호",
					dataField : "invoice_no",
					width : "90",
					minWidth : "90",
					style : "aui-center"
				},
				{
					headerText : "발송사업장",
					dataField : "send_out_dept_name",
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{
					headerText : "발송구분",
					dataField : "invoice_send_name",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{
					headerText : "발송상태",
					dataField : "invoice_send_status_name",
					width : "55",
					minWidth : "55",
					style : "aui-center"
				},
				{
					headerText : "배송구분",
					dataField : "invoice_money_name",
					width : "55",
					minWidth : "55",
					style : "aui-center"
				},
				{
					headerText : "배송비",
					dataField : "delivery_fee",
					width : "70",
					minWidth : "70",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "처리자",
					dataField : "inout_mem_name",
					width : "50",
					minWidth : "50",
					style : "aui-center"
				},
				{
					headerText : "고객명<br>(구매자)",
					dataField : "receive_name",
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{
					headerText : "휴대폰<br>(구매자)",
					dataField : "send_hp_no",
					width : "100",
					minWidth : "100",
					style : "aui-center"
				},
				{
					headerText : "전표비고",
					dataField : "view_remark",
					width : "180",
					minWidth : "180",
					style : "aui-left"
				},
				{
					headerText : "전표마감",
					dataField : "day_end",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{
					headerText : "전표바코드",
					dataField : "doc_barcode_no",
					visible : false
				},
				{
					headerText : "송장타입코드",
					dataField : "invoice_type_cd",
					visible : false
				},
				{
					headerText : "품의서구분코드",
					dataField : "inout_doc_type_cd",
					visible : false
				},
				{
					headerText : "고객번호",
					dataField : "receive_cust_no",
					visible : false
				},
				{
					headerText : "송장발송번호",
					dataField : "send_invoice_seq",
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGridinner6", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGridinner6").resize();

			AUIGrid.bind(auiGrid, "cellClick", function(event){
				if(event.dataField == "doc_no") {
					var params = {
						"doc_barcode_no" : event.item.doc_barcode_no
					};

					var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=480, left=0, top=0";
					$M.goNextPage('/part/part0203p01', $M.toGetParam(params), {popupStatus : popupOption});
				}

// 				if(event.dataField == "invoice_send_name") {
// 					goSearchSendInvoice(event.item);
// 				}
			});
		}
		
		function goSearchSendInvoice(item) {
			var sendInvoiceSeq = item.send_invoice_seq;
			var params = {
				"s_send_invoice_seq" : sendInvoiceSeq
			}

			$M.goNextPageAjax(this_page + "/invoice/search", $M.toGetParam(params), {method : 'GET'},
					function(result) {
						if(result.success) {
							goDeliveryInfo(result.bean);
						}
					}
			);
		}

		function goDeliveryInfo(bean) {
			var invoiceNo = typeof bean.invoice_no == "undefined" ? "" : bean.invoice_no;
			var remark = typeof bean.remark == "undefined" ? "" : bean.remark;
			var receiveTelNo = typeof bean.receive_tel_no == "undefined" ? "" : bean.receive_tel_no;
			var postNo = typeof bean.post_no == "undefined" ? "" : bean.post_no;
			var addr1 = typeof bean.addr1 == "undefined" ? "" : bean.addr1;
			var addr2 = typeof bean.addr2 == "undefined" ? "" : bean.addr2;

			var params = {
				"cust_no" : bean.cust_no,
				"invoice_type_cd" : bean.invoice_type_cd,
				"invoice_money_cd" : bean.invoice_money_cd,
				"invoice_send_cd" : bean.invoice_send_cd,
				"receive_name" : bean.receive_name,
				"invoice_no" : invoiceNo,
				"receive_hp_no" : $M.phoneFormat(bean.receive_hp_no),
				"receive_tel_no" : receiveTelNo,
				"qty" : bean.qty,
				"remark" : remark,
				"post_no" : postNo,
				"addr1" : addr1,
				"addr2" : addr2,
				"show_yn" : "Y"
			};

			openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(params));
		}

		function setDeliveryInfo() {
		}
		
</script>

	<div  class="mt10">
		<div id="auiGridinner6" style="margin-top: 5px;"></div>
	</div>
