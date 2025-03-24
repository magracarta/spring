<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 영업/관리/부품부 업무일지 상세
-- 작성자 : 박준영
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
	
		var auiGridinner2;

		function createauiGridinner2() {
			var gridPros = {
				showRowNumColumn : true
			};

			var columnLayout = [
				{ 
					dataField : "machine_doc_type_cd", 
					visible : false
				},
				{ 
					dataField : "display_org_name", 
					visible : false
				},
				{ 
					headerText : "관리번호", 
					dataField : "machine_doc_no", 
					style : "aui-center  aui-popup",
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
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = value;
						if (item.machine_doc_type_cd == "STOCK") {
							ret = item.display_org_name;
						} 
					    return ret; 
					},
					style : "aui-center"
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no",  
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value) {
						var ret = "";
						if (value != "") {
							ret = $M.phoneFormat(value);
						}
						return ret;
					},
				},
				
				{ 
					headerText : "메이커", 
					dataField : "maker_name", 
					style : "aui-center"
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					style : "aui-center"
				},
				{ 
					headerText : "인도예정", 
					dataField : "pending_receive_plan_dt", 
					dataType : "date",   
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "결재상신", 
					dataField : "request_appr_dt", 
					dataType : "date",   
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "결재상태", 
					dataField : "machine_doc_status_name", 
					style : "aui-center"
				},			
				{
					dataField : "machine_doc_status_cd",
					visible : false
				},
				{
					dataField : "doc_mem_no",
					visible : false
				}
			];

			auiGridinner2 = AUIGrid.create("#auiGridinner2", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridinner2, []);
			$("#auiGridinner2").resize();
			AUIGrid.bind(auiGridinner2, "cellClick", function(event) {
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
		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner2" style="margin-top: 5px; height: 280px;"></div>
	</div>