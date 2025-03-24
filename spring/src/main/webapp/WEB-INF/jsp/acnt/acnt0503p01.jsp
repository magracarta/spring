<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 은행거래조건관리 > null > 은행코드관리
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-16 10:11:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();	// 그리드 생성
			goSearch();			// 은행목록 조회
		});
		
		
		function goSearch() {
			var param = {
				"s_sort_key" 		: "sort_no",
				"s_sort_method" 	: "asc"
			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
	
		// 은행거래조건 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			
			if (fnCheckGridEmpty() === false) {
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			};
			
			var frm = fnChangeGridDataToForm(auiGrid);
			console.log(frm);
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : "POST"}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
						opener.goSearch();
					};
				}
			); 
		}
		
		// 처리내역 행 추가
		function fnAdd() {
			// 그리드 빈값 체크
			if(fnCheckGridEmpty(auiGrid)) {
	    		var item = new Object();
	    		item.group_code = "BANK";
	    		item.code = "";
	    		item.code_name = "";
	    		item.code_v1 = "";
	    		item.code_v2 = "";
	    		item.code_v3 = "";
	    		item.sort = "";
	    		item.use_yn = "N";
				AUIGrid.addRow(auiGrid, item, "first");
			};
		}
		
		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["code", "code_name", "sort_no"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				fillColumnSizeMode : false,
				editable : true,
				showStateColumn : true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "은행코드",
				    dataField: "code",
					width : "20%",
					style : "aui-center",
					editable : true,
					required : true,
					editRenderer : {
					      type : "InputEditRenderer",
					      auiGrid : "#auiGrid",
					      onlyNumeric : true,
					      length : 3,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					}
				},
				{
				    headerText: "은행명",
				    dataField: "code_name",
					width : "25%",
					style : "aui-center aui-editable",
				},
				{
					headerText : "지점명",
					dataField : "code_v1",
					width: "25%",
					style : "aui-centerr aui-editable",
				},
				{
					headerText : "연락처",
					dataField : "code_v2",
					width: "25%",
					style : "aui-centerr aui-editable",
					editRenderer : {
					      type : "InputEditRenderer",
					      onlyNumeric : true,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "LC한도",
					dataField : "code_v3",
					dataType : "numeric",
					formatString : "#,##0",
					width: "25%",
					style : "aui-right aui-editable",
					editRenderer : {
					      type : "InputEditRenderer",
					      onlyNumeric : true,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "정렬순서",
					dataField : "sort_no",
					dataType : "numeric",
					width: "10%",
					style : "aui-rightr aui-editable",
					editRenderer : {
					      type : "InputEditRenderer",
					      onlyNumeric : true,
					      maxlength : 3,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					},
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				if(event.dataField == "code") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if(AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "조회된 은행코드는 수정할 수 없습니다.");
						}, 1);
						return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
					}
				}
				return true; // 다른 필드들은 편집 허용
			});
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
				<!-- 폼테이블 -->					
				<div>
					<div class="title-wrap">
						<h4>은행코드관리</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div style="margin-top: 5px; height: 400px;" id="auiGrid"></div>
				</div>
				<!-- /폼테이블-->					
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