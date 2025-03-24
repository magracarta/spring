<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 영업/관리/부품부 업무일지 상세
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
	
		var auiGridinner3;
		
		/* $(document).ready(function() {
			createauiGridinner3();
		}); */

		function createauiGridinner3() {
			var gridPros = {
				showRowNumColumn : true
			};

			var columnLayout = [
				{
					headerText : "발행일자", 
					dataField : "taxbill_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "10%",
					style : "aui-center"
				},
				{
					dataField : "taxbill_doc_type_cd",
					visible : false
				},
				{ 
					headerText : "부서", 
					dataField : "org_name", 
					width : "10%",
					style : "aui-center",
				},
				{
					dataField : "org_code",
					visible : false
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "10%",
					style : "aui-center",
				},
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					width : "10%",
					style : "aui-center"
				},
				{ 
					headerText : "물품대", 
					dataField : "taxbill_amt",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{ 
					headerText : "적요", 
					dataField : "desc_text",
					width : "20%",
					style : "aui-left"
				},
				{ 
					headerText : "자료구분", 
					dataField : "issu_yn",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == "Y" ? "발행" : "가발행";
					}
				},
				{ 
					headerText : "처리결과", 
					dataField : "err_msg",
					width : "20%",
					style : "aui-left"
				},
				{
					dataField : "issu_mem_no",
					visible : false
				},
				{
					dataField : "taxbill_type_cd",
					visible : false
				},
				{
					dataField : "issu_status_yn",
					visible : false
				},
				{
					dataField : "account_link_cd",
					visible : false
				},
				{
					dataField : "end_yn",
					visible : false
				},
				{
					dataField : "inout_doc_type_cd",
					visible : false
				}
			];

			auiGridinner3 = AUIGrid.create("#auiGridinner3", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setGridData(auiGridinner3, []);
			$("#auiGridinner3").resize();
			AUIGrid.bind(auiGridinner3, "cellClick", function(event) {
				if(event.dataField == "taxbill_no" ) {
					var params = {
							"taxbill_no" : event.item["taxbill_no"]
					};
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=750, left=0, top=0";
					$M.goNextPage('/acnt/acnt0301p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	

		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner3" style="margin-top: 5px;"></div>
	</div>
