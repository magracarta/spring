<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 바코드출력관리 > null > 저장위치
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-02-19 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	$(document).ready(function() {
		// 그리드생성
		createAUIGrid();
		fnInit();
	});
	
	function fnInit() {
		var val = "${inputParam.s_storage_name}";
		$M.setValue("s_storage_name", val);
	}
	
	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "storage_name",
			showRowNumColumn : true
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				headerText: "저장위치",
				dataField: "storage_name",
				width : "100%",
				style : "aui-center"
			},
			{
				dataField: "warehouse_cd",
				visible : false
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${list1});
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			// Row행 클릭 시 반영
			try{
				<c:if test="${not empty inputParam.parent_js_name}">
					opener.${inputParam.parent_js_name}(event.item);
				</c:if>
				window.close();	
			} catch(e) {
				alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
			}
		});	
		$("#auiGrid").resize();
	}
	
	function goSearch() {
		// 부품창고 값 세팅
// 		var warehouse_cd = '${inputParam.s_warehouse_cd}'
		var warehouse_cd = $M.getValue("warehouse_cd");
		
		console.log("warehouse_cd : ", warehouse_cd);
		
		var param = {
			s_storage_name : $M.getValue("s_storage_name"),
			warehouse_cd : warehouse_cd,
			s_sort_key : "storage_name",
			s_sort_method : "asc"
		};
		
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}		
		);
	}
	
	function fnClose() {
		window.close();
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_storage_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<input type="hidden" id="warehouse_cd" name="warehouse_cd" value="${warehouse_cd}">
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
<!-- 검색영역 -->					
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<td style="width:220px">
									<input id="s_storage_name" name="s_storage_name" type="text" class="form-control" >
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
				<div id="auiGrid" style="margin-top: 5px; height:330px; width:280px;"></div>
			</div>
			<div class="btn-group mt5">
				<div class="btn-group">	
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>		
			</div>
<!-- /폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>