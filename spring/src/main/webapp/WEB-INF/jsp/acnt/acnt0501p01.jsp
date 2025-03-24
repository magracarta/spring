<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 법인차량관리 > null > 변경이력
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-17 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	//변경구분
	var carChangeJson = JSON.parse('${codeMapJsonObj['CAR_CHANGE']}');
	var managementYn = "${page.fnc.F00589_001}" == "Y" ? "Y" : "N";
		
	var gridRowIndex;
	var auiGrid;
	
	$(document).ready(function() {
		createAUIGrid();
		fnInit();
	});
	
	function fnInit() {
		if(managementYn != "Y") {
			$("#_goSave").addClass("dpn");
			$("#_fnAdd").addClass("dpn");
		} else {
			$("#_goSave").removeClass("dpn");
			$("#_fnAdd").removeClass("dpn");
		}
	}
	
	function createAUIGrid() {

		var servYn = "${SecureUser.org_code}".substring(0, 1) == "5" ? "Y" : "N";
		
		
		var gridPros = {
				editable : true,
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				//rowIdTrustMode : true,
				// rowNumber 
				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true,
		};

		if(managementYn != "Y") {
			gridPros.editable = false;
		}
		
		var columnLayout = [
			{
				dataField : "car_code",
				visible : false
			},
			{
				headerText : "변경일자", 
				dataField : "change_dt", 
				dataType : "date",   
				width : "15%",
				style : "aui-center",
				required : true,
				editable : true,				
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				editRenderer : {
					type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
					defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
					onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
					maxlength : 8,
					onlyNumeric : true, // 숫자만
					validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
						return fnCheckDate(oldValue, newValue, rowItem);
					},
					showEditorBtnOver : true
				}
			},
			{
				headerText : "사용자",
				dataField : "kor_name",
				width : "20%",
				style : "aui-center",
				required : true,
				editable : false
			},
			{ 
				headerText : "직원번호",
				dataField : "mem_no",
				visible : false
			},
			{
				headerText : "부서",
				dataField : "org_kor_name",
				visible : false																
			},			
			{
				headerText : "변경구분",
				dataField : "car_change_cd",
				width : "15%",
				style : "aui-center",
				required : true,
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : carChangeJson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<carChangeJson.length; i++){
						if(value == carChangeJson[i].code_value){
							return carChangeJson[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText : "세부내역",
				dataField : "remark",
				width : "35%",
				style : "aui-left",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      maxlength : 100,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				}
			},
			{
				
				headerText : "삭제",
				dataField : "removeBtn",
				width : "15%",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);		
						} else {
							AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
						}
					},
					visibleFunction : function(rowIndex, columnIndex, value, item, dataField) {
						if (managementYn == "Y") {
							return true;
						};
						return false;
					},

				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					return '삭제'
				},
	
				style : "aui-center",
				editable : true
			}				
		]
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, carMemListJson);
		$("#auiGrid").resize();
		
		AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
			// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
			if(AUIGrid.isAddedById(auiGrid,event.item._$uid)) {			
				return true;
			}
			else{
				return false;
			}
						
		});	
				
		AUIGrid.bind(auiGrid, "cellClick", function(event) {		
			//사용자 선택시 직원 조회 팝업 호출
			if(AUIGrid.isAddedById(auiGrid,event.item._$uid)) {			
				if(event.dataField == "kor_name" ) {
					gridRowIndex = event.rowIndex;
					param = {
						  "agency_yn" : "N"
					}									
// 					openOrgMapPanel('fnsetOrgMapPanel', $M.toGetParam(param));
					openMemberOrgPanel('fnsetOrgMapPanel', "N" , $M.toGetParam(param));
				}
				return true;
			}
			else{
				return false;
			}					
		});	
		
		AUIGrid.bind(auiGrid, "addRow", function( event ) {
			fnUpdateCnt();
		});
		AUIGrid.bind(auiGrid, "removeRow", function( event ) {
			fnUpdateCnt();
		});
	}
	
	// 직원조회 결과
	function fnsetOrgMapPanel(data) {		
		console.log("data : ", data);
		AUIGrid.updateRow(auiGrid, { "org_kor_name" : data.org_name }, gridRowIndex);
	    AUIGrid.updateRow(auiGrid, { "kor_name" : data.mem_name }, gridRowIndex);
	    AUIGrid.updateRow(auiGrid, { "mem_no" : data.mem_no }, gridRowIndex);
	}
	

	function fnUpdateCnt() {
		var cnt = AUIGrid.getGridData(auiGrid).length;
		$("#total_cnt").html(cnt);
	}
	
	//행추가
	function fnAdd() {					
		if(fnCheckGridEmpty(auiGrid)) {
    		var item = new Object();
   			item.car_code= "${inputParam.car_code}";
    		item.change_dt = "";
    		item.kor_name = "";
    		item.mem_no = "";
    		item.org_kor_name = "";
    		item.car_change_name= "";
    		item.remark = "";
  		
			AUIGrid.addRow(auiGrid, item, 'first');
		}
	}
	
	
	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validation(auiGrid);
	}
	
	// 저장
 	function goSave() {
		
 		if (fnChangeGridDataCnt(auiGrid) == 0){
			alert("변경된 데이터가 없습니다.");
			return false;
		};
		if (fnCheckGridEmpty(auiGrid) === false){
// 			alert("필수 항목은 반드시 값을 입력해야합니다.");
			return false;
		}
		
		var frm = fnChangeGridDataToForm(auiGrid);
		$M.goNextPageAjaxSave(this_page +"/save", frm, {method : 'POST'}, 
			function(result) {
				if(result.success) {
					AUIGrid.removeSoftRows(auiGrid);
					AUIGrid.resetUpdatedItems(auiGrid);	
					
					//저장 후 변경된 최신 소유자 정보 넘겨주기
					opener.${inputParam.parent_js_name}(result);
					
					$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);	
					location.reload();
				};
			}
		);

	}
	
	function fnClose() {
		window.close(); 
	}	
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="car_code" name="car_code">
<!-- 팝업 -->
    <div class="popup-wrap width-100per" >
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>변경이력</h4>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
			</div>
<!-- /폼테이블-->					
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
<!-- /팝업 -->
</form>
</body>
</html>