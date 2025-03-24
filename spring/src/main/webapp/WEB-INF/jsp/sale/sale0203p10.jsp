<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비입고-LC Open 선적 > null > 차대번호 일괄등록
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-08-09 17:17:08
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	var containerList = ${containerList}
	var gridData;

	$(document).ready(function() {
		createAUIGrid(); // 메인 그리드
	});
	
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid", 
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			showStateColumn : false,
			editable : true,
		};
		var columnLayout = [
			{
				dataField : "machine_plant_seq",
				visible : false
			},
			{
				dataField : "machine_lc_no",
				visible : false
			},
			{
				dataField : "machine_ship_no",
				visible : false
			},
			{
				dataField : "seq_no",
				visible : false
			},
			{
				dataField : "machine_seq",
				visible : false
			},
			{
				dataField : "center_confirm_yn",
				visible : false
			},
			{
				dataField : "container_name",
				visible : false
			},
			{
				dataField : "in_org_code",
				visible : false
			},
			{
				dataField : "in_org_name",
				visible : false
			},
			{
				dataField : "center_org_code",
				visible : false
			},
			{
				dataField : "center_org_name",
				visible : false
			},
			{
				dataField : "ship_dt",
				visible : false
			},
			{
				dataField : "port_plan_dt",
				visible : false
			},
			{
				dataField : "driver_name",
				visible : false
			},
			{
				dataField : "driver_hp_no",
				visible : false
			},
			{
				headerText : "*모델",
				dataField : "machine_name",
				width : "120",
				style : "aui-left",
				editable : false
			},
			{
				headerText : "외화단가",
				dataField : "unit_price",
				dataType : "numeric",
				formatString : "#,##0.00",
				width : "100",
				style : "aui-right"
			},
			{
				headerText : "*차대번호", 
				dataField : "body_no", 
				width : "180", 
				style : "aui-center aui-editable",
				editable : true,
				// styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				// 	if (item.center_confirm_yn == "Y") {
				// 		return "";
				// 	} else {
				// 		return "aui-editable";
				// 	};
				// },
			},
			{ 
				headerText : "컨테이너", 
				dataField : "container_seq",
				width : "120",
				style : "aui-center",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					list : containerList,
					keyField : "container_seq",
					valueField : "container_name"
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<containerList.length; i++){
						if(value == containerList[i].container_seq){
							return containerList[i].container_name;
						}
					}
					return value;
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (item.center_confirm_yn == "Y") {
						return "";
					} else {
						return "aui-editable";
					};
				},
			},
			{ 
				headerText : "엔진모델1", 
				dataField : "engine_model_1", 
				width : "120", 
				style : "aui-center aui-editable",
				editable : true,
				// styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				// 	if (item.center_confirm_yn == "Y") {
				// 		return "";
				// 	} else {
				// 		return "aui-editable";
				// 	};
				// },
			},
			{ 
				headerText : "*엔진번호1", 
				dataField : "engine_no_1", 
				width : "120", 
				style : "aui-center aui-editable",
				editable : true,
				// styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				// 	if (item.center_confirm_yn == "Y") {
				// 		return "";
				// 	} else {
				// 		return "aui-editable";
				// 	};
				// },
			},
			{ 
				headerText : "엔진모델2", 
				dataField : "engine_model_2", 
				width : "120", 
				style : "aui-center aui-editable",
				editable : true,
				// styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				// 	if (item.center_confirm_yn == "Y") {
				// 		return "";
				// 	} else {
				// 		return "aui-editable";
				// 	};
				// },
			},
			{ 
				headerText : "엔진번호2", 
				dataField : "engine_no_2", 
				width : "120", 
				style : "aui-center aui-editable",
				editable : true,
				// styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				// 	if (item.center_confirm_yn == "Y") {
				// 		return "";
				// 	} else {
				// 		return "aui-editable";
				// 	};
				// },
			},
			{ 
				headerText : "옵션모델1", 
				dataField : "opt_model_1", 
				width : "100", 
				style : "aui-center aui-editable",
				editable : true,
				// styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				// 	if (item.center_confirm_yn == "Y") {
				// 		return "";
				// 	} else {
				// 		return "aui-editable";
				// 	};
				// },
			},
			{ 
				headerText : "옵션번호1", 
				dataField : "opt_no_1", 
				width : "100", 
				style : "aui-center aui-editable",
				editable : true,
				// styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				// 	if (item.center_confirm_yn == "Y") {
				// 		return "";
				// 	} else {
				// 		return "aui-editable";
				// 	};
				// },
			},
			{ 
				headerText : "옵션모델2", 
				dataField : "opt_model_2", 
				width : "100", 
				style : "aui-center aui-editable",
				editable : true,
				// styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				// 	if (item.center_confirm_yn == "Y") {
				// 		return "";
				// 	} else {
				// 		return "aui-editable";
				// 	};
				// },
			},
			{ 
				headerText : "옵션번호2", 
				dataField : "opt_no_2", 
				width : "100", 
				style : "aui-center aui-editable",
				editable : true,
				// styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				// 	if (item.center_confirm_yn == "Y") {
				// 		return "";
				// 	} else {
				// 		return "aui-editable";
				// 	};
				// },
			},
			{ 
				headerText : "비고", 
				dataField : "lc_remark", 
				width : "150", 
				style : "aui-left aui-editable",
				editable : true,
				// styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				// 	if (item.center_confirm_yn == "Y") {
				// 		return "";
				// 	} else {
				// 		return "aui-editable";
				// 	};
				// },
			},
			{
				headerText : "옵션품목",
				children : [
					{ 
						headerText : "부품번호", 
						dataField : "part_no", 
						width : "130", 
						style : "aui-center",
						editable : false
					},
					{ 
						headerText : "부품명", 
						dataField : "part_name", 
						width : "200", 
						style : "aui-center",
						editable : false
					},
					{ 
						headerText : "단위", 
						dataField : "part_unit", 
						width : "60", 
						style : "aui-center",
						editable : false
					},
					{ 
						headerText : "구성수량", 
						dataField : "opt_qty", 
						width : "60", 
						style : "aui-center",
						editable : false,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							value = AUIGrid.formatNumber(value, "#,##0");
							return value == 0 ? "" : value;
									
						},
					},
				]
			},
		];
		
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, ${list});
		$("#total_cnt").html(${total_cnt});
		
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
			// 입고센터 확정일 경우 수정 불가

			if (event.dataField == "container_seq") {
				if (event.item.center_confirm_yn == "Y") {
					setTimeout(function() {
						AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "입고 확정인 경우 수정 불가합니다.");
					}, 1);

					if (event.dataField) {
						return false;
					}
				}
			}

			gridData = AUIGrid.getGridData(auiGrid);
			
			// 차대번호 입력 벨리데이션
			if (event.dataField != "body_no") {
				if (event.item.body_no == "") {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "차대번호를 먼저 입력해주세요.");
					}, 1);
					
					if (event.oldValue == null) {
						return "";
					} else {
						return event.oldValue;
					}
				}
			}
			
			// 생성된 컨테이너가 없을 경우
			if (event.dataField == "container_seq") {
				if (event.item.body_no != "") {
					console.log("containerList : ", containerList);
					if (containerList.length == 0) {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "생성된 컨테이너가 없습니다.");
						}, 1);
						
						if (event.oldValue == null) {
							return "";
						} else {
							return event.oldValue;
						}
					}
				}
			}
			
			
		});

		AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
			// 차대번호 중복체크
			if (event.dataField == "body_no") {
				if (event.item.body_no != "") {
					fnBodyNoCheck(event.item.body_no, event.rowIndex);
				}
			}
			
			// 컨테이너 선택시 부가정보 세팅.
			if (event.dataField == "container_seq") {
				var param = {
						"container_seq" : event.item.container_seq
				}
				
				$M.goNextPageAjax("/sale/sale0203p02/search/containerInfo" , $M.toGetParam(param), {method : 'GET'},
					function(result) {
		    			console.log("result : ", result);
			    		if(result.success) {
			    			var data = {
			    					"container_name" : result.map.container_name,
			    					"in_org_code" : result.map.center_org_code,
			    					"in_org_name" : result.map.center_org_name,
			    					"driver_name" : result.map.driver_name,
			    					"driver_hp_no" : result.map.driver_hp_no,
			    					"center_org_name" : result.map.center_org_name,
			    					"center_org_code" : result.map.center_org_code,
			    					"ship_dt" : result.map.ship_dt,
			    					"port_plan_dt" : result.map.port_plan_dt,
			    			}
			    			
			    			AUIGrid.updateRow(auiGrid, data, event.rowIndex);
						}
					}
				);	
			}
		});

		// 붙여넣기 막음. (차대번호일괄등록(컨테이너)) 팝업에서 진행.
		AUIGrid.bind(auiGrid, "pasteBegin", function(event) {
			alert("붙여넣기 기능은 차대번호일괄등록(컨테이너) 팝업에서 진행 해 주세요.")
			return false; // 붙여 넣기 안함(취소 시킴)
		});
	}	
	
	// 차대번호 중복체크
	function fnBodyNoCheck(bodyNo, rowIndex) {
		var flag = "Y"; // 차대번호 중복체크 변수
		
		for (var i = 0; i < gridData.length; i++) {
			if ($.trim(gridData[i].body_no) == $.trim(bodyNo)) {
				flag = "N";
			}
		}
		
		if (flag == "Y") {
			$M.goNextPageAjax("/sale/sale0203p02/duplicate/check/" + bodyNo, "", {method : 'GET'},
				function(result) {
		    		if(result.success) {
						
					} else {
						AUIGrid.updateRow(auiGrid, { "body_no" : ""}, rowIndex);
						return;
					}
				}
			);
		} else {
			alert("차대번호가 중복됩니다.");
			AUIGrid.updateRow(auiGrid, { "body_no" : ""}, rowIndex);
			return;
		}	
	}
	
	// 저장
	function goSave() {
		var editRows = AUIGrid.getEditedRowItems(auiGrid);
		if (editRows.length == 0) {
			alert("변경된 내역이 없습니다.");
			return;
		}

		for (var i = 0; i < editRows.length; i++) {
			if (editRows[i].body_no == "") {
				alert("변경 내역의 차대번호는 필수 입력입니다.");
				return;
			}		

			if (editRows[i].engine_no_1 == "") {
				alert("변경 내역의  엔진번호1은 필수 입력입니다.");
				return;
			}		
			
		}
		
		
		// 부모페이지(장비대장관리-선적) 의 차대번호등록내역으로 list넘겨주기.
		if(confirm("변경내역을 저장하시겠습니까?") == false) {
			return false;
		}

		opener.fnSetMachineBodyAllList(editRows);
		fnClose();
	}
	
	// 닫기
	function fnClose() {
		window.close();
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="container_total_cnt" name="container_total_cnt" value="${container_total_cnt}">
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
<!-- 조회결과 -->
				<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
<!-- /조회결과 -->
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
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