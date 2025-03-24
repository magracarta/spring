<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 영업부 업무일지 상세
-- 작성자 : 박준영
-- 최초 작성일 : 2020-06-30 13:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>


	<script type="text/javascript">
	
		var auiGridinner1;

		function createauiGridinner1() {
			var gridPros = {
				showRowNumColumn : true,
				// showTooltip: true,
			};

			var columnLayout = [
				{ 
					dataField : "cust_counsel_seq",
					visible : false
				},
				{
					dataField : "consult_dt",
					visible : false
				},
				{
					dataField : "mem_name",
					visible : false
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "100",
					minWidth : "90",
					style : "aui-center aui-popup"
				},
				// {
				// 	headerText : "상담구분",
				// 	dataField : "consult_case_name",
				// 	width : "60",
				// 	minWidth : "50",
				// 	style : "aui-center"
				// },
				{ 
					headerText : "상담시간", 
					dataField : "consult_ti",
					width : "100",
					minWidth : "90",
					style : "aui-center"
				},
				{
					headerText : "관심도",
					dataField : "consult_interest_name",
					width : "60",
					minWidth : "50",
					style : "aui-center"
				},
				{
					headerText : "구매계획",
					dataField : "consult_buy_plan_name",
					width : "80",
					minWidth : "50",
					style : "aui-center"
				},
				// {
				// 	headerText : "소요시간",
				// 	dataField : "consult_min",
				// 	width : "60",
				// 	minWidth : "50",
				// 	style : "aui-center"
				// },
				{ 
					headerText : "상담내용", 
					dataField : "consult_text",
					style : "aui-left",
					tooltip : {
						// show : true,
						// tooltipField : "consult_text",
						// tooltipFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						// 	return item["consult_text"].replaceAll("\n", "<br/>");
						// }
						useNativeTip : true,
					},
				}
			];


			auiGridinner1 = AUIGrid.create("#auiGridinner1", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridinner1, []);
			$("#auiGridinner1").resize();
			AUIGrid.bind(auiGridinner1, "cellClick", function(event) {
				if(event.dataField == 'cust_name'){				
					var params = {
						"cust_no" : event.item.cust_no,
						// "s_start_dt" : event.item.consult_dt,
						// "s_end_dt" : event.item.consult_dt,
						"s_machine_plant_seq" : event.item.machine_plant_seq,
						// 업무일지 상세(영업부) > 영업대상고객 > 고객명 클릭 시, 해당 모델의 모든 상담내역 도출 - 김경빈
						"s_dt_yn": "N",
					};
					$M.goNextPage('/cust/cust0101p05', $M.toGetParam(params), {popupStatus : ""});
										
				}
			});
			AUIGrid.showAjaxLoader("#auiGridinner1"); //로딩바 보이기
		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner1" style="margin-top: 5px; height: 280px;"></div>
	</div>
