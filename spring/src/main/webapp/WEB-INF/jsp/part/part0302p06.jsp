<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 부품매입관리 > null > 매입단가산출
-- 작성자 : 정윤수
-- 최초 작성일 : 2022-10-19 16:46:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function() {
			createAUIGrid();

		});
		function createAUIGrid() {
			var gridData = opener.${inputParam.parent_js_name}();
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
				showStateColumn : true,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					dataField: "money_unit_cd",
					visible : false
				},
				{
					dataField: "part_production_cd",
					visible : false
				},
				{
					headerText: "부품번호",
					dataField: "item_id",
					width : "50%",
					style : "aui-center"
				},
				{
					headerText: "단가",
					dataField: "in_price",
					width : "25%",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0.00"
				},
				{
					headerText: "매입단가",
					dataField: "unit_price",
					width : "25%",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},

			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, gridData);
			$("#auiGrid").resize();
			$("#total_cnt").html(gridData.length);
			for(var i =0; i < gridData.length; i++) {
				gridData[i].unit_price = "";
			}
			AUIGrid.setGridData(auiGrid, gridData);
		}
		// 매입단가산출
		function fnCalculateUnitPrice() {
			var gridData = AUIGrid.getGridData(auiGrid);
			for(var i =0; i < gridData.length; i++) {
				if("1" == gridData[i].part_production_cd){ // 국산부품
					gridData[i].unit_price = gridData[i].in_price;
				}else if("JPY" == gridData[i].money_unit_cd){ // JPY
					gridData[i].unit_price = Math.ceil(gridData[i].in_price * $M.getValue("apply_er_rate") * $M.getValue("mng_amt") / 100);
				}else{ // 외자부품
					gridData[i].unit_price = Math.ceil(gridData[i].in_price * $M.getValue("apply_er_rate") * $M.getValue("mng_amt"));
				}
				AUIGrid.setGridData(auiGrid, gridData);
			}

		}

		function goApply() {
			var gridData = AUIGrid.getGridData(auiGrid);
			var applyErRate = $M.getValue("apply_er_rate");
			var mngAmt = $M.getValue("mng_amt");
			opener.fnUnitPriceApply(gridData, applyErRate, mngAmt);
			window.close();
		}

		function goSearchRatePage() {
			window.open('http://www.smbs.biz/ExRate/TodayExRate.jsp');
		}

		//팝업 닫기
		function fnClose(){
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
					<h4>매입단가입력</h4>
					<span class="text-warning">※ 매입처리시 적용환율은 입항일 기준이므로 수입필증에서 입항일을 확인하시길 바랍니다.</span>
				</div>
				<!-- 검색영역 -->
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="30px">
							<col width="30px">
							<col width="50px">
							<col width="30px">
							<col width="50px">
							<col width="10px">
						</colgroup>
						<tbody>
						<tr>
							<td>
								<div>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
								</div>
							</td>
							<th>적용환율</th>
							<td>
								<input type="text" class="form-control" id="apply_er_rate" name="apply_er_rate" style="text-align:right;padding-right: 10px;" value="" format="decimal">
							</td>

							<th>관리비</th>
							<td>
								<input type="text" class="form-control" id="mng_amt" name="mng_amt" style="text-align:right;padding-right: 10px;" value="1.2" format="decimal">
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색영역 -->
				<div id="auiGrid" style="margin-top: 5px;height: 370px;"></div>
			</div>
			<!-- /폼테이블 -->
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