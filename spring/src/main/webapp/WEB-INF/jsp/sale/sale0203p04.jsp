<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비입고-LC Open 선적 > 장비대장관리-선적 > 입고센터지정
-- 작성자 : 황빛찬
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var list = ${list}
		var centerList = ${centerList}
		
		$(document).ready(function() {
			// 센터별보유장비현황 그리드
			createMiddleAUIGrid();
			// 입고센터지정 그리드 생성
			createBottomAUIGrid();
		});
		
		//그리드생성
		function createMiddleAUIGrid() {
			var gridProsMiddle = {
					rowIdField : "_$uid",
					// rowNumber 
					showRowNumColumn: true,
					showFooter : true,
					footerPosition : "top",
			};
			// 컬럼레이아웃
			var columnLayoutMiddle = [
				{ 
					headerText : "모델", 
					dataField : "machine_name", 
// 					width : "25%", 
					style : "aui-center",
				},
				{ 
					headerText : "옥천", 
					dataField : "okcheon", 
					dataType : "numeric",
					formatString : "#,##0",
// 					width : "25%", 
					style : "aui-center",
				},
				{ 
					headerText : "평택", 
					dataField : "pyeongtaek", 
					dataType : "numeric",
					formatString : "#,##0",
// 					width : "25%", 
					style : "aui-center",
				},
				{ 
					headerText : "김해", 
					dataField : "gimhae", 
					dataType : "numeric",
					formatString : "#,##0",
// 					width : "25%", 
					style : "aui-center",
				},
				{   headerText : "계",
				    dataField : "total", 
					dataType : "numeric",
					formatString : "#,##0",
				    width:80,
					style : "aui-center",
				}
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "machine_name",
				}, 
				{
					dataField: "okcheon",
					positionField: "okcheon",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "pyeongtaek",
					positionField: "pyeongtaek",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "gimhae",
					positionField: "gimhae",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "total",
					positionField: "total",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer"
				},
			];
			
			auiGridMiddle = AUIGrid.create("#auiGridMiddle", columnLayoutMiddle, gridProsMiddle);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGridMiddle, footerColumnLayout);
			AUIGrid.setGridData(auiGridMiddle, ${list1});
			$("#auiGridMiddle").resize();
		}
		
		function createBottomAUIGrid() {
			var gridProsBottom = {
					rowIdField : "_$uid",
					showRowNumColumn: true,
					editable : true,
					showStateColumn : true
					// 체크박스 표시 설정
// 					showRowCheckColumn : true,			
// 					// 전체 체크박스 표시 설정
// 					showRowAllCheckBox : true,
			};
			var columnLayoutBottom = [
				{ 
					dataField : "machine_lc_no", 
					visible : false
				},
				{ 
					dataField : "container_seq", 
					visible : false
				},
				{ 
					dataField : "ship_yn", 
					visible : false
				},
				{ 
					headerText : "컨테이너명", 
					dataField : "container_name", 
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "입고센터", 
					dataField : "center_org_code", 
					width : "18%", 
					style : "aui-center aui-editable",
					editRenderer : {				
						type : "DropDownListRenderer",
						list : centerList,
						keyField : "code_value",
						valueField : "code_name"
					},
					labelFunction : function(rowIndex, columnIndex, value){
						for(var i=0; i<centerList.length; i++){
							if(value == centerList[i].code_value){
								return centerList[i].code_name;
							}
						}
						return value;
					}
				},
				{ 
					headerText : "센터입고일", 
					dataField : "center_in_plan_dt", 
					dataType : "date",   
					width : "18%", 
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editable : true,
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					}
				},
				{
					headerText : "요청여부",
					dataField : "center_confirm_req_yn",
					width : "10%",
					editable : false,
				},
				{
					headerText : "확정여부",
					dataField : "center_confirm_yn",
					width : "10%",
					editable : false,
				},
				{ 
					headerText : "", 
					dataField : "requestBtn",
					width : "13%", 
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							console.log("event : ", event);
							if (event.item.center_confirm_yn != "Y") {
								var requestYn = "N";  // 요청 or 요청취소 flag값  N : 요청취소
								console.log(event);
								if (event.item.center_confirm_req_yn == "Y") {
									requestYn = "Y";  // 요청
								}
								
								if (event.item.ship_yn == "N") {
									alert("장비 선적 후 요청 해 주세요.");
									return;
								}

								if (event.item.center_confirm_req_yn == "N") {
									if (event.item.center_org_code == "" || event.item.center_in_plan_dt == "") {
										alert("입고센터와 입고일을 지정해주세요.");
										return;
									}
								}
								
								
								var params = {
										"container_seq" : event.item.container_seq,
										"center_org_code" : event.item.center_org_code,
										"center_in_plan_dt" : event.item.center_in_plan_dt,
										"request_yn" : requestYn
								}
								
								// 요청, 요청취소 처리
								$M.goNextPageAjaxSave(this_page +"/modify", $M.toGetParam(params), {method : 'POST'}, 
					   				function(result) {
					   					if(result.success) {
											window.opener.location.reload();
					   						location.reload();
					   					};
					   				}
					   			);
							} else {
								alert("센터확정된 컨테이너는 취소가 불가능합니다.");
							}
							
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						if (item["center_confirm_req_yn"] == 'Y') {
							return '요청취소'
						} else {
							return '요청'
						}
					},
					style : "aui-center",
					editable : false,
				}
			];
			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayoutBottom, gridProsBottom);
			AUIGrid.setGridData(auiGridBottom, ${list});
			AUIGrid.bind(auiGridBottom, "cellEditBegin", function (event) {
				if (event.item.center_confirm_yn == 'Y') {
					if (event.dataField == "center_org_code" || event.dataField == "center_in_plan_dt") {
						return false;
					}
				}
				
			});
			$("#auiGridBottom").resize(); 
		};
		
		// 조건부 에디트렌더러 출력(드랍다운리스트)
		var myDropEditRenderer = {
				showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
				type : "DropDownListRenderer",
				keyField : 'code_value',
				valueField : 'code_name',
				list : list,
				editable : false,
				required : true,
				multipleMode : false
		};

		// 조건부 에디트렌더러 출력(드랍다운리스트)
		var myDropEditRenderer2 = {
				showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
				type : "DropDownListRenderer",
				keyField : 'code_value',
				valueField : 'code_name',
				list : centerList,
				editable : false,
				required : true,
				multipleMode : false
		};
		
		function fnClose() {
			window.close();
		}
		
		// 요청
		function goRequest() {
			var frm = fnChangeGridDataToForm(auiGridBottom)
			console.log(frm);
			
			$M.goNextPageAjaxSave(this_page +"/modify", frm, {method : 'POST'}, 
   				function(result) {
   					if(result.success) {
   						alert("저장이 완료되었습니다.");
   						fnClose();
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
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<div class="doc-info" style="flex: 1;">				
					<h4>센터별보유장비현황</h4>		
				</div>		
			</div>
			<div id="auiGridMiddle" style="margin-top: 5px; height: 300px;"></div>	

			<div class="title-wrap mt10">
				<div class="doc-info" style="flex: 1;">				
					<h4>입고센터지정</h4>				
				</div>		
			</div>
			<div id="auiGridBottom" style="margin-top: 5px; height: 200px;"></div>	

<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>	
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>