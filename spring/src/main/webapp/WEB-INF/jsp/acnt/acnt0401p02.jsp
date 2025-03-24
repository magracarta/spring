<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 장비입고관리-통관 > null > 선임료조회
-- 작성자 : 김상덕
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
			goSearch();
		});
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "33%",
					style : "aui-center"
				},
				{ 
					headerText : "통관일자", 
					dataField : "pass_dt", 
					width : "33%",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{ 
					headerText : "선임료", 
					dataField : "amt", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}
	
		// 닫기
		function fnClose() {
			window.close();
		}
		
		// 선임료 조회
		function goSearch() {
			var param = {
				s_maker_cd : $M.getValue("s_maker_cd")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블1 -->					
			<div>
<!-- 옵션품목 셀렉트 -->
				<select class="form-control width140px" id="s_maker_cd" name="s_maker_cd" onchange="javascript:goSearch();">
					<option value="">- 전체 -</option>
					<c:forEach items="${codeMap['MAKER']}" var="item" varStatus="status">
						<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
<%-- 							<option value="${item.code_value}" ${status.count == 1 ? 'selected="selected"' : ''} >${item.code_name}</option> --%>
							<option value="${item.code_value}" >${item.code_name}</option>
						</c:if>
					</c:forEach>
				</select>
				<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
<!-- 옵션품목 셀렉트 -->
			</div>
<!-- /폼테이블1 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
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