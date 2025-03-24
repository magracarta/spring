<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 부품재고현황 > null > 부품그룹
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();		
		});
		
		//팝업 닫기
		function fnClose() {
			window.close(); 
		}

		function goSearch() {
			alert("조회");
		}

		function go2() {
			alert("적용");
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "분류코드",
				    dataField: "1",
				    width : "10%",
					style : "aui-center"
				},
				{
					headerText : "분류명1",
					dataField : "2",
					style : "aui-center"
				},
				{
					headerText : "분류명2",
					dataField : "2",
					style : "aui-left"
				},
			];
			
			var testArr = [];
			var testObject = {
					"1" : "1111",
					"2" : "Engine Internal parts 내부단품",
					"3" : "Piston, Valve etc",
			};
			// 테스트데이터 배열로 생성
			for (var i = 0; i < 5; ++i) {
				var tempObject = $.extend(true,{},testObject);
				tempObject.codeId = i;
	
				testArr.push(tempObject);
			};
	
			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			// AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setGridData(auiGrid, testArr);
		}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
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
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="60px">
							<col width="90px">
							<col width="50px">
							<col width="90px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>분류코드</th>
								<td>
									<input type="text" class="form-control">
								</td>
								<th>분류명</th>
								<td>
									<input type="text" class="form-control">
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
				<div style="margin-top: 5px; height: 200px;" id="auiGrid"></div>

			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary">25</strong>건
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