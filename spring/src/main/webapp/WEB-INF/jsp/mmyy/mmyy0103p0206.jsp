<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 영업/관리/부품부 업무일지 상세
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
	
		var auiGridinner6;

		function createauiGridinner6() {
			var gridPros = {
				showRowNumColumn : true,
				treeColumnIndex : 1,
				displayTreeOpen : true
			};

			var columnLayout = [
				{
					headerText : "등록일", 
					dataField : "reg_date", 
					dataType : "date",  
					formatString : "yyyy-mm-dd",
					width : "7%", 
					style : "aui-center"
				},
				{ 
					headerText : "관리번호", 
					dataField : "machine_no", 
					width : "12%", 
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (item["seq_depth"] == "1") {
							return "aui-popup"
						}
						return null;
					}
				},
				{ 
					headerText : "발주내역", 
					dataField : "machine_name", 
					width : "15%", 
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (item["machine_name"] != "") {
							return "aui-popup"
						}
						return null;
					}
				},
				{ 
					headerText : "수량", 
					dataField : "qty", 
					dataType : "numeric",
					width : "7%", 
					style : "aui-center",
				},
				{ 
					headerText : "금액", 
					dataField : "total_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%", 
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var desc_text = $M.numberFormat(value);
						if(item["seq_depth"] != "1") {
							desc_text = "-"
						}
						return desc_text;
					}
				},
				{ 
					headerText : "선적서류", 
					dataField : "file_check",
					width : "10%", 
					style : "aui-center",
				},
				{ 
					headerText : "입고센터", 
					dataField : "center_confirm_yn", 
					width : "10%", 
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var desc_text = value;
						if(item["seq_depth"] == "2" && item["center_confirm_yn"] == "Y") {
							desc_text = "확정"
						} else if (item["seq_depth"] == "1") {
							desc_text = "-"
						} else {
							desc_text = "미확정"
						}
						return desc_text;
					}
				},
				{ 
					headerText : "배차일시", 
					dataField : "car_date", 
					width : "10%", 
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var desc_text = AUIGrid.formatDate(value, "yyyy-mm-dd");
						if (item["seq_depth"] == "1") {
							desc_text = "-"
						} 
						return desc_text;
					}
				},
				{ 
					headerText : "기사번호", 
					dataField : "driver_hp_no", 
				 	labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							return fnGetHPNum(value);
						},
					style : "aui-center",
				},
				{ 
					headerText : "상태", 
					dataField : "status_name", 
					style : "aui-center",
				}
			];

			auiGridinner6 = AUIGrid.create("#auiGridinner6", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridinner6, []);
			$("#auiGridinner6").resize();
			AUIGrid.bind(auiGridinner6, "cellClick", function(event) {
				if(event.dataField == "machine_no") {
					console.log("event : ", event);
					if(event.item.seq_depth == "1") {
						var params = {
							machine_lc_no : event.item.machine_lc_no
						};
						var popupOption = "";
						$M.goNextPage('/sale/sale0203p01', $M.toGetParam(params), {popupStatus : popupOption});
					} 
				}
				
				if(event.dataField == "machine_name") {
					console.log("event : ", event);
					if (event.item.machine_name != "") {
						var params = {
							machine_lc_no : event.item.machine_lc_no,
						}
						var popupOption = "";
						$M.goNextPage("/sale/sale0203p05", $M.toGetParam(params), {popupStatus : popupOption});
					}
				}
			});	

		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner6" style="margin-top: 5px; height: 280px;"></div>
	</div>
