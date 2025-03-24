<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 부품부 업무일지 상세
-- 작성자 : 박예진
-- 최초 작성일 : 2021-04-29 09:40:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
		var auiGridinner4;
		/* $(document).ready(function() {
			createauiGridinner4();

		}); */


		function createauiGridinner4() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false

			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "요청번호",
				    dataField: "part_adjust_no",
					style : "aui-center aui-popup"
				},
				{
					headerText : "등록일",
					dataField : "reg_dt",
					style : "aui-center"
				},
				{
				    headerText: "요청센터",
				    dataField: "warehouse_name",
					style : "aui-center"
				},
				{
				    dataField: "warehouse_cd",
					visible : false
				},
				{
				    headerText: "작성자",
				    dataField: "reg_mem_name",
					style : "aui-center"
				},
				{
				    headerText: "품목수",
				    dataField: "adjust_qty",
					style : "aui-center"
				},
				{
					dataField : "appr_proc_status_cd",
					visible : false
				},
				{
				    headerText: "상태",
				    dataField: "appr_proc_status_name",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return (item.appr_proc_status_cd == '05') ? '반영완료' : value; 
					}
				},
				{
				    headerText: "결재요청일",
				    dataField: "appr_req_dt",
					dataType : "date",   
					formatString : "yyyy-mm-dd",			    
					style : "aui-center"
				},
				{
				    headerText: "반영일",
				    dataField: "adjust_dt",
					dataType : "date",   
					formatString : "yyyy-mm-dd",	
					style : "aui-center"
				},
				{
				    headerText: "내용",
				    dataField: "count_remark",
				    width: "20%",
					style : "aui-left"
				},
				{
				    headerText: "비고",
				    dataField: "remark",
				    width: "25%",
					style : "aui-left"
				},
			];
			

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGridinner4", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(event.dataField == "part_adjust_no") {
 					
 					var param = {
 							"part_adjust_no" : event.item.part_adjust_no
 					};	
 				
 					var popupOption = "";
 					$M.goNextPage('/part/part0505p01', $M.toGetParam(param), {popupStatus : popupOption});

 				}
			});		
		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner4" style="margin-top: 5px;"></div>
	</div>
