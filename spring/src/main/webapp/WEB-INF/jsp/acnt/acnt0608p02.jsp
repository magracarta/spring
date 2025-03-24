<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 인센티브평가 비중관리 > null > Range구간 설정
-- 작성자 : 정재호
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">
	var auiGrid;
	var numberFormat = "thousand";
	
	$(document).ready(function () {
		// 그리드 생성
		createAUIGrid();
		if("${inputParam.code_v3}" != "금액"){
			numberFormat = "all";
		}
	});
	
	// 그리드 생성
	function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                softRemoveRowMode : false,
                editable: true,
            };
            var columnLayout = [
                {
                    dataField: "incen_grp_seq",
                    visible: false
                },
                {
                    dataField: "rate_seq_no",
                    visible: false
                },
                {
                    dataField: "seq_no",
                    visible: false
                },
                {
                    dataField: "use_yn",
                    visible: false
                },
                {
                    dataField: "range_level",
                    headerText: "레벨",
                    style: "aui-center",
                    editable : false,
                },
                {
                    dataField: "start_range",
                    headerText: "시작구간(${inputParam.code_v3})",
                    style: "aui-background-darkgray",
                    width : "150",
                    editable : false,
                    labelFunction : function(rowIndex,columnIndex, value, headerText, item){
                    	if("${inputParam.code_v3}" == "금액" && numberFormat == "all" && value != ""){
                    		return $M.setComma(value);
                    	}else if("${inputParam.code_v3}" == "금액" && value != ""){
                    		return $M.setComma(Math.floor($M.toNum(value)/1000));
                    	}
             			return value;
                    },
                },
                {
                    dataField: "end_range",
                    headerText: "종료구간(${inputParam.code_v3})",
                    style: "aui-center",
                    width : "150",
                    required : true,
                    editRenderer: {
                        type: "InputEditRenderer",
                        onlyNumeric: true
                    },
					labelFunction : function(rowIndex,columnIndex, value, headerText, item){
						if("${inputParam.code_v3}" == "금액" && numberFormat == "all" && value != ""){
                    		return $M.setComma(value);
                    	}else if("${inputParam.code_v3}" == "금액" && value != ""){
                    		return $M.setComma(Math.floor($M.toNum(value)/1000));
                    	}
             			return value;
                    },
                },
                {
                    dataField: "range_point",
                    headerText: "구간점수",
                    style: "aui-center",
                    required : true,
                    width : "100",
                    editRenderer: {
                        type: "InputEditRenderer",
                        onlyNumeric: true
                    },
                },
                {
                    dataField: "removeBtn",
                    headerText: "삭제",
                    width: "50",
                    renderer: {
                        type: "ButtonRenderer",
                        onClick: function (event) {
                        	var check;
                        	if(event.item.seq_no == "0"){
                            	check = true;
                        	}else{
                            	check = confirm("삭제하시겠습니까?");
                        	}
                        	if(check){
                        		var nowrange_level = $M.toNum(event.item.range_level);
                        		var data = AUIGrid.getGridData(auiGrid);
                        		if(nowrange_level != data.length){
                        			for(var i=0;i<data.length;i++){
                            			var temprange_level = $M.toNum(data[i].range_level);
                            			if(temprange_level > nowrange_level){
                            				if(temprange_level == nowrange_level+1){
                            					AUIGrid.updateRow(auiGrid, {"start_range": event.item.start_range}, i);	
                            				}
                            				AUIGrid.updateRow(auiGrid, {"range_level": temprange_level-1}, i);	
                            			}
                            		}
                        		}
                        		if(event.item.seq_no != "0"){
                        			if($M.getValue("delete_seq_no_str") == ""){
                        				$M.setValue("delete_seq_no_str",event.item.seq_no+"#");
                        			}else{
                        				$M.setValue("delete_seq_no_str",$M.getValue("delete_seq_no_str")+event.item.seq_no+"#");
                        			}
                        		}
                        		AUIGrid.updateRow(auiGrid, {"use_yn": "N"}, event.rowIndex);
                        		AUIGrid.removeRow(event.pid, event.rowIndex);
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

            // 셀 클릭 이벤트
            AUIGrid.bind(auiGrid, "cellEditEnd", auiEventHandler);
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
		
        AUIGrid.clearSortingAll(auiGrid);
        
        var gridFrm = fnChangeGridDataToForm(auiGrid);
		
		$M.goNextPageAjaxSave(this_page + "/save", gridFrm , {method : 'POST'},
			function(result){
				if(result.success){
	    			if (opener != null && opener.${inputParam.parent_js_name}) {
	    				var data = AUIGrid.getGridData(auiGrid);
	    				var content = "";
	    				for(var i=0;i<data.length;i++){
	    					content += data[i].range_level + "레벨 : " + data[i].range_point + "점 | ";
	    				}
	    				content = content.substring(0,content.length-2);
						opener.${inputParam.parent_js_name}(content, ${inputParam.row_index});
					}
					window.close();
				}
			}
		);
	}
	
	function auiEventHandler(event){
		console.log(event);
		switch(event.type){
			case "cellEditEnd" :
				if(event.value == event.oldValue){
					return event.oldValue;
				}
				if(numberFormat == "thousand"){
					event.value = event.value*1000;
				}
				if(event.dataField == "end_range"){
					var data = AUIGrid.getGridData(auiGrid);
					var range_level = $M.toNum(event.item.range_level);
					if($M.toNum(event.value) <= $M.toNum(event.item.start_range)){
						setTimeout(function () {
                            AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "종료구간은 시작구간보다 커야합니다.");
                        }, 1);
						AUIGrid.updateRow(auiGrid, {"end_range": ""}, event.rowIndex);
						return false;
					}
					
					for(var i=range_level-2; i>=0; i--){
						if(data[i].end_range != "" && data[i].end_range != undefined && ($M.toNum(data[i].end_range) >= $M.toNum(event.value) - 1)){
							setTimeout(function () {
	                            AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "종료구간은 이전구간의 종료구간보다 커야합니다.");
	                        }, 1);
							AUIGrid.updateRow(auiGrid, {"end_range": ""}, event.rowIndex);
							return false;
						}
					}
					
					for(var i=range_level;i<data.length;i++){
						if(data[i].end_range != "" && data[i].end_range != undefined && ($M.toNum(data[i].end_range) - 1 <= $M.toNum(event.value))){
							setTimeout(function () {
	                            AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "종료구간은 다음구간의 종료구간보다 작아야합니다.");
	                        }, 1);
							AUIGrid.updateRow(auiGrid, {"end_range": ""}, event.rowIndex);
							return false;
						}
					}
					
					if(range_level != data.length){
						AUIGrid.updateRow(auiGrid, {"end_range": event.value}, event.rowIndex);
						AUIGrid.updateRow(auiGrid, {"start_range": $M.toNum(event.value)+1}, $M.toNum(event.rowIndex)+1);
					}else{
						AUIGrid.updateRow(auiGrid, {"end_range": event.value}, event.rowIndex);
					}
				} else if(event.dataField == "range_point"){
					if(event.value == 0){
						setTimeout(function () {
                            AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "구간점수는 0보다 커야합니다.");
                        }, 1);
						AUIGrid.updateRow(auiGrid, {"range_point": ""}, event.rowIndex);
						return false;
					}
				}
				break;	
		}
	}
	
	// 행 추가
	function fnAdd(){
		var data = AUIGrid.getGridData(auiGrid);
		var item = new Object();
        item.incen_grp_seq = $M.getValue("now_incen_grp_seq");
        item.rate_seq_no = $M.getValue("now_rate_seq_no");
        item.seq_no = "0";
        item.use_yn = "Y";
        if(data.length == 0){
            item.start_range = "0";
            item.range_level = "1";
        } else{
        	if(data[data.length-1].end_range != ""){
                item.start_range = $M.toNum(data[data.length-1].end_range)+1;
        	}else{
        		item.start_range = "";
        	}
        	item.range_level = data.length + 1;
        }
        item.end_range = "";
        item.range_point = "";
        AUIGrid.addRow(auiGrid, item, 'last');
	}
	
	function fnSetNumberFormatToggle() {
		if (numberFormat == "all") {
			numberFormat = "thousand";
		} else {
			numberFormat = "all"
		}

		AUIGrid.resize(auiGrid);
	}
	
	// 닫기
	function fnClose(){
		window.close();
	}
</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="now_incen_grp_seq" name="now_incen_grp_seq" value="${inputParam.incen_grp_seq }"/>
<input type="hidden" id="now_rate_seq_no" name="now_rate_seq_no" value="${inputParam.rate_seq_no }"/>

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
				${inputParam.incen_eval_name } 비중 : ${inputParam.weight_point }
			</h4>	
			<div class="right text-warning">
                                                             ※ 최대 종료구간이 max값을 넘었을 시 마지막 구간으로 인식됩니다.
            </div>	
			<div class="right">
				<c:if test="${inputParam.code_v3 eq '금액' }">
					<label for="s_toggle_numberFormat" style="color:black;">
						<input type="checkbox" id="s_toggle_numberFormat" checked="checked" onclick="javascript:fnSetNumberFormatToggle(event)"><span>천</span> 단위
					</label>
				</c:if>
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