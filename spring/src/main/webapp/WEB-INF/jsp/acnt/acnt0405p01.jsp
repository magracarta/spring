<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 장비거래원장-대리점 > null > 거래내역
-- 작성자 : 김태훈
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
				// No. 제거
				showRowNumColumn: true,
				editable : false,
// 				showFooter : true,
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					headerText : "출하일자", 
					dataField : "out_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "15%",
					style : "aui-center"
				},
				{ 
					headerText : "적요", 
					dataField : "remark", 
					style : "aui-left"
				},
				{ 
					headerText : "출하", 
					dataField : "sale_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "15%",
					style : "aui-right",
				},
				{ 
					headerText : "입금", 
					dataField : "deposit_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "15%",
					style : "aui-right",
				},
				{ 
					headerText : "미수금", 
					dataField : "misu_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "15%",
					style : "aui-right",
				}
			];
			// 푸터레이아웃
			// asis에 거래내역 합계없음, 미수금 부분합을 합계로 다 더하면 안됨
			// 기획에 합계있지만, 안하기로함 2020-09-21
			/* var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "remark",
					style : "aui-right aui-footer",
				}, 
				{
					dataField : "sale_amt",
					positionField : "sale_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "misu_amt",
					positionField : "misu_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				}
			]; */
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			var list = ${list}
			$("#total_cnt").html(list.length);
			AUIGrid.setGridData(auiGrid, list);
			$("#auiGrid").resize();
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="org_code" name="org_code" value="${inputParam.org_code }">
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
					<h4>거래내역상세</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			</div>
<!-- /폼테이블-->					
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>	
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>