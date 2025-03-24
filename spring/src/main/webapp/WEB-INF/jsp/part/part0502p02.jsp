<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > HOMI관리 
-- 작성자 : 박준영
-- 최초 작성일 : 2020-11-15 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});
		
		
		//조회
		function goSearch() { 
			$M.goNextPageAjax('/part/part0502p02/search', '' , {method : 'get'},
				function(result) {
					if (result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				;
			});
		}
		
		function createAUIGrid() {
			var gridPros = {
					editable : true,
					// rowIdField 설정
					rowIdField : "_$uid", 
					/* rowIdTrustMode : true, */
					// rowNumber 
					showRowNumColumn: true,
					// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
					wrapSelectionMove : false,
					enableSorting : true,
					showStateColumn : true,
					editBeginMode : "doubleClick" // edit이 그냥 클릭이면 유효성 메세지가 바로 사라져서 더블클릭으로 함.
			};
			var columnLayout = [
				{
					dataField : "group_code", 
					visible : false
				},
				{
					headerText : "코드", 
					dataField : "code", 
					width : "20%", 
					style : "aui-center",
					editRenderer : {
						type : "InputEditRenderer",
						auiGrid : "#auiGrid",
						validator : AUIGrid.commonValidator
					}
				},
				{ 
					headerText : "센터명", 
					dataField : "code_name", 
					style : "aui-center aui-editable",
					width : "40%",
					editRenderer : {
						type : "InputEditRenderer",
						auiGrid : "#auiGrid",
						validator : AUIGrid.commonValidator
					}
				},
				{ 
					headerText : "정렬순서", 
					dataField : "sort_no", 
					width : "20%", 
					dataType : "numeric",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true
					}
				},
				{
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "20%", 
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				}				
			]
			
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${list});
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				if(event.dataField == "code") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if(AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "조회된 운용센터코드는 수정할 수 없습니다.");
						}, 1);
						return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
					}
				}
				return true; // 다른 필드들은 편집 허용
			});
		}
		
		//팝업 끄기
		function fnClose() {
			window.close(); 
		}

		// 코드 행 추가, 삽입
		function fnAdd() {
	    	if(fnCheckGridEmpty()) {
	    		var item = new Object();
	    		item.group_code = "HOMI_WAREHOUSE";
	    		item.code_value = "";
	    		item.code_name = "";
	    		item.use_yn = "Y";
				AUIGrid.addRow(auiGrid, item, 'last');
	    	};
		}
		

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["code", "code_name"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		

		function goSave() {
			
			var frm = fnChangeGridDataToForm(auiGrid);

			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			};

			if (fnCheckGridEmpty(auiGrid) === false){
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			}
						
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					};
				}
			);	
			
		}
		
	</script>
</head>
<body class="bg-white class">

<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
		 <div class="main-title">
			 <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
        <div class="content-box" style="text-align:right;border:0">
			<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>	
		</div>

<!-- 검색결과 -->
			<div id="auiGrid" style="margin-top: 5px; width: 100%; height: 300px;"></div>
			<div class="btn-group mt5">	
				<div class="left">	
					총 <strong class="text-primary" id="total_cnt">0</strong>건</div>
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