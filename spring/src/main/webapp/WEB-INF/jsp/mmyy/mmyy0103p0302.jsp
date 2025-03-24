<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 관리부 업무일지 상세
-- 작성자 : 박준영
-- 최초 작성일 : 2020-10-21 15:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
		var auiGridinner2;
		/* $(document).ready(function() {
			createauiGridinner2();
		}); */

		function createauiGridinner2() {

			var gridPros = {
					rowIdField : "inout_doc_no",
					showStateColumn : false,
					// No. 제거
					showRowNumColumn: true,
				};
				var columnLayout = [
					{
						headerText : "부서", 
						dataField : "org_name", 
						width : "8%",
						style : "aui-center"
					},
					{ 
						headerText : "전표번호", 
						dataField : "inout_doc_no", 
						width : "10%",
						style : "aui-center aui-popup"
					},
					{ 
						headerText : "고객명", 
						dataField : "cust_name", 
						width : "10%",
						style : "aui-center aui-popup",
					},
					{ 
						headerText : "전표구분", 
						dataField : "inout_type_name", 
						width : "8%",
						style : "aui-center aui-popup",
					},
					{ 
						headerText : "내용", 
						dataField : "dis_desc_text", 
						width : "25%",
						style : "aui-left"
					},
					{ 
						headerText : "물품대", 
						dataField : "doc_amt",
						dataType : "numeric",
						formatString : "#,##0",
						style : "aui-right"
					},
					{ 
						headerText : "요청", 
						dataField : "vat_treat_cd",
						style : "aui-center",
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							var vatTreatName = "";
							if(value == "Y") {
								vatTreatName = "세금";
							} else if (value == "R") {
								vatTreatName = "보류";
							} else if (value == "S") {
								vatTreatName = "합산";
							} else if (value == "F" && item.taxbill_send_cd == "5") {
								vatTreatName = "수정";
							} else if (value == "C") {
								vatTreatName = "카드매출";
							} else if (value == "A") {
								vatTreatName = "현금영수증";
							} else if (value == "N") {
								vatTreatName = "무증빙";
							}
							return vatTreatName;
						}
					},
					{
						headerText : "회계전송", 
						dataField : "duzon_trans_date",
						dataType : "date",
						width : "15%",
						formatString : "yy-mm-dd HH:MM:ss",
						style : "aui-center"
					},
					{
						dataField : "inout_org_code",
						visible : false
					},
					{
						dataField : "org_code",
						visible : false
					},
					{
						dataField : "inout_type_code",
						visible : false
					},
					{
						dataField : "acc_type_cd",
						visible : false
					},
					{
						dataField : "mem_no",
						visible : false
					},
					{
						dataField : "end_yn",
						visible : false
					},
					{
						dataField : "duzon_trans_yn",
						visible : false
					},
					{
						dataField : "account_link_cd",
						visible : false
					},
					{
						dataField : "cust_no",
						visible : false
					}
				];
				
				auiGridinner2 = AUIGrid.create("#auiGridinner2", columnLayout, gridPros);
				AUIGrid.setGridData(auiGridinner2, []);
				$("#auiGridinner2").resize();
				// 발주내역 클릭시 -> 발주서상세 팝업 호출
				AUIGrid.bind(auiGridinner2, "cellClick", function(event) {
					var popupOption = "";
					if(event.dataField == "inout_type_name" ) {
						var param = {
							"inout_doc_no" : event.item["inout_doc_no"]
						};
						if(event.item["inout_type_cd"] == "04") {
							// 매출처리 팝업 (매출처리상세?)
							$M.goNextPage('/cust/cust0202p01', $M.toGetParam(param), {popupStatus : popupOption});
							
						} else if(event.item["inout_type_cd"] == "06") {
							// 매입처리팝업
							$M.goNextPage('/part/part0302p01', $M.toGetParam(params), {popupStatus : popupOption});
							
						} else if(event.item["inout_type_cd"] == "01" || event.item["inout_type_cd"] == "02") {
							$M.goNextPage('/cust/cust0203p01', $M.toGetParam(param), {popupStatus : popupOption});
							
						}
					}
					if(event.dataField == "inout_doc_no" ) {
						// 전표세부내역
						var param = {
								"inout_doc_no" : event.item["inout_doc_no"]
						};
						$M.goNextPage('/cust/cust0302p01', $M.toGetParam(param), {popupStatus : popupOption});
						
					}
					
					if(event.dataField == "cust_name" ) {
						// 거래원장상세
						var params = {
								"s_cust_no" : event.item["cust_no"],
								"s_start_dt" : $M.getValue("s_start_dt"),
								"s_end_dt" : $M.getValue("s_end_dt"),
						};
						openDealLedgerPanel($M.toGetParam(params));
						
					}
				});	
		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner2" style="margin-top: 5px;"></div>
	</div>
