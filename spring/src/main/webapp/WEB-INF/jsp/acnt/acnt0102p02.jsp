<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 비용관리 > 전도금정산서 > null > 처리내역
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-08 17:55:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		$(document).ready(function () {
			createAUIGrid();
		});

		function fnClose() {
			window.close();
		}

		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부
				showRowNumColum : true,
				showFooter : true
			};

			var columnLayout = [
				{
					headerText : "은행명",
					dataField : "a"
				},
				{
					headerText : "계좌번호",
					dataField : "b"
				},
				{
					headerText : "처리일자",
					dataField : "c"
				},
				{
					headerText : "입금",
					dataField : "d",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "출금",
					dataField : "e",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "적요",
					dataField : "f"
				},
				{
					headerText : "전표일자",
					dataField : "g"
				},
				{
					headerText : "번호",
					dataField : "h"
				},
				{
					headerText : "고객명",
					dataField : "i"
				},
				{
					headerText : "예금구분",
					dataField : "j"
				},
				{
					headerText : "처리액",
					dataField : "k"
				}
			];

			var dummyData = [
				{
					"a" : "농협",
					"b" : "123-123-12321",
					"c" : "2020-10-22",
					"d" : "",
					"e" : "-500000",
					"f" : "적요가 들어갑니다.",
					"g" : "2020-10-17",
					"h" : "006",
					"i" : "장현석",
					"j" : "보통예금",
					"k" : "-500000"
				},
				{
					"a" : "농협",
					"b" : "123-123-12321",
					"c" : "2020-10-22",
					"d" : "",
					"e" : "-500000",
					"f" : "적요가 들어갑니다.",
					"g" : "2020-10-17",
					"h" : "006",
					"i" : "장현석",
					"j" : "보통예금",
					"k" : "-500000"
				},
				{
					"a" : "농협",
					"b" : "123-123-12321",
					"c" : "2020-10-22",
					"d" : "",
					"e" : "-500000",
					"f" : "적요가 들어갑니다.",
					"g" : "2020-10-17",
					"h" : "006",
					"i" : "장현석",
					"j" : "보통예금",
					"k" : "-500000"
				}
			];

			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "c"
				},
				{
					dataField: "d",
					positionField: "d",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "e",
					positionField: "e",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "k",
					positionField: "k",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer"
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, dummyData);
		}
	</script>
</head>
<body>
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<h2>처리내역</h2>
		<button type="button" class="btn btn-icon"><i class="material-iconsclose"></i></button>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<!-- 폼테이블 -->
		<div>
			<div class="title-wrap">
				<h4>조회결과</h4>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
		</div>
		<!-- /폼테이블-->
		<div class="btn-group mt10">
			<div class="right">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
	</div>
</div>
</body>
</html>