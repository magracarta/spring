<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 직원연관팝업 > 직원연관팝업 > null > 지역조회
-- 작성자 : 정윤수
-- 최초 작성일 : 2024-01-24 11:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<script type="text/javascript">

	$(document).ready(function() {
		createAUIGrid();
	});
		
	function createAUIGrid() {
		var gridProsTree = {
		rowIdField: "sale_area_code",
		enableFilter: true,
		displayTreeOpen: false,
		showRowCheckColumn: true,
		rowCheckDependingTree: true,
		showRowNumColumn: false
	};

		var columnLayoutTree = [
			{
				headerText: "마케팅지역",
				dataField: "sale_area_name",
				style: "aui-left",
				editable: false,
				filter: {
					showIcon: true
				}
			},
			{
				headerText : "센터",
				dataField : "center_org_name",
				width : "20%",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				dataField : "center_org_code ",
				visible : false
			},
			{
				headerText : "마케팅담당",
				dataField : "sale_mem_name",
				width : "20%",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				dataField : "sale_mem_no ",
				visible : false
			},
			{
				headerText : "서비스담당",
				dataField : "service_mem_name",
				width : "20%",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				dataField : "service_mem_no ",
				visible : false
			},
			{
				headerText: "마케팅구역코드",
				dataField: "sale_area_code",
				visible: false
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayoutTree, gridProsTree);
		AUIGrid.setGridData(auiGrid, ${list});
		$("#auiGrid").resize();

		// 그리드 전체 체크
		AUIGrid.setAllCheckedRows(auiGrid, true);
	}
	
	function goApply() {
		// 체크된 지역
		var areaGridData = AUIGrid.getCheckedRowItemsAll(auiGrid);
		if(areaGridData.length <= 0) {
			alert("마케팅지역을 1곳 이상 선택해주세요.");
			return;
		}

		// 체크된 순서가 아니라 그리드에 표기된 순서여야 차트에 해당지역 가져올수있어서 정렬함!
		areaGridData.sort($M.sortMulti("full_sort_no"));

		var area_name_array = [];
		var area_sale_code_str = [];
		var area_sale_name = [];
		for (var i = 0; i < areaGridData.length; ++i) {
			try {
				area_sale_code_str.push(areaGridData[i].sale_area_code);
				if (areaGridData[i].up_sale_area_code == "000") {
					area_sale_name.push(areaGridData[i].sale_area_name);
				}
				// 차트 해당지역, 권역별 전체는 "강원권전체" 형태로 표시, 개별체크는 선택된 지역명 모두 출력
				if (area_sale_code_str.indexOf(areaGridData[i].up_sale_area_code) == -1) {
					var name = areaGridData[i].sale_area_name;
					if (areaGridData[i]._$leafCount != 0) {
						name = name + "전체";
					}
					area_name_array.push(name);
				}
			} catch (e) {
				console.log(e);
				console.log(areaGridData[i]);
			}
		}

		var params = {
			"area_name" : area_name_array.join(', '),
			"s_area_sale_code_str" : $M.getArrStr(area_sale_code_str)
		};
		try{
			opener.${inputParam.parent_js_name}(params);
			window.close();
		} catch(e) {
			alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
		};
	}
	
	//팝업 끄기
	function fnClose() {
		window.close(); 
	}
	
</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<div class="title-wrap mt5">
					<h4>마케팅지역</h4>
					<div class="btn-group mt5">
						<div class="right">
							<button type="button" onclick=AUIGrid.expandAll(auiGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
							<button type="button" onclick=AUIGrid.collapseAll(auiGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 285px;"></div>
				<div class="btn-group mt5">					
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