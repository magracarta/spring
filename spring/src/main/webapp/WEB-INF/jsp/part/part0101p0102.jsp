<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품조회 > 부품재고조회 > 부품재고상세 > 발주내역
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGridSecond();
			//AUIGrid.resize(auiGrid);
			// top.test();
		});
		
		
		
		function createAUIGridSecond() {
			var gridPros = {
					// rowNumber 
					showRowNumColumn: false,
					rowIdField : "_$uid",	
					/* height : 400,
					width : 1000 */
			};
			var columnLayout = [
				{ 
					headerText : "발주번호", 
					dataField : "part_order_no", 
					width : "140", 
					minWidth : "140", 
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if("${page.fnc.F00382_001}" == "Y") {
							return "aui-popup";
						} else {
							return "aui-center";
						}
					},
				},
				{ 
					headerText : "발주처리일", 
					dataField : "order_proc_dt", 
					width : "110", 
					minWidth : "110", 					
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "계약납기일", 
					dataField : "delivary_dt", 
					width : "110", 
					minWidth : "110", 	
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center",
				},
				{ 
					headerText : "입고예정일", 
					dataField : "in_plan_dt", 
					width : "110", 
					minWidth : "110", 	
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "입고확정일", 
					dataField : "in_fix_dt", 
					width : "110", 
					minWidth : "110", 	
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "입고예정수량", 
					dataField : "approval_qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "90", 
					minWidth : "90", 	
					style : "aui-center"
				},
				{ 
					headerText : "요청처(센터)", 
					dataField : "order_org_name", 
					width : "110", 
					minWidth : "100", 	
					style : "aui-center"
				},
				{ 
					headerText : "비고", 
					dataField : "memo", 
					width : "340", 
					minWidth : "340", 	
					style : "aui-left"
				}
			]
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${list});
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var popupOption = "";
				var param = {};
				// 금액도 있으므로 권한자만.

				if(event.dataField == "part_order_no" && "${page.fnc.F00382_001}" == "Y") {
					param.part_order_no = event.item["part_order_no"];
					$M.goNextPage('/part/part0403p01', $M.toGetParam(param), {popupStatus : popupOption});
				}
			});	
			$("#auiGrid").resize();
		}

		// [재호] [3차-Q&A 16088] 부품재고조회 수정으로 인한 메인 페이지로 이동
		// 부품발주요청
		<%--function goOrderPart() {--%>
		<%--	var param = {--%>
		<%--			"part_no" : "${inputParam.part_no}"--%>
		<%--	};--%>
		<%--	openOrderPartPanel('setPartRequestInfo', $M.toGetParam(param));--%>
		<%--}--%>

		// function setPartRequestInfo() {
		// 	location.reload();
		// }
		
		//팝업 끄기
		function fnClose() {
			top.fnClose();
		}
	
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <div class="content-wrap">	
<!-- 발주내역 -->
				<div style="width: 100%">
					<div class="title-wrap mt10">
						<h4>발주내역</h4>
					</div>
				</div>
				<div>
					<div id="auiGrid" style="margin-top: 5px; height: 500px; width:100%"></div>
				</div>
<!-- /발주내역 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5 custheight">		
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건 
						</div>				
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- /발주요청 -->				
			</div>
        </div>
<!-- /팝업 -->
</form>
</body>
</html>