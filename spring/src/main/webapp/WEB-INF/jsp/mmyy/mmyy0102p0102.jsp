<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 쪽지함 > null > 쪽지쓰기 > 조직도
-- 작성자 : 이종술
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
			fnPaperGroupUser();
		});
		
		//추가
		function fnData() {
			var data = [];
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			for(var i = 0 ; i < itemArr.length ; i++){
				if(itemArr[i].mem_no != ""){
					data.push(itemArr[i]);
				}
			}
			AUIGrid.setAllCheckedRows(auiGrid, false);
			return data;
		}
		
		//검색
		function fnSearch(str){
			var searchData = [];
			var rowItems = AUIGrid.getOrgGridData(auiGrid);
			
			for(var i = 0 ; i < rowItems.length ; i++){
				if(rowItems[i].name.indexOf(str) > -1){
					searchData.push(rowItems[i]);
				}
			}
			
			AUIGrid.search(auiGrid, "name", str);
			
			return searchData;
		}
		
		//발송그룹 조직원 조회
		function fnPaperGroupUser(){
			if($M.getValue("s_paper_group_seq") == ""){
				return;
			}
			
			var param = {
				s_paper_group_seq : $M.getValue("s_paper_group_seq")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		function goSetting() {
			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=630, left=0, top=0";
			$M.goNextPage('/mmyy/mmyy0102p05/', '', {popupStatus : poppupOption});
		}

		function fnAdd() {
			alert("대상추가 버튼입니다.");
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};

			var columnLayout = [
				{
					headerText : "부서명",
					dataField : "org_name",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					},
				},
				{
					headerText : "사원명",
					dataField : "name",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		}

	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="content width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
		</div>
		<!-- /타이틀영역 -->
		<div class="title-wrap mt10">

			<div class="btn-group">
				<select id="s_paper_group_seq" name="s_paper_group_seq" class="form-control" style="width: 150px; margin-right: 5px;" onchange="fnPaperGroupUser();">
					<c:forEach var="data" items="${list }">
						<option value="${data.paper_group_seq }">${data.group_name }</option>
					</c:forEach>
					<c:if test="${empty list }">
						<option value="">없음</option>
					</c:if>
				</select>
				<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
					<div class="btn-group">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
						</div>
						<%-- <div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div> --%>
					</div>
				</div>
			</div>
		</div>
		<div class="content-wrap">
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>