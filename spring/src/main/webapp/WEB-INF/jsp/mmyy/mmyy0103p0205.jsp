<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 영업/관리/부품부 업무일지 상세
-- 작성자 : 박준영
-- 최초 작성일 : 2020-10-20 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
	
		var auiGridinner5;

		function createauiGridinner5() {
			var gridPros = {
				showRowNumColumn : true,
				showFooter : true,
				footerPosition : "top"
			};

			var columnLayout = [
				{
					headerText : "관리번호", 
					dataField : "machine_doc_no", 
					width : "12%",
					style : "aui-center aui-popup",
					labelFunction : function(rowIndex, columnIndex, value) {
						var ret = "";
						if (value != "") {
							var arr = value.split("-");
							ret = arr[0]+"-"+arr[1]
						}
						return ret;
					},
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "12%",
					style : "aui-center"
				},
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					width : "12%",
					style : "aui-center"
				},
				{ 
					headerText : "구분", 
					dataField : "machine_pay_type_name", 
					width : "12%",
					style : "aui-center",
				},
				{ 
					headerText : "입금처리금액", 
					dataField : "deposit_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "12%",
					style : "aui-right",
				},
				{
					headerText : "입금일자",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					dataField : "deposit_dt"
				},
				{
					headerText : "입금처리일시",
					dataField : "reg_date"
				},
				{ 
					headerText : "비고", 
					dataField : "remark", 
					style : "aui-left",
				},
				{ 
					dataField : "doc_org_code", 
					visible : false
				}
			];

			auiGridinner5 = AUIGrid.create("#auiGridinner5", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridinner5, []);
			$("#auiGridinner5").resize();
			AUIGrid.bind(auiGridinner5, "cellClick", function(event) {
				if(event.dataField == 'machine_doc_no'){				
					var param = {
							machine_doc_no : event.item.machine_doc_no
						}
						var poppupOption = "";
						var url = '/sale/sale0101p01';
						if (event.item.machine_doc_type_cd == "STOCK") {
							url = '/sale/sale0101p09';
						} 
						$M.goNextPage(url, $M.toGetParam(param), {popupStatus : poppupOption});									
				}
			});

			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					colSpan : 4,
					positionField : "machine_doc_no"
				},
				{
					dataField: "deposit_amt",
					positionField: "deposit_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				}

			];
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGridinner5, footerLayout);
		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner5" style="margin-top: 5px; height: 280px;"></div>
	</div>
