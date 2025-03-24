<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 인사코드관리 > null > 그룹관리
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-10-19 09:47:25
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGridGroup;
	var levelList = ${levelList}
	
	var rowNum;
	
	$(document).ready(function () {
		createAUIGrid();
		goSearch();
	});
	
    function createAUIGrid() {
        // 그리드 속성
        var gridPros = {
            rowIdField: "_$uid",
            editable: true,
            showStateColumn: true
        };

        // 생성 될 칼럼 레이아웃
        var columnLayout = [
        	{
        		dataField : "code",
        		visible : false
        	},
        	{
        		dataField : "row_num",
        		visible : false
        	},
            {
                dataField: "code_name",
                headerText: "직군명",
                width : "40%",
                style : "aui-center aui-editable",
                required: true
            },
            {
                dataField: "group_count",
                headerText: "조직원수",
                width : "20%",
                style : "aui-center",
                editable: false,
            },
            {
                dataField: "sort_no",
                headerText: "정렬순서",
                width : "20%",
                style : "aui-center aui-editable",
                editable: true,
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
				},
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "시작레벨", 
				dataField : "min_biz_level", 
				width : "90", 
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {				
					type : "DropDownListRenderer",
					list : levelList,
					keyField : "code_value",
					valueField : "code_name"
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<levelList.length; i++){
						if(value == levelList[i].code_value){
							return levelList[i].code_name;
						}
					}
					return value;
				},
			},
			{ 
				headerText : "종료레벨", 
				dataField : "max_biz_level", 
				width : "90", 
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {				
					type : "DropDownListRenderer",
					list : levelList,
					keyField : "code_value",
					valueField : "code_name"
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<levelList.length; i++){
						if(value == levelList[i].code_value){
							return levelList[i].code_name;
						}
					}
					return value;
				},
			},
        ];

        // 그리드 생성
        auiGridGroup = AUIGrid.create("#auiGridGroup", columnLayout, gridPros);
        
		// 추가된 행 벨리데이션
		AUIGrid.bind(auiGridGroup, "cellEditBegin", function (event) {
			if (event.dataField == "min_biz_level" || event.dataField == "max_biz_level") {
				if (!AUIGrid.isAddedById(event.pid, event.item._$uid)) {
					return true;
				} else {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridGroup, event.rowIndex, event.columnIndex, "새로 추가된행은 직군을 먼저 저장 후 레벨설정을 진행 해 주세요.");
					}, 1);
					return false;
				}
			}
		});
        
		AUIGrid.bind(auiGridGroup, "cellEditEnd", function (event) {
			var minLevel = event.item.min_biz_level;
			var maxLevel = event.item.max_biz_level;
			
			if (event.dataField == "use_yn") {
				// 해당직군에 포함된 조직원이 없을경우에만 사용여부 N 처리 가능.
				if (event.item.group_count != 0) {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridGroup, event.rowIndex, event.columnIndex, "해당 직군에 포함된 조직원이 있을경우 불가능합니다.");
					}, 1);
					
					AUIGrid.updateRow(auiGridGroup, { "use_yn" : "Y"}, event.rowIndex);
				} else if (event.value == "N") {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridGroup, event.rowIndex, event.columnIndex, "사용해제시 레벨은 초기화 됩니다.");
					}, 1);
					AUIGrid.updateRow(auiGridGroup, { "min_biz_level" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGridGroup, { "max_biz_level" : ""}, event.rowIndex);
				}
			}
			
			// 시작레벨 벨리데이션
			if (event.dataField == "min_biz_level") {
				if ((maxLevel != "" || maxLevel != 0) && $M.toNum(minLevel) > $M.toNum(maxLevel)) {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridGroup, event.rowIndex, event.columnIndex, "시작레벨은 종료레벨보다 작아야 합니다.");
					}, 1);
					
					AUIGrid.updateRow(auiGridGroup, { "min_biz_level" : ""}, event.rowIndex);
				}
			}
			
			// 종료레벨 벨리데이션
			if (event.dataField == "max_biz_level") {
				if (minLevel == "") {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridGroup, event.rowIndex, event.columnIndex, "시작레벨을 먼저 설정 해 주세요.");
					}, 1);
					
					AUIGrid.updateRow(auiGridGroup, { "max_biz_level" : ""}, event.rowIndex);
				}
				
				if ((minLevel != "" || minLevel != 0)&& $M.toNum(minLevel) > $M.toNum(maxLevel)) {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridGroup, event.rowIndex, event.columnIndex, "종료레벨은 시작레벨보다 높아야 합니다.");
					}, 1);
					
					AUIGrid.updateRow(auiGridGroup, { "max_biz_level" : ""}, event.rowIndex);					
				}
			}
		});
    }
	
	function goSearch() {
		var param = {};
				
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGridGroup, result.list);
					
					rowNum = result.rowNum;
				};
			}		
		);	
	}
	
	function fnClose() {
		window.close();
	}
	
	// 행추가
	function fnAdd() {
		var item = new Object();
		if(fnCheckGridEmpty(auiGridGroup)) {
			item.code = rowNum;
			item.code_name = "";
			item.group_count = 0;
			item.sort_no = "";
			item.use_yn = "Y";
			
			rowNum++;
			AUIGrid.addRow(auiGridGroup, item, 'last');
		}
	}
	
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGridGroup, ["code_name", "sort_no"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	// 저장
	function goSave() {
		if(fnCheckGridEmpty(auiGridGroup) == false) {
			return;
		}
		
		var addGridData = AUIGrid.getAddedRowItems(auiGridGroup);  // 추가내역
		var changeGridData = AUIGrid.getEditedRowItems(auiGridGroup); // 변경내역
		
		if (changeGridData.length == 0 && addGridData.length == 0) {
			alert("변경내역이 없습니다.");
			return;
		}
		
		for (var i = 0; i < changeGridData.length; i++) {
			var minLevel = changeGridData[i].min_biz_level;
			var maxLevel = changeGridData[i].max_biz_level;
			
			if ((minLevel != "" || minLevel != 0) && (maxLevel == "" || maxLevel == 0)) {
				alert("시작레벨을 지정하면 종료레벨도 지정해야 합니다.");
				return;
			}
		}
		
		var codeArr = [];
		var codeNameArr = [];
		var sortNoArr = [];
		var useYnArr = [];
		var cmdArr = [];
		
		var minBizLevelArr = [];
		var maxBizLevelArr = [];
		
		for (var i = 0; i < addGridData.length; i++) {
			codeArr.push(addGridData[i].code);
			codeNameArr.push(addGridData[i].code_name);
			sortNoArr.push(addGridData[i].sort_no);
			useYnArr.push(addGridData[i].use_yn);
			cmdArr.push("C");
			
			minBizLevelArr.push(addGridData[i].min_biz_level);
			maxBizLevelArr.push(addGridData[i].max_biz_level);
		}
		
		for (var i = 0; i < changeGridData.length; i++) {
			codeArr.push(changeGridData[i].code);
			codeNameArr.push(changeGridData[i].code_name);
			sortNoArr.push(changeGridData[i].sort_no);
			useYnArr.push(changeGridData[i].use_yn);
			cmdArr.push("U");
			
			minBizLevelArr.push(changeGridData[i].min_biz_level);
			maxBizLevelArr.push(changeGridData[i].max_biz_level);
		}
		
		var option = {
				isEmpty : true
		};
		
		var param = {
				code_str : $M.getArrStr(codeArr, option),
				code_name_str : $M.getArrStr(codeNameArr, option),
				sort_no_str : $M.getArrStr(sortNoArr, option),
				use_yn_str : $M.getArrStr(useYnArr, option),
				cmd_str : $M.getArrStr(cmdArr, option),
				min_biz_level_str : $M.getArrStr(minBizLevelArr, option),
				max_biz_level_str : $M.getArrStr(maxBizLevelArr, option)
		}
		
		console.log(param);
		
		$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			goSearch();
				}
			}
		);
		
	}
	</script>
</head>
<body class="bg-white">
<!-- 팝업 -->
<div class="popup-wrap width-100per">
    <!-- 타이틀영역 -->
    <div class="main-title">
        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <!-- /타이틀영역 -->
    <div class="content-wrap">
        <!-- 그룹 영역 -->
        <div class="title-wrap">
            <div class="left">
                <h4>직군관리</h4>
            </div>
            <div class="right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
            </div>
        </div>
        <div id="auiGridGroup" style="margin-top: 5px; height: 300px;"></div>
        <!-- /그룹 영역 -->
        <!-- 버튼 영역 -->
        <div class="btn-group mt10 mr5">
            <div class="right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
            </div>
        </div>
        <!-- /버튼 영역 -->
    </div>
</div>
<!-- /팝업 -->
</body>
</html>