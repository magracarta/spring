<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자산현황 및 재무제표 > null > 장비재고상세내역
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-10-24 16:46:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	$(document).ready(function () {
		createAUIGrid();
		goSearch();
	});

	function fnClose() {
		window.close();
	}

	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showFooter : true,
			footerPosition : "top",
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				headerText : "메이커",
				dataField : "default1"
			},
			{
				headerText : "부품",
				dataField : "default2"
			},
			{
				headerText : "수량",
				dataField : "default3"
			},
			{
				headerText : "금액",
				dataField : "default4"
			}
		];

		// 푸터레이아웃
		var footerColumnLayout = [

		];

		// 그리드 출력
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);

		AUIGrid.setFooter(auiGrid, footerColumnLayout);
		$("#auiGrid").resize();
	}

	function goSearch() {
		AUIGrid.setGridData(auiGrid, []);	// 요청예정목록 초기화
		if ($M.getValue("s_type_1") == "part") {
			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "120",
					minWidth: "30",
					style: "aui-center"
				},
				{
					headerText : "신번호",
					dataField : "part_new_no",
					width : "120",
					minWidth: "30",
					style: "aui-center"
				},
				{
					headerText : "수량",
					dataField : "cnt",
					width : "100",
					minWidth: "30",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value == 0 ? "" : $M.setComma(value);
					},
					style: "aui-right"
				},
				{
					headerText : "금액",
					dataField : "amt",
					width : "120",
					minWidth: "30",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value == 0 ? "" : $M.setComma(value);
					},
					style: "aui-right"
				}
			];
			AUIGrid.changeColumnLayout(auiGrid, columnLayout);

			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "part_new_no",
					style : "aui-center aui-footer",
				},
				{
					dataField : "cnt",
					positionField : "cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "amt",
					positionField : "amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				}
			];
			AUIGrid.changeFooterLayout(auiGrid, footerColumnLayout);
		} else {
			var columnLayout = [
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "120",
					minWidth: "30",
					style: "aui-center"
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "120",
					minWidth: "30",
					style: "aui-right"
				},
				{
					headerText : "수량",
					dataField : "cnt",
					width : "100",
					minWidth: "30",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value == 0 ? "" : $M.setComma(value);
					},
					style: "aui-right"
				},
				{
					headerText : "금액",
					dataField : "amt",
					width : "120",
					minWidth: "30",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value == 0 ? "" : $M.setComma(value);
					},
					style: "aui-right"
				}
			];
			AUIGrid.changeColumnLayout(auiGrid, columnLayout);

			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "machine_name",
					style : "aui-center aui-footer",
				},
				{
					dataField : "cnt",
					positionField : "cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "amt",
					positionField : "amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				}
			];
			AUIGrid.changeFooterLayout(auiGrid, footerColumnLayout);
		}

		var param = {
			s_year : $M.getValue("s_year"),
			s_mon : $M.getValue("s_mon"),
			s_type_1 : $M.getValue("s_type_1"),
			s_type : $M.getValue("s_type"),
		}

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					console.log(result.list);
					AUIGrid.setGridData(auiGrid, result.list);	// 요청예정목록 초기화
				};
			}
		);
	}

	</script>
</head>
<body>
<input type="hidden" name="s_year" value="${inputParam.s_year}">
<input type="hidden" name="s_mon" value="${inputParam.s_mon}">
<input type="hidden" name="s_type_1" value="${inputParam.s_type_1}">
<input type="hidden" name="s_type" value="${inputParam.s_type}">
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
				<h4>조회결과</h4>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>
		</div>
		<!-- /폼테이블-->
		<div class="btn-group mt10">
			<div class="right">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
	</div>
</div>
<!-- /팝업 -->

</body>
</html>