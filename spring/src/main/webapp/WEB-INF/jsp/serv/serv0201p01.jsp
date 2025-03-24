<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 장비 입/출고 > 장비입고관리 > null > 장비입고확정
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid;
	var inYCenterList = ${inYCenterList};
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
	});
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			// 체크박스 출력 여부
			showRowCheckColumn : true,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : true,
			editable : true
		};
		var columnLayout = [
			{ 
				dataField : "machine_lc_no", 
				visible : false
			},
			{ 
				headerText : "모델", 
				dataField : "machine_list", 
				style : "aui-center",
				editable : false
			},
			{
				headerText : "수량", 
				dataField : "qty", 
				style : "aui-center",
				width : "8%",
				editable : false
			},
			{ 
				headerText : "컨테이너명", 
				dataField : "container_name", 
				style : "aui-center aui-popup",
				editable : false
			},
			{ 
				headerText : "입고센터", 
				dataField : "center_org_name", 
				style : "aui-center",
				editable : false
			},
			{ 
				headerText : "확정센터", 
				dataField : "in_org_code", 
				style : "aui-center aui-editable",
				showEditorBtn : false,
				showEditorBtnOver : false,
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					// showEditorBtnOver : true,
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					list : inYCenterList,
					keyField : "org_code",
					valueField  : "org_name"
				},
				labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
					var retStr = value;
					for(var j = 0; j < inYCenterList.length; j++) {
						if(inYCenterList[j]["org_code"] == value) {
							retStr = inYCenterList[j]["org_name"];
							break;
						}
					}
					return retStr;
				},
			},
			{ 
				headerText : "입고일", 
				dataField : "center_in_plan_dt", 
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
				editable : false
			},
			{ 
				headerText : "상태", 
				dataField : "container_status_name", 
				style : "aui-center",
				width : "10%",
				editable : false
			},
			{
				headerTest : "컨테이너번호",
				dataField : "container_seq",
				visible : false
			},
			{
				headerTest : "장비대장번호",
				dataField : "machine_seq_list",
				visible : false
			}
		];
		
	 
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		//AUIGrid.setGridData(auiGrid, testData);
		AUIGrid.setGridData(auiGrid, ${list});
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "container_name") {
				console.log("event : ", event);
				var params = {
					machine_lc_no : event.item.machine_lc_no,
				}
				var popupOption = "";
				$M.goNextPage("/sale/sale0203p05", $M.toGetParam(params), {popupStatus : popupOption});
			}
		});	
		
		$("#auiGrid").resize();
	}	
	
	// 닫기
    function fnClose() {
    	window.close();
    }
	
	function goProcessConfirm() {
		var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
		
		if (rows.length == 0) {
			alert("선택한 데이터가 없습니다.");
			return;
		}
		
		var param = {
			"container_seq" : $M.getArrStr(rows, {key : "container_seq", isEmpty : true})
			, "in_org_code" : $M.getArrStr(rows, {key : "in_org_code", isEmpty : true})
			, "machine_seq" : $M.getArrStr(rows, {key : "machine_seq_list", isEmpty : true})
		}
		
		console.log(param);
		
		$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param), {method : 'POST'},
			function(result) {
				if(result.success) {
					alert("저장이 완료되었습니다.");
					fnClose();
					if(opener != null && opener.goSearch) {
						opener.goSearch(); 
					}
				}
			}
		);
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블1 -->					
			<div>
<!-- 전 센터 공구함 현황 -->
				<div class="title-wrap">
					<h4>장비입고요청목록</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
<!-- 					<button type="button" class="btn btn-default" style="width: 60px;" onclick="javascript:goConfirm();"><i class="material-iconsdone text-default"></i>확정</button> -->
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
<!-- /전 센터 공구함 현황 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
					</div>		
					<div class="right">
						<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
					</div>				
				</div>
			</div>
<!-- /폼테이블1 -->
			<!-- <div class="btn-group mt10">
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div> -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>