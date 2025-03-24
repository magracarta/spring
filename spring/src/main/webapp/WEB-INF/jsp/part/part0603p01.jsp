<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 재고회전율 > null > 부품재고회전율
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
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "부품정보",
					children : [
						{
							dataField : "1",
							headerText : "부품번호",
							width : "10%",
							style : "aui-center",
							
						}, 
						{
							dataField : "2",
							headerText : "부품명",
							width : "10%",
							style : "aui-left",
						},
						{
							dataField : "3",
							headerText : "기종",
							style : "aui-center",
						},
					]
				},
				{
				    headerText: "전 3개월 평균",
					children : [
						{
							dataField : "4",
							headerText : "출고원가",
							style : "aui-right",
							
						}, 
						{
							dataField : "5",
							headerText : "재고",
							style : "aui-right",
						},
						{
							dataField : "6",
							headerText : "회전율",
							style : "aui-right",
						},
					]
				},
				{
					headerText : "전년말<br>12개월",
					dataField : "7",
					style : "aui-right"
				},
				{
				    headerText: "당해년도",
					children : [
						{
							dataField : "8",
							headerText : "01월",
							style : "aui-right",
							
						}, 
						{
							dataField : "9",
							headerText : "02월",
							style : "aui-right",
							
						}, 
						{
							dataField : "10",
							headerText : "03월",
							style : "aui-right",
							
						}, 
						{
							dataField : "11",
							headerText : "04월",
							style : "aui-right",
							
						}, 
						{
							dataField : "12",
							headerText : "05월",
							style : "aui-right",
							
						}, 
						{
							dataField : "13",
							headerText : "06월",
							style : "aui-right",
							
						}, 
						{
							dataField : "14",
							headerText : "07월",
							style : "aui-right",
							
						}, 
						{
							dataField : "15",
							headerText : "08월",
							style : "aui-right",
							
						}, 
						{
							dataField : "16",
							headerText : "09월",
							style : "aui-right",
							
						}, 
						{
							dataField : "17",
							headerText : "10월",
							style : "aui-right",
							
						}, 
						{
							dataField : "18",
							headerText : "11월",
							style : "aui-right",
							
						}, 
						{
							dataField : "19",
							headerText : "12월",
							style : "aui-right",
							
						}, 
					
					]
				},
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "1",
					colSpan : 3,
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "4",
					positionField : "4",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "5",
					positionField : "5",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "6",
					positionField : "6",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "7",
					positionField : "7",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "8",
					positionField : "8",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "9",
					positionField : "9",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "10",
					positionField : "10",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "11",
					positionField : "11",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "12",
					positionField : "12",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "13",
					positionField : "13",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "14",
					positionField : "14",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "15",
					positionField : "15",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "16",
					positionField : "16",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "17",
					positionField : "17",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "18",
					positionField : "18",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
				{
					dataField : "19",
					positionField : "19",
					operation : "SUM",
					formatString : "0.00",
					style : "aui-right aui-footer",
				},
			];
			
			var testArr = [];
			var testObject = {
					"1" : "190005-35151L",
					"2" : "FILTER, ENGINE OIL",
					"3" : "Y015",
					"4" : "10000",
					"5" : "28071",
					"6" : "0.06",
					"7" : "",
					"8" : "4.81",
					"9" : "3.66",
					"10" : "1.83",
					"11" : "1.60",
					"12" : "2.85",
					"13" : "4.27",
					"14" : "2.85",
					"15" : "0.37",
					"16" : "0.48",
					"17" : "2.40",
					"18" : "3.10",
					"19" : "5.45",
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
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, testArr);
			// AUIGrid.setFixedColumnCount(auiGrid, 6);
			$("#auiGrid").resize();
		}
		
		function go1() {
			alert("엑셀다운로드");
		}

		function go2() {
			alert("인쇄");
		}
		
		function fnClose() {
			window.close();
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
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<div class="left">
						<h4>얀마 / 수입</h4>
					</div>
					<div class="right">						
						<button type="button" class="btn btn-default mr5" onclick="javascript:go1();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
						<button type="button" class="btn btn-md btn-rounded btn-outline-primary" onclick="javascript:go2();"><i class="material-iconsprint text-primary"></i> 인쇄</button>		
					</div>
				</div>						
				<div style="margin-top: 5px; height: 350px;" id="auiGrid"></div>
			</div>	
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary">25</strong>건
				</div>	
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>	
<!-- /폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>