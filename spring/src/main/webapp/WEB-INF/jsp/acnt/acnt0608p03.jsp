<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 인센티브평가 비중관리 > null > 평가항목 코드관리
-- 작성자 : 이강원
-- 최초 작성일 : 2021-09-02 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">
	var auiGrid;
	var groupJson = [{"code_value":"공통","code_name":"공통"}];
	var groupJson2 = [{"code_value":"마케팅","code_name":"마케팅"},{"code_value":"서비스","code_name":"서비스"},{"code_value":"관리","code_name":"관리"},{"code_value":"부품","code_name":"부품"},{"code_value":"공통","code_name":"공통"}];
	
	$(document).ready(function () {
		<%--var orgCode = '${SecureUser.org_code}'.substr(0,1);--%>
		if("${page.fnc.F03340_001}" == "Y"){
			// 관리
			var obj = [{"code_value":"마케팅","code_name":"마케팅"},{"code_value":"서비스","code_name":"서비스"},{"code_value":"관리","code_name":"관리"},{"code_value":"부품","code_name":"부품"}];
			groupJson = groupJson.concat(obj);
		}else if("${page.fnc.F03340_002}" == "Y"){
			// 영업
			var obj = {"code_value":"마케팅","code_name":"마케팅"};
			groupJson.push(obj);
		}else if("${page.fnc.F03340_003}" == "Y"){
			// 서비스
			var obj = {"code_value":"서비스","code_name":"서비스"};
			groupJson.push(obj);
		}else if("${page.fnc.F03340_004}" == "Y"){
			// 부품
			var obj = {"code_value":"부품","code_name":"부품"};
			groupJson.push(obj);
		}
		
		// 그리드 생성
		createAUIGrid();
		
	});
	
	// 그리드 생성
	function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                editable: true,
            };
            var columnLayout = [
            	{
                    dataField: "group_code",
                    visible: false
                },
            	{
                    dataField: "code",
                    visible: false
                },
                {
                    dataField: "use_yn",
                    visible: false
                },
                {
                    dataField: "code_v1",
                    headerText: "연관부서",
                    style : "aui-center",
                    width : "70",
                    required : true,
                    editRenderer: {
                        type: "DropDownListRenderer",
                        showEditorBtn: false,
                        showEditorBtnOver: true,
                        list: groupJson,
                        keyField: "code_value",
                        valueField: "code_name"
                    },
                    labelFunction: function (rowIndex, columnIndex, value) {
                        for (var i in groupJson2) {
                            if (groupJson2[i].code_value == value) {
                                return groupJson2[i].code_name;
                            }
                        }
                        return "";
                    }
                },
                {
                    dataField: "code_name",
                    headerText: "평가항목",
                    style: "aui-editable",
                    width : "100",
                    required : true,
                },
                {
                    dataField: "code_v3",
                    headerText: "단위",
                    style: "aui-editable",
                    width : "70",
                    required : true,
                },
                {
                    dataField: "code_desc",
                    headerText: "비고",
                    style: "aui-editable",
                    width : "200",
                },
                {
                    dataField: "removeBtn",
                    headerText: "삭제",
                    width: "50",
                    renderer: {
                        type: "ButtonRenderer",
                        onClick: function (event) {
                        	var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
                            if(!isRemoved){
                            	if(event.item.eval_cnt != "0"){
                                	alert("해당 평가항목을 사용한 그룹이 있습니다. 해당 항목을 제거 후 다시 시도해주세요.");
                            		return false;
                            	}
                            	AUIGrid.updateRow(auiGrid, { "use_yn" : "N" }, event.rowIndex);
                            	AUIGrid.removeRow(event.pid, event.rowIndex);
                            }else{
                            	AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
                            	AUIGrid.updateRow(auiGridReportOrder, { "use_yn" : "Y" }, event.rowIndex);
                            }
                        	
                        }
                    },
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return '삭제'
                    },
                    style: "aui-center",
                    editable: false,
                    filter: {
                        showIcon: true
                    },
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, ${list});
            
            AUIGrid.bind(auiGrid,"cellEditBegin",myAuiGridHandler);
    }
	
	function myAuiGridHandler(event){
		switch(event.type){
			case "cellEditBegin":
				if(event.dataField == "code_v1" && event.item.code != "0000"){
					setTimeout(function () {
	                    AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "이미 저장한 평가항목의 연관부서는 변경할 수 없습니다.");
	                }, 1);
	        		return;
				}
			break;
		}
	}
	
	
	// 저장
	function goSave(){
		var changeCheck = fnChangeGridDataCnt(auiGrid);
		
		if(changeCheck == 0){
			alert("변경사항이 없습니다.");
			return;
		}
		
		var isValid = AUIGrid.validation(auiGrid);
        if (!isValid) {
            return;
        }
        
        var gridFrm = fnChangeGridDataToForm(auiGrid);
		
		$M.goNextPageAjaxSave(this_page + "/save", gridFrm , {method : 'POST'},
			function(result){
				if(result.success){
	    			
					window.close();
				}
			}
		);
	}
	
	function fnAdd(){
        var item = new Object();
        item.group_code = "INCEN_EVAL";
        item.code = "0000";
        item.code_v1 = "";
        item.code_name = "";
        item.code_v3 = "";
        item.code_desc = "";
        item.eval_cnt = "0";
        item.use_yn = "Y";
        AUIGrid.addRow(auiGrid, item, 'last');
	}
	
	// 닫기
	function fnClose(){
		window.close();
	}
</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- 팝업 -->
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
<!-- /타이틀영역 -->
	<div class="content-wrap">
<!-- 발령상세 -->	
		<!-- 그리드 타이틀, 컨트롤 영역 -->
		<div class="title-wrap">
			<h4 class="primary">
				평가항목 코드관리
			</h4>
			<div class="right">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
			</div>
		</div>
		<div>
		<!-- 기본 -->	
<!-- /그리드 타이틀, 컨트롤 영역 -->					
			<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">					
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- /기본 -->
		</div>
	</div>					
</div>		
</form>	
</body>
</html>