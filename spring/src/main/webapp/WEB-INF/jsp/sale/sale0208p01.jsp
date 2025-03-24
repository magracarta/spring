<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 선적일정공유표 > null > LC오픈
-- 작성자 : 이강원
-- 최초 작성일 : 2021-08-06 16:12:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function(){
			createAUIGrid();
		})
		
		function createAUIGrid(){
			var gridPros = {
	                rowIdField: "_$uid",
	                showStateColumn: true,
	                editable: false,
            };
            var columnLayout = [
            	{
					headerText : "등록일", 
					dataField : "reg_date", 
					dataType : "date",  
					formatString : "yy-mm-dd",
					width : "65",
					minWidth : "30",
					style : "aui-center"
				},
				{ 
					headerText : "관리번호", 
					dataField : "machine_no", 
					width : "160",
					minWidth : "80",
					style : "aui-left",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if (item["seq_depth"] == "1") {
							return value.substring(4);
						}
						return value;
					}
				},
				{ 
					headerText : "발주처", 
					dataField : "cust_name", 
					width : "110",
					minWidth : "30",
					style : "aui-center"
				},
				{ 
					headerText : "발주내역", 
					dataField : "machine_name", 
					width : "200",
					minWidth : "30", 
					style : "aui-left",
				},
				{ 
					headerText : "참고", 
					dataField : "desc_text", 
					width : "130",
					minWidth : "30",
					style : "aui-left",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var desc_text = value;
						if(item["seq_depth"] != "1") {
							desc_text = "-"
						}
						return desc_text;
					}
				},
				{ 
					headerText : "수량", 
					dataField : "qty", 
					dataType : "numeric",
					width : "40",
					minWidth : "30",
					style : "aui-center",
				},
				{ 
					headerText : "금액", 
					dataField : "total_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "100",
					minWidth : "30",
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
					headerText : "화폐단위", 
					dataField : "money_unit_cd", 
					width : "70",
					minWidth : "70",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var desc_text = value;
						if(item["seq_depth"] != "1") {
							desc_text = "-"
						}
						return desc_text;
					}
				},
				{
					headerText : "송금처리일시",
					dataField : "remit_proc_date",
					visible : false,
				},
				{
					dataField : "link_check",
					visible : false,
				},
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, ${lcList});

            // 셀 클릭 이벤트
            AUIGrid.bind(auiGrid, "cellClick", function(event){
            	if(event.item.link_check == 'Y'){
            		alert("이미 연결된 선적일정이 있습니다.");
            		return false;
            	}
            	
				if(event.dataField == "machine_no"){
					opener.${inputParam.parent_js_name}(event.item,${inputParam.column_index});
					window.close();
				}
            });
		}
		
		function fnClose(){
			window.close();
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 메인 타이틀 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /메인 타이틀 -->
		<div class="content-wrap">
			<div>
				<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap">
					<h4>LC-Open 내역</h4>
				</div>
				<!-- /그리드 타이틀, 컨트롤 영역 -->
				<div id="auiGrid" style="height:555px; margin-top: 5px;"></div>
			</div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt" >${total_cnt}</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
<!-- /팝업 -->
</form>
</body>
</html>