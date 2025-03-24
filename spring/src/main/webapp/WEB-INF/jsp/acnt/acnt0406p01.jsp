<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 출하시임의비용처리 > null > 출하종결목록
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				enableFilter :true
			};
			var columnLayout = [
				{
					headerText : "관리번호", 
					dataField : "machine_doc_no", 
					width : "15%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "출하일자", 
					dataField : "out_dt", 
					width : "13%",
					editable : false,
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "판매자", 
					dataField : "reg_mem_name", 
					width : "11%",
					editable : false,
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					editable : false,
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no",
					width : "13%",
					editable : false,
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "차주명", 
					dataField : "machine_cust_name",
					width : "11%",
					editable : false,
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "11%",
					editable : false,
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "연락처", 
					dataField : "hp_no", 
					width : "16%",
					editable : false,
					style : "aui-center",
					filter : {
						showIcon : true
					}
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			// AUIGrid.setGridData(auiGrid, testData);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// Row행 클릭 시 반영
				try{
					opener.fnSetOppCost(event.item);
					window.close();	
				} catch(e) {
					alert('호출 페이지에서 fnSetOppCost(row) 함수를 구현해주세요.');
				}
			});
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<%-- <input type="hidden" id="s_start_dt" name="s_start_dt" value="${inputParam.s_start_dt}"> --%>
<%-- <input type="hidden" id="s_end_dt" name="s_end_dt" value="${inputParam.s_end_dt}"> --%>
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>출하종결목록</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
			</div>
<!-- /폼테이블-->					
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
				</div>		
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>	
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>