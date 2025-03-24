<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include
	page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c"
	uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn"
	uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt"
	uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib
	uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib
	uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비생산발주 > null > 매입처목록
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
	<script type="text/javascript">
	
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();
		});

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "codeId",
				height : 515,
				// rowNumber 
				showRowNumColumn : true,
			};
			// 컬럼레이아웃
			var columnLayout = [
				{
					headerText : "그룹",
					dataField : "com_buy_group_cd",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "업체명",
					dataField : "company_name",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "대표자",
					dataField : "breg_rep_name",
					width : "5%",
					style : "aui-center"
				},
				{
					headerText : "전화",
					dataField : "phone_number",
					width : "10%",
					style : "aui-right"
				},
				{
					headerText : "구성품목",
					dataField : "item_list",
					width : "10%",
					style : "aui-right"
				},
				{
					headerText : "계약L/T",
					dataField : "lead_time",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "납기율",
					dataField : "delivery_rate",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "업체평가",
					dataField : "point_case",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "INCOTERMS",
					dataField : "incoterms",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "지불조건",
					dataField : "out_case",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "당해매입",
					dataField : "purchase1",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "전년매입",
					dataField : "purchase2",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "전전매입",
					dataField : "purchase3",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "계약",
					dataField : "contract",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "금형",
					dataField : "kuemhng",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "도면",
					dataField : "domuen",
					width : "10%",
					style : "aui-center"
				} 
			];
			var testArr = [];
			var testObject = {
				"codeId" : "1",
				"com_buy_group_cd" : "A",
				"company_name" : "후쿠이츠",
				"breg_rep_name" : "김민교",
				"phone_number" : "01012345678",
				"item_list" : "AB-2",
				"lead_time" : "90",
				"delivery_rate" : "30%",
				"point_case" : "A",
				"incoterms" : "33",
				"out_case" : "익월말현금",
				"purchase1" : "32300",
				"purchase2" : "12100",
				"purchase3" : "43300",
				"contract" : "계약A",
				"kuemhng" : "금형A",
				"domuen" : "도면A",
			};
			// 테스트데이터 배열로 생성
			for (var i = 0; i < 20; ++i) {
				var tempObject = $.extend(true,{},testObject);
				tempObject.codeId = i;
				testArr.push(tempObject);
			};
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, testArr);
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
			$("#auiGrid").resize();
		}
		
		function fnScollChangeHandelr(event) {
			// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
			if(event.position == event.maxPosition) {
				// goMoreData();
			};
		}
		
		function goSearch() {
			alert("조회");
		}
		
	</script>
</head>
<body>
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<div class="title-wrap">
					<h4>매입처목록</h4>
				</div>
				<!-- 검색영역 -->
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="60px">
							<col width="120px">
							<col width="60px">
							<col width="120px">
							<col width="50px">
							<col width="120px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>업체명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control">
									</div>
								</td>
								<th>대표자</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control">
									</div>
								</td>
								<th>그룹</th>
								<td><select class="form-control">
										<option>전체</option>
								</select></td>
								<td class="">
									<button type="button" class="btn btn-important"
										style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>

							</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색영역 -->
				<!-- 검색결과 -->
				<div id="auiGrid" style="height:515px; margin-top: 5px;"></div>
				<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary">25</strong>건
					</div>
				</div>
				<!-- /그리드 서머리, 컨트롤 영역 -->
				<!-- /검색결과 -->
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>