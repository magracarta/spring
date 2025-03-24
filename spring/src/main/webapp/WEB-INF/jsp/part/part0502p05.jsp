<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > HOMI관리 > null > 센터설정적용
-- 작성자 : 성현우
-- 최초 작성일 : 2020-11-15 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function () {
			createAUIGrid();

			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${homiWarehouseList});
		});

		function goApply() {
			var gridData = AUIGrid.getCheckedRowItems(auiGrid);
			var nextOrgCode = gridData[0].item.code_value;
			var nextSortNo = gridData[0].item.sort_no;

			var params = {
				"s_year_mon" : $M.getValue("s_year_mon"),
				"s_before_year_mon" : $M.getValue("s_before_year_mon"),
				"s_next_org_code" : nextOrgCode,
				"s_next_sort_no" : nextSortNo
			}

			$M.goNextPageAjaxMsg("센터설정을 적용 하시겠습니까?", this_page + '/apply', $M.toGetParam(params), {method: 'GET'},
					function (result) {
						if (result.success) {
							window.opener.goSearch();
							fnClose();
						}
					}
			);
		}

		//팝업 끄기
		function fnClose() {
			window.close();
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "code_value", // rowIdField 설정
				editable: false,
				showRowNumColumn: true, // 행번호
				enableSorting: true,
				// 체크박스 표시 설정
				showRowCheckColumn : true,
				// 체크박스 대신 라디오버튼 출력함
				rowCheckToRadio : true,
			};

			var columnLayout = [
				{
					headerText: "코드",
					dataField: "code_value",
					width: "20%",
					style: "aui-center"
				},
				{
					headerText: "센터명",
					dataField: "code_name",
					width: "40%",
					style: "aui-center"
				},
				{
					headerText: "정렬순서",
					dataField: "sort_no",
					width: "20%",
					style: "aui-center"
				},
				{
					headerText : "시작센터코드",
					dataField: "start_warehouse_cd",
					visible:false
				}
			]

			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			// ready 이벤트 바인딩
			AUIGrid.bind(auiGrid, "ready", function(event) {
				var gridData = AUIGrid.getGridData(auiGrid);
				setCheckedRowsByIds(gridData); // 시작 시 체크된 상태로 표시
			});

		}

		function setCheckedRowsByIds(data) {
			var startWarehouseCd = "";
			for(var i=0; i<data.length; i++) {
				if(data[i].start_warehouse_cd != "") {
					startWarehouseCd = data[i].start_warehouse_cd;
				}
			}
			AUIGrid.setCheckedRowsByIds(auiGrid, startWarehouseCd);
		}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
	<input type="hidden" id="s_year_mon" name="s_year_mon" value="${inputParam.s_year_mon}"/>
	<input type="hidden" id="s_before_year_mon" name="s_before_year_mon" value="${inputParam.s_before_year_mon}"/>
	<input type="hidden" id="next_org_code" name="next_org_code" />
	<input type="hidden" id="sort_no" name="sort_no" />
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">

			<!-- 검색결과 -->
			<div id="auiGrid" style="margin-top: 5px; width: 100%; height: 300px;"></div>
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>

			<!-- /검색결과 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>