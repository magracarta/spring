<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 서비스관련코드 > 이동거리 출장비 산정기준 관리 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-03-17 15:48:19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		var auiGrid;
		$(document).ready(function() {
			createAUIGrid();
		});
		
		function createAUIGrid() {
			var gridPros = {
					editable : true,
					// rowIdField 설정
					rowIdField : "_$uid", 
					// rowIdField가 unique 임을 보장
					rowIdTrustMode : true,
					// rowNumber 
					showRowNumColumn : true,
					enableSorting : true,
					showStateColumn : true
			};
			var columnLayout = [
				{
					dataField : "group_code",
					visible : false
				},
				{
					headerText : "이동거리(km)",
					children : [
						{
							headerText : "이상", 
							dataField : "code_v1", 
							dataType : "numeric",
							width : "16%", 
							style : "aui-right",
							editable : true,
							required : true,
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true,
						      	auiGrid : "#auiGrid",
					     	 	maxlength : 20,
						      	// 에디팅 유효성 검사
						      	validator : AUIGrid.commonValidator
							}
						}, 
						{
							headerText : "미만", 
							dataField : "code_v2", 
							dataType : "numeric",
							width : "16%",
							style : "aui-right aui-editable",
							editable : true,
							required : true,
							editRenderer : {
							    type : "InputEditRenderer",
							    onlyNumeric : true,
					     	 	maxlength : 20,
						      	// 에디팅 유효성 검사
						      	validator : AUIGrid.commonValidator
							}
						}
					]
				},
				{
					headerText : "기준출장비(원)",
					children : [	
						{
							headerText : "일반", 
							dataField : "code_v3", 
							dataType : "numeric",
							width : "16%",
							style : "aui-right aui-editable",
							editable : true,
							required : true,
							editRenderer : {
							    type : "InputEditRenderer",
							    onlyNumeric : true,
					     	 	maxlength : 20,
						      	// 에디팅 유효성 검사
						      	validator : AUIGrid.commonValidator
							}
						},
						{
							headerText : "긴급", 
							dataField : "code_v4", 
							dataType : "numeric",
							width : "16%",
							style : "aui-right aui-editable",
							editable : true,
							editRenderer : {
							    type : "InputEditRenderer",
							    onlyNumeric : true,
					     	 	maxlength : 20,
						      	// 에디팅 유효성 검사
						      	validator : AUIGrid.commonValidator
							}
						},
					]
				},
				{
					headerText : "정렬순서", 
					dataField : "sort_no", 
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
					width : "13%",
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
			AUIGrid.setGridData(auiGrid, ${list});

			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				if(event.dataField == "code_v1") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if(AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						setTimeout(function() {
							 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "이동거리(km)이상 값은 수정할수 없습니다.");
						}, 1);
						return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
					}
				}
				return true; // 다른 필드들은 편집 허용
			});	
			
			AUIGrid.bind(auiGrid, "addRow", function( event ) {
				fnUpdateCnt();
			});

			AUIGrid.bind(auiGrid, "removeRow", function( event ) {
				fnUpdateCnt();
			});
		}
		
		
		function fnUpdateCnt() {
			var cnt = AUIGrid.getGridData(auiGrid).length;
			$("#total_cnt").html(cnt);
		}
		
		// 신규
		function fnAdd() {					
			if(fnCheckGridEmpty(auiGrid)) {
	    		var item = new Object();
	    		item.group_code = "TRAVEL_EXPENSE";
	    		item.code_v1 = "";
	    		item.code_v2 = "";
	    		item.code_v3 = "";
	    		item.code_v4 = "";
	    		item.sort_no = 0;
	    		item.use_yn = "Y";
				AUIGrid.addRow(auiGrid, item, 'last');
			}
		}
		
		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validation(auiGrid);
		}
		
		// 저장
	 	function goSave() {
			var frm = $M.toValueForm(document.main_form);

			if (fnCheckGridEmpty(auiGrid) === false){
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			}

			var gridForm = fnChangeGridDataToForm(auiGrid);
			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);

			$M.goNextPageAjaxSave(this_page +"/save", gridForm, {method : 'POST'},
				function(result) {
					if(result.success) {
						window.location.reload();
					};
				}
			);

		}
		
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="prop_group_code" name="prop_group_code" value="PROP">
<input type="hidden" id="prop_code" name="prop_code" value="SVC_TRAVEL_EXPENSE_HOUR">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<div class="contents" style="width : 60%;">
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<div class="btn-group">
							<div class="right">
								<div style="display: inline-block;">
									<th>서비스 시간당 출장비 : </th>
									<input type="text" class="text-right" id="svc_travel_expense_hour" name="svc_travel_expense_hour" format="decimal" datatype="int" value="${bean.code_v1}">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" name="total_cnt" id="total_cnt">${total_cnt}</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>