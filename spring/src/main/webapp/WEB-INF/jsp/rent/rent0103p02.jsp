<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈운영 > 고객 앱 신청현황 > 신청참조 > null
-- 작성자 : 이강원
-- 최초 작성일 : 2023-08-07 13:06:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		<%-- 여기에 스크립트 넣어주세요. --%>

		var auiGridPopup;

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			goSearch();
		});

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
			};
			var columnLayout = [
				{
					headerText : "관리번호",
					dataField : "c_rental_request_seq",
					visible : false,
				},
				{
					dataField : "extend_yn",
					visible : false,
				},
				{
					dataField : "rental_st_dt",
					visible : false,
				},
				{
					dataField : "rental_ed_dt",
					visible : false,
				},
				{
					headerText : "신청일자",
					dataField : "request_dt",
					dataType : "date",
					width : "80",
					minWidth : "80",
					formatString : "yy-mm-dd",
					style : "aui-center",
				},
				{
					headerText : "구분",
					dataField : "rental_gubun",
					width : "80",
					minWidth : "80",
					style : "aui-center",
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "120",
					minWidth : "120",
					style : "aui-center",
				},
				{
					headerText : "연락처",
					dataField : "hp_no",
					width : "120",
					minWidth : "120",
					style : "aui-center",
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "90",
					minWidth : "90",
					style : "aui-center",
				},
				{
					headerText : "모델",
					dataField : "machine_name",
					width : "120",
					minWidth : "120",
					style : "aui-center",
				},
				{
					headerText : "렌탈신청기간",
					dataField : "rental_dt",
					width : "200",
					minWidth : "200",
					style : "aui-center",
				},
				{
					headerText : "연장신청기간",
					dataField : "extend_dt",
					width : "200",
					minWidth : "200",
					style : "aui-center",
				},
				{
					headerText : "센터",
					dataField : "org_name",
					width : "80",
					minWidth : "80",
					style : "aui-center",
				},
			];

			auiGridPopup = AUIGrid.create("#auiGridPopup", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridPopup, ${list});
			$("#auiGridPopup").resize();

			// 전체 체크박스 클릭 이벤트 바인딩
			AUIGrid.bind(auiGridPopup, "cellClick", function( event ) {
				goApply(event.item);
			});
		}

		// 적용
		function goApply(data) {
			try {
				opener.${inputParam.parent_js_name}(data);
				fnClose();
			} catch(e) {
				console.log(e);
				alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
			}
		}

		// 닫기
		function fnClose() {
			window.close();
		}

	</script>
</head>
<body   class="bg-white" >
<!-- 팝업 -->
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<div>
			<!-- 조회결과 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
				<div class="btn-group">
					<div class="right">
					</div>
				</div>
			</div>
			<!-- /조회결과 -->
			<div style="margin-top: 5px; height: 450px;" id="auiGridPopup" ></div>
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- /팝업 -->
</body>
</html>