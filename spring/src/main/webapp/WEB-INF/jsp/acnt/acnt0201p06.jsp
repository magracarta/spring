
<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보 > null > 입금예정금액(받을어음)
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-27 20:41:15
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
			showRowNumColumn : true,
			enableFilter :true,
			showFooter : true,
			footerPosition : "top",
			editable : false,
		};

		var columnLayout = [
			{
				headerText : "예금일자",
				dataField : "end_dt",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
				style : "aui-center aui-popup",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "내역",
				dataField : "remark",
				style : "aui-left"
			},
			{
				headerText : "고객명",
				dataField : "cust_name",
				style : "aui-center"
			},
			{
				headerText : "금액",
				dataField : "amt",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right"
			}
		];

		// 푸터 설정
		var footerLayout = [
			{
				labelText : "합계",
				positionField : "cust_name"
			},
			{
				dataField: "amt",
				positionField: "amt",
				operation: "SUM",
				formatString : "#,##0",
				style: "aui-right aui-footer"
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 푸터 레이아웃 세팅
		AUIGrid.setFooter(auiGrid, footerLayout);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, ${list});
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "end_dt") {
				// 받을어음상세 팝업 호출
				var param = {
						billin_no : event.item.billin_no
				}
				var popupOption = "";
				$M.goNextPage('/acnt/acnt0203p01', $M.toGetParam(param), {popupStatus : popupOption});
			}
		});
	}
	</script>
</head>
<body>
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
				<h4>입금예정금액(받을어음)</h4>
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
<!-- /팝업 -->

</body>
</html>