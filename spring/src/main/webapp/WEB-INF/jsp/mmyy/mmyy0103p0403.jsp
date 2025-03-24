<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 부품부 업무일지 상세
-- 작성자 : 박예진
-- 최초 작성일 : 2021-04-29 09:40:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
	
		var auiGridinner3;
		
		/* $(document).ready(function() {
			createauiGridinner3();
		}); */

		function createauiGridinner3() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
			};
			var columnLayout = [
				{ 
					headerText : "전표번호", 
					dataField : "inout_doc_no", 
					style : "aui-center aui-popup",
					width : "90",
					minWidth : "90",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					}
				},
				{ 
					headerText : "전표구분", 
					dataField : "inout_doc_type_cd", 
					width : "70",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var inoutDocTypeName = "";
						if(value == "05") {
							inoutDocTypeName = "수주";
						} else if (value == "07") {
							inoutDocTypeName = "정비";
						} else if (value == "11") {
							inoutDocTypeName = "렌탈"
						}
						return inoutDocTypeName;
					}
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "130",
					minWidth : "130",
					style : "aui-center",
				},
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					width : "140",
					minWidth : "130",
					style : "aui-center",
				},
				{ 
					headerText : "적요", 
					dataField : "dis_desc_text", 
					width : "290",
					minWidth : "200",
					style : "aui-left",
				},
				{ 
					headerText : "금액", 
					dataField : "total_amt",  
					dataType : "numeric",
					formatString : "#,##0",
					width : "95",
					minWidth : "95",
					style : "aui-right",
				},
				{ 
					headerText : "처리구분", 
					dataField : "vat_treat_cd", 
					width : "80",
					minWidth : "70",
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
					headerText : "처리자", 
					dataField : "mem_name", 
					width : "70",
					minWidth : "60",
					style : "aui-center",
				},
				{ 
					dataField : "mem_no", 
					visible : false
				},
				{ 
					headerText : "계산서발행일", 
					dataField : "taxbill_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "80",
					minWidth : "80",
					style : "aui-center",
				},
				{ 
					headerText : "미수금", 
					dataField : "misu_amt",  
					dataType : "numeric",
					formatString : "#,##0",
					width : "100",
					minWidth : "100",
					style : "aui-right",
				},
				{ 
					headerText : "비고", 
					dataField : "dis_remark", 
					headerStyle : "aui-fold",
					style : "aui-left",
					width : "200",
					minWidth : "195"
				}
			];
			auiGrid = AUIGrid.create("#auiGridinner3", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGridinner3").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "inout_doc_no" ) {
					var params = {
							"inout_doc_no" : event.item["inout_doc_no"]
					};
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
					$M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner3" style="margin-top: 5px;"></div>
	</div>
