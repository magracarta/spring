<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 수요예측 > null > 수요예측 제외품목
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-10 17:06:42
-- 2022-12-23 jsk: erp3-2차 15199 수요예측 3년 판매총량의 정보 추가, 수요예측포함 로직 추가
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;

		$(document).ready(function() {
			createAUIGrid();	
		});

		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true,
				rowIdField: "part_no",
				enableFilter: true,
				showRowCheckColumn : true,
				showRowAllcheckBox : true
			};

			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "15%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					style : "aui-left",
					width : "28%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "10%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "관리구분",
					dataField : "part_mng_name",
					width : "12%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "구분",
					dataField : "part_production_name",
					width : "8%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "매입처명",
					dataField : "client_name",
					width : "14%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "분류",
					dataField : "part_group_cd",
					width : "8%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "최초등록",
					dataField : "use_start_dt",
					dataType : "date",
					width : "12%",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "당해매출",
					dataField : "be0_out_total_qty",
					dataType : "numeric",
					style : "aui-right",
					width : "10%"
				},
				{
					headerText : "전년매출",
					dataField : "be1_out_total_qty",
					dataType : "numeric",
					style : "aui-right",
					width : "10%"
				},
				{
					headerText : "전전년매출",
					dataField : "be2_out_total_qty",
					dataType : "numeric",
					style : "aui-right",
					width : "10%"
				},
				{
					headerText : "3년간총매출",
					dataField : "year3_out_total_qty",
					dataType : "numeric",
					style : "aui-right",
					width : "12%"
				}
			];
			var list = ${list}
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, list);
			$("#total_cnt").html(list.length);
		}

		// 수요예측 포함
		function goInclude() {
			var data = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (data.length == 0) {
				alert("체크된 부품이 없습니다.");
				return false;
			}

			if (confirm("수요예측에 포함하시겠습니까?")) {
				var param = {
					part_no_str : $M.getArrStr(data, {key : "part_no"})
				};
				$M.goNextPageAjax(this_page+"/include", $M.toGetParam(param), {method : 'post'},
						function(result) {
							if(result.success) {
								AUIGrid.removeCheckedRows(auiGrid);
								AUIGrid.removeSoftRows(auiGrid);
								AUIGrid.resetUpdatedItems(auiGrid);
							};
						}
				);
			}
		}

		function fnClose() {
			window.close();
		}
	</script>
</head>
<body>
	<div class="popup-wrap width-100per">
	<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
	<!-- /메인 타이틀 -->
			<div class="content-wrap">
				<div class="btn-group mt5">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
	<!-- 기본 -->					
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
	<!-- /기본 -->	
	
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>						
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
	</div>
<!-- /contents 전체 영역 -->	
</body>
</html>