<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 바코드출력관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-02-12 14:22:17
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	
	$(document).ready(function() {
		// 그리드생성
		createAUIGrid();
	});
	
	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "code_value",
			showRowNumColumn : true,
			editable : true,
			//체크박스 출력 여부
			showRowCheckColumn : true,
			//전체선택 체크박스 표시 여부
			showRowAllCheckBox : true,
			enableFilter :true,
			// 수정 표시
			showStateColumn : true
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				headerText: "창고코드",
				dataField: "code_value",
				width : "20%",
				style : "aui-center",
				filter : {
					showIcon : true
				}
			},
			{
				headerText: "창고명",
				dataField: "code_name",
				width : "65%",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText: "매수",
				dataField: "output_count",
				width : "15%",
				dataType : "numeric",
				style : "aui-center aui-editable",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				}
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, ${list});
		$("#auiGrid").resize();
 		$("#total_cnt").html(${total_cnt});
	}
	
	function fnGetPageData() {
		// 그리드에 체크된 값 가져오기
		var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
		
		var newRows = [];
		for (var i in rows) {
			// 매수만큼 데이터 반복
			for (var j = 0; j < rows[i].output_count; j++) {
				newRows.push(rows[i]);
			}
		}
		return newRows;
	}
	
	</script>
</head>
<body style="background : #fff;">
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
			<div class="content-box">
				<div class="contents">
<!-- 메인 타이틀 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>창고조회내역</h4>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height:450px; width:60%;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>						
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>