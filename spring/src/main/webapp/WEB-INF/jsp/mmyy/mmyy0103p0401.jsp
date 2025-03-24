<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 부품부 업무일지 상세
-- 작성자 : 박예진
-- 최초 작성일 : 2021-04-28 19:11:05
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
		var auiGridinner1;

		function createauiGridinner1() {
			var gridPros = {
					showRowNumColumn : true,
					rowCheckableFunction : function(rowIndex, isChecked, item) {
						if(item.part_order_status_cd != "3" && item.part_order_status_cd != "9") {
							alert("진행상태가 \"발주\"인 자료만 선택 가능합니다.");
							return false;
						}
						return true;
					},
					
				};
			var columnLayout = [
				{
					dataField : "part_order_no",
					visible : false
				},
				{ 
					headerText : "발주번호", 
					dataField : "dis_part_order_no", 
					style : "aui-popup",
					width : "95",
					minWidth : "95",
				},
				{
					dataField : "part_order_status_cd",
					visible : false
				},
				{ 
					headerText : "발주등록일", 
					dataField : "reg_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "75",
				},
				{ 
					headerText : "발주처리일", 
					dataField : "order_proc_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "75",
				},
				{ 
					headerText : "발주처", 
					dataField : "cust_name", 
					width : "125",
					minWidth : "125",
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					style : "aui-left",
					width : "190",
					minWidth : "190",
				},
				{ 
					headerText : "적요", 
					dataField : "desc_text",
					style : "aui-left",
					width : "180",
					minWidth : "180",
				},
				{ 
					headerText : "금액", 
					dataField : "total_amt", 
					width : "95",
					minWidth : "95",
					dataType : "numeric",
					style : "aui-right"
				},
				{ 
					headerText : "담당자", 
					dataField : "reg_mem_name", 
					width : "65",
					minWidth : "65",
				},
				{ 
					headerText : "결재", 
					dataField : "path_mem_appr_status_name",
					style : "aui-left",
					width : "240",
					minWidth : "100",
				},
				{ 
					headerText : "상태", 
					dataField : "part_order_status_name", 
					width : "85",
					minWidth : "55"
				},
				{ 
					headerText : "센터부품할당", 
					dataField : "warehouse_name", 
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var temp = value == "" || value == null ? "" : value.split("|");
						if (temp.length > 1) {
							temp = temp[0] + " 외 "+(temp.length-1)+"건"; 
						} 
			            return temp;
					},
					width : "120",
					minWidth : "120"
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGridinner1", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == 'dis_part_order_no'){
					var param = {
							part_order_no : event.item.part_order_no
					};
					var poppupOption = "";
					$M.goNextPage('/part/part0403p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
		}
	</script>


	<div  class="mt10">
		<div id="auiGridinner1" style="margin-top: 5px;"></div>
	</div>

