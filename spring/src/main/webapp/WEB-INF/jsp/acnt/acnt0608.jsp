<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<!DOCTYPE html>
<html>

<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var auiGridGroup;
        var auiGridRate;
		// 그룹 이동 취소시 포커스 이동용 그룹이름 저장변수
		var curr_group_name;
		// 그룹설정 검색을 위한 현재 검색된 년도 저장변수
        var curr_incen_year = ${inputParam.s_current_year};

        var assetRealIncenJson = JSON.parse('${codeMapJsonObj['INCEN_EVAL']}'); // 인센티브 평가항목
		
        $(document).ready(function () {
            createAUIGridGroup();
            createAUIGridRate();
            goSearch();
        });


        /////////////////////// 기본 메서드 //////////////////////

        ////////////////////////////////////////////////////////

        ///////////////// 그룹 그리드 이벤트 메서드 ////////////////

        // 그룹 그리드 생성
        function createAUIGridGroup() {

            var gridPros = {
                rowIdField: "_$uid",
                editable: false
            };

            var columnLayout = [
                {
                    dataField: "incen_grp_seq",
                    visible: false
                },
                {
                    dataField: "group_name",
                    headerText: "그룹명",
                    style: "aui-center aui-link"
                },
                {
                    dataField: "group_count",
                    headerText: "조직원수",
                    style: "aui-center aui-link"
                }
            ];

            auiGridGroup = AUIGrid.create("#auiGridGroup", columnLayout, gridPros);
            AUIGrid.setGridData(auiGridGroup, []);

            // 셀 클릭 이벤트
            AUIGrid.bind(auiGridGroup, "cellClick", auiCellClickHandlerGroup);

        }

        // 그룹 그리드 - 셀 클릭 핸들러
        function auiCellClickHandlerGroup(event) {
            var field = event.dataField;
            switch (field) {
                case "group_name" :
                    if ($M.getValue("curr_incen_grp_seq") != event.item.incen_grp_seq) { // 다른 그룹 이름을 클릭했다면
                        if (fnChangeGridDataCnt(auiGridRate) != 0) {
                            if (confirm("저장하지 않고 넘어가겠습니까?") == true) {
                            } else {
                            	AUIGrid.search(auiGridGroup, "group_name", curr_group_name, {wholeWord : true});
                                return;
                            }
                        }
                    }

                    $M.setValue("curr_incen_grp_seq", event.item.incen_grp_seq);

                    var param = {
                        "incen_grp_seq": event.item.incen_grp_seq,
                    }

                    $M.goNextPageAjax(this_page + "/rate", $M.toGetParam(param), {method: 'get'}, function (result) {
                        if (result.success) {
                        	curr_group_name = event.value;
                            $M.setValue("total_weight", result.total_weight);
                            AUIGrid.setGridData(auiGridRate, result.list);
                            AUIGrid.setColumnProp(auiGridRate, 5, {
                                headerText: "비중 (" + $M.getValue("total_weight") + " / 100)"
                            });
                            AUIGrid.resetUpdatedItems(auiGridRate);
                        }
                    });

                    break;
                case "group_count" :

                    var param = {
                        "s_incen_year": curr_incen_year,
                        "incen_grp_seq": event.item.incen_grp_seq,
                    }
                    $M.goNextPage('/acnt/acnt0608p01', $M.toGetParam(param), {popupStatus: ''});
                    break;
            }
        }

        // 비중관리 그리드 생성
        function createAUIGridRate() {

            var gridPros = {
                rowIdField: "_$uid",
                editable: true,
                showStateColumn: true
            };

            var columnLayout = [
                {
                    dataField: "incen_grp_seq",
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
                    dataField: "incen_eval_cd",
                    headerText: "평가항목 명",
                    width: "150",
                    minWidth: "100",
                    required: true,
                    editRenderer: {
                        type: "DropDownListRenderer",
                        showEditorBtn: false,
                        showEditorBtnOver: true,
                        list: assetRealIncenJson,
                        keyField: "code_value",
                        valueField: "code_name"
                    },
                    labelFunction: function (rowIndex, columnIndex, value) {
                        for (var i in assetRealIncenJson) {
                            if (assetRealIncenJson[i].code_value == value) {
                                return assetRealIncenJson[i].code_name;
                            }
                        }
                        return "";
                    }
                },
                {
                    dataField: "auto_cal_yn",
                    headerText: "평가구분",
                    editable: false,
                    width: "150",
                    minWidth: "100",
                    style :"aui-background-darkgray",
                    labelFunction: function (rowIndex, columnIndex, value) {
                        var str = "";
                        if (value == 'Y') {
                            str = "자동계산";
                        } else if (value == 'N') {
                            str = "임의등록";
                        }
                        return str;
                    }
                },
                {
                    dataField: "weight_rate",
                    required: true,
                    width: "100",
                    minWidth: "70",
                    headerText: "비중 (" + $M.getValue('total_weight') + " / 100)",
                    editRenderer: {
                        type: "InputEditRenderer",
                        onlyNumeric: true
                    },
                },
                {
                    dataField: "range_point_content",
                    headerText: "Range구간",
                    width: "300",
                    minWidth: "200",
                    styleFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        if (item.auto_cal_yn != 'Y') {
                            return "aui-background-darkgray";
                        } else {
                            return "aui-popup";
                        }
                    },
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        var str = "";
                        if (value == "" && item.auto_cal_yn == 'Y') {
                            str = "설정";
                        } else if (value != "") {
                            str = value;
                        }

                        return str;
                    },
                    editable: false,
                },
                {
                    dataField: "removeBtn",
                    headerText: "삭제",
                    width: "50",
                    renderer: {
                        type: "ButtonRenderer",
                        onClick: function (event) {
                        	if(event.item.incen_eval_cd == "0301" || event.item.incen_eval_cd == "0302" || event.item.incen_eval_cd == "0303"){
                        		setTimeout(function () {
                                    AUIGrid.showToastMessage(auiGridRate, event.rowIndex, event.columnIndex, "공통항목은 필수요소로 삭제할 수 없습니다.");
                                }, 1);
                        		return;
                        	}
                            var total_weight = $M.getValue("total_weight");
                            var isRemoved = AUIGrid.isRemovedById(auiGridRate, event.item._$uid);
                            if (isRemoved == false) {
                                $M.setValue("total_weight", $M.toNum(total_weight) - $M.toNum(event.item.weight_rate));
                                AUIGrid.setColumnProp(auiGridRate, 5, {
                                    headerText: "비중 (" + $M.getValue("total_weight") + " / 100)"
                                });
                                AUIGrid.updateRow(auiGridRate, {use_yn: "N"}, event.rowIndex);
                                AUIGrid.removeRow(event.pid, event.rowIndex);
                            } else {
                                if ($M.toNum(total_weight) == 100) {
                                    alert("총 평가항목 비중을 100보다 작게 만든 후 시도해주세요.");
                                    return;
                                } else if ($M.toNum(total_weight) + $M.toNum(event.item.weight_rate) > 100) {
                                    AUIGrid.restoreSoftRows(auiGridRate, "selectedIndex");
                                    AUIGrid.updateRow(auiGridRate, {weight_rate: 100 - total_weight}, event.rowIndex);
                                } else {
                                    AUIGrid.restoreSoftRows(auiGridRate, "selectedIndex");
                                }
                                AUIGrid.updateRow(auiGridRate, {use_yn: "Y"}, event.rowIndex);
                                $M.setValue("total_weight", $M.toNum(total_weight) + $M.toNum(event.item.weight_rate));
                                AUIGrid.setColumnProp(auiGridRate, 5, {
                                    headerText: "비중 (" + $M.getValue("total_weight") + " / 100)"
                                });
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

            auiGridRate = AUIGrid.create("#auiGridRate", columnLayout, gridPros);
            AUIGrid.setGridData(auiGridRate, []);

            AUIGrid.bind(auiGridRate, "cellClick", auiHandlerRate);
            AUIGrid.bind(auiGridRate, "cellEditEndBefore", auiHandlerRate);
            AUIGrid.bind(auiGridRate, "cellEditBegin", auiHandlerRate);
            AUIGrid.bind(auiGridRate, "rowStateCellClick", auiHandlerRate);

        }

        // 평가항목 그리드 - 셀 클릭 핸들러
        function auiHandlerRate(event) {
            var type = event.type;
            switch (type) {
                case "cellClick" :
                    if (event.dataField == "range_point_content") {
                        if (event.item.auto_cal_yn != 'Y' || event.item.use_yn == 'N') {
                            return false;
                        }
                        if (event.item.weight_rate == "") {
                            setTimeout(function () {
                                AUIGrid.showToastMessage(auiGridRate, event.rowIndex, event.columnIndex, "비중을 먼저 입력해주세요.");
                            }, 1);
                        } else {
                            if (event.item.seq_no == "0") {
                                alert("저장 후 다시 시도해주세요.");
                                return false;
                            }

                            var code_v3;
                            for (var i in assetRealIncenJson) {
                                if (assetRealIncenJson[i].code_value == event.item.incen_eval_cd) {
                                    code_v3 = assetRealIncenJson[i].code_v3;
                                }
                            }
                            var incen_eval_name;
                            for (var i in assetRealIncenJson) {
                                if (assetRealIncenJson[i].code_value == event.item.incen_eval_cd) {
                                	incen_eval_name = assetRealIncenJson[i].code_name;
                                }
                            }
                            var params = {
                                "incen_grp_seq": event.item.incen_grp_seq,
                                "incen_eval_name": incen_eval_name,
                                "rate_seq_no": event.item.seq_no,
                                "weight_point": event.item.weight_rate,
                                "row_index": event.rowIndex,
                                "code_v3": code_v3,
                                "parent_js_name": "setRangePointContent"
                            }
                            $M.goNextPage('/acnt/acnt0608p02', $M.toGetParam(params), {popupStatus: ""});
                        }
                    }
                    break;
                case "cellEditEndBefore" :
                    if (event.dataField == "incen_eval_cd") {
                        var total_weight = $M.getValue("total_weight");
                        var isValid = AUIGrid.isUniqueValue(auiGridRate, event.dataField, event.value);

                        if(event.oldValue == event.value){
                        	return ;
                        }

                        if (!isValid && event.value != "") {
                            setTimeout(function () {
                                AUIGrid.showToastMessage(auiGridRate, event.rowIndex, event.columnIndex, "이미 존재하는 평가항목입니다.");
                            }, 1);
                            $M.setValue("total_weight", $M.toNum(total_weight) - $M.toNum(event.item.weight_rate));
                            AUIGrid.setColumnProp(auiGridRate, 5, {
                                headerText: "비중 (" + $M.getValue("total_weight") + " / 100)"
                            });
                            AUIGrid.setCellValue(auiGridRate, event.rowIndex, "incen_eval_cd", "");
                            AUIGrid.setCellValue(auiGridRate, event.rowIndex, "auto_cal_yn", "");
                            AUIGrid.setCellValue(auiGridRate, event.rowIndex, "weight_rate", "");
                            AUIGrid.setCellValue(auiGridRate, event.rowIndex, "range_point_content", "");
                            return "";
                        }

                        var autoYn;
                        for (var i in assetRealIncenJson) {
                        	if(assetRealIncenJson[i].code_value == event.value){
                        		autoYn = assetRealIncenJson[i].code_v2;
                        		break;
                        	}
                        }
                       	if(autoYn == 'N'){
                       		AUIGrid.setCellValue(auiGridRate, event.rowIndex, "auto_cal_yn", "N");
                       	}else if(autoYn != ""){
                       		AUIGrid.setCellValue(auiGridRate, event.rowIndex, "auto_cal_yn", "Y");
                       	}

                        $M.setValue("total_weight", $M.toNum(total_weight) - $M.toNum(event.item.weight_rate));
                        AUIGrid.setColumnProp(auiGridRate, 5, {
                            headerText: "비중 (" + $M.getValue("total_weight") + " / 100)"
                        });
                        AUIGrid.updateRow(auiGridRate, {"weight_rate": ""}, event.rowIndex);
                        AUIGrid.updateRow(auiGridRate, {"range_point_content": ""}, event.rowIndex);
                    } else if (event.dataField == "weight_rate") {
                    	if(event.oldValue == event.value){
                    		return event.oldValue;
                    	}
                        var total_weight = $M.getValue("total_weight");
                        if ($M.toNum(total_weight) - $M.toNum(event.oldValue) + $M.toNum(event.value) > 100) {
                            setTimeout(function () {
                                AUIGrid.showToastMessage(auiGridRate, event.rowIndex, event.columnIndex, "비중의 합이 100을 넘었습니다.");
                            }, 1);
                            $M.setValue("total_weight", $M.toNum(total_weight) - $M.toNum(event.oldValue));
                            AUIGrid.setColumnProp(auiGridRate, 5, {
                                headerText: "비중 (" + $M.getValue("total_weight") + " / 100)"
                            });
                            return "";
                        }
                        $M.setValue("total_weight", $M.toNum(total_weight) - $M.toNum(event.oldValue) + $M.toNum(event.value));
                        AUIGrid.setColumnProp(auiGridRate, 5, {
                            headerText: "비중 (" + $M.getValue("total_weight") + " / 100)"
                        });
                    }
                    break;
                case "cellEditBegin" :
                    if (event.dataField == "weight_rate") {
                        if (event.item.incen_eval_cd == "") {
                            return false;
                        }
                    } else if (event.dataField == "incen_eval_cd") {
                    	if(event.item.seq_no != "0"){
                    		setTimeout(function () {
                                AUIGrid.showToastMessage(auiGridRate, event.rowIndex, event.columnIndex, "이미 저장한 평가항목 명은 변경할 수 없습니다.");
                            }, 1);
                    		return false;
                    	}
                    	if(event.value == "0301" || event.value == "0302" || event.value == "0303"){
                    		setTimeout(function () {
                                AUIGrid.showToastMessage(auiGridRate, event.rowIndex, event.columnIndex, "공통항목은 필수요소로 변경할 수 없습니다.");
                            }, 1);
                    		return false;
                    	}
                    }
                    break;
                case "rowStateCellClick" :
                	if(event.marker == "removed"){
                        var total_weight = $M.getValue("total_weight");
                        if ($M.toNum(total_weight) == 100) {
                            alert("총 평가항목 비중을 100보다 작게 만든 후 시도해주세요.");
                            return false;
                        } else if ($M.toNum(total_weight) + $M.toNum(event.item.weight_rate) > 100) {
                            AUIGrid.restoreSoftRows(auiGridRate, "selectedIndex");
                            AUIGrid.updateRow(auiGridRate, {weight_rate: 100 - total_weight}, event.rowIndex);
                        } else {
                            AUIGrid.restoreSoftRows(auiGridRate, "selectedIndex");
                        }
                        AUIGrid.updateRow(auiGridRate, {use_yn: "Y"}, event.rowIndex);
                        $M.setValue("total_weight", $M.toNum(total_weight) + $M.toNum(event.item.weight_rate));
                        AUIGrid.setColumnProp(auiGridRate, 5, {
                            headerText: "비중 (" + $M.getValue("total_weight") + " / 100)"
                        });
    				}else if(event.marker == "edited"){
    					var oldValue = AUIGrid.getCellValue(auiGridRate, event.rowIndex, "weight_rate");
    					AUIGrid.restoreEditedCells(auiGridRate,[event.rowIndex,"weight_rate"]);
    					var value = AUIGrid.getCellValue(auiGridRate, event.rowIndex, "weight_rate");
    					
    					var total_weight = $M.getValue("total_weight");
                        if ($M.toNum(total_weight) - oldValue + $M.toNum(value) > 100) {
                            alert("수정을 취소할 시 평가항목 비중이 100이상이 되어 불가능합니다.");
                            AUIGrid.updateRow(auiGridRate, {weight_rate: oldValue}, event.rowIndex);
                            return false;
                        }
                        $M.setValue("total_weight", $M.toNum(total_weight) - oldValue + $M.toNum(value));
                        AUIGrid.setColumnProp(auiGridRate, 5, {
                            headerText: "비중 (" + $M.getValue("total_weight") + " / 100)"
                        });
    				}else if(event.marker == "added-edited"){
                        var total_weight = $M.getValue("total_weight");
                        $M.setValue("total_weight", $M.toNum(total_weight) - $M.toNum(event.item.weight_rate));
                        AUIGrid.setColumnProp(auiGridRate, 5, {
                            headerText: "비중 (" + $M.getValue("total_weight") + " / 100)"
                        });
    				}
                	break;
            }
        }

        ////////////////////////////////////////////////////////

        /////////////////////// 버튼 메서드 //////////////////////

        // 조회
        function goSearch() {
            var params = {
                "s_incen_year": $M.getValue("s_incen_year"),
                "s_sort_key": "incen_grp_seq",
                "s_sort_method": "desc"
            };
            $M.goNextPageAjax(this_page + '/search', $M.toGetParam(params), {method: 'get'}, function (result) {
                if (result.success) {
                    curr_incen_year = $M.getValue("s_incen_year");
                    AUIGrid.setGridData(auiGridGroup, result.list);
                    AUIGrid.setGridData(auiGridRate, []);
                    $M.setValue("total_weight", 0);
                    $M.setValue("curr_incen_grp_seq","");
                    AUIGrid.setColumnProp(auiGridRate, 5, {
                        headerText: "비중 (" + $M.getValue("total_weight") + " / 100)"
                    });
                }
            });
        }

       	function goCopy(){
       		if($M.getValue("s_incen_year") == $M.getValue("copy_incen_year")){
       			alert("같은 연도로는 복사할 수 없습니다.");
       			return;
       		}

       		if(!confirm("선택된 연도로 복사되며 복사될 연도의 기존 내용은 모두 삭제됩니다.")){
       			return;
       		}
       		var params = {
       			"s_incen_year" : $M.getValue("s_incen_year"),
       			"copy_incen_year" : $M.getValue("copy_incen_year"),
       		};
       		$M.goNextPageAjax(this_page + '/copy', $M.toGetParam(params), {method: 'post'}, function (result) {
                if (result.success) {
                    ;
                }
            });
       	}

        // 저장
        function goSave() {
            if ($M.getValue("curr_incen_grp_seq") == "") {
                alert("선택된 그룹이 없습니다.");
                return;
            }
            if ($M.getValue("total_weight") != 100) {
                alert("총 비중의 합은 100이 되어야합니다.");
                return;
            }

            var changeCnt = fnChangeGridDataCnt(auiGridRate);
            if (changeCnt == 0) {
                alert("변경사항이 없습니다.");
                return;
            }

            var isValid = AUIGrid.validation(auiGridRate);
            if (!isValid) {
                return;
            }

            // 정렬순서가 꼬여서 업데이트 row부터 form으로 만듬
            // 추가된 행 아이템들(배열)
			var addedRowItems = AUIGrid.getAddedRowItems(auiGridRate);
				 
			// 수정된 행 아이템들(배열)
			var editedRowItems = AUIGrid.getEditedRowItems(auiGridRate);
		
			// 삭제된 행 아이템들(배열)
			var removedRowItems = AUIGrid.getRemovedItems(auiGridRate);
			
			var frm = $M.createForm();
			
			// 그리드에 명시된 행만 추출함
			var columns = fnGetColumns(auiGridRate);
			
			for(var i = 0, n = editedRowItems.length; i < n; i++) {
				var row = editedRowItems[i];
				frm = fnToFormData(frm, columns, row);
				
				var hasCmd = 'cmd' in row;
				if(hasCmd == false) {
					$M.setHiddenValue(frm, 'cmd', 'U');
				}
			}
			for(var i = 0, n = addedRowItems.length; i < n; i++) {
				var row = addedRowItems[i];
				frm = fnToFormData(frm, columns, row);
				
				var hasCmd = 'cmd' in row;
				if(hasCmd == false) {
					$M.setHiddenValue(frm, 'cmd', 'C');
				}
			}
			for(var i = 0, n = removedRowItems.length; i < n; i++) {
				var row = removedRowItems[i];
				if (useYn != undefined && useYn != '') {
					row['use_yn'] = 'N';
				}
				frm = fnToFormData(frm, columns, row);
				var hasCmd = 'cmd' in row;
				if(hasCmd == false) {
					if (useYn != undefined) {
						$M.setHiddenValue(frm, 'cmd', 'U');
					} else {
						$M.setHiddenValue(frm, 'cmd', 'D');
					}
				}
			}

            $M.goNextPageAjaxSave(this_page + "/save", frm, {method: 'post'}, function (result) {
                if (result.success) {
					AUIGrid.setGridData(auiGridRate,result.list);
                }
            });

        }

        // 그룹설정
        function goGroupSet() {
            var param = {
                "s_incen_year": curr_incen_year
            }
            $M.goNextPage('/acnt/acnt0608p01', $M.toGetParam(param), {popupStatus: ''});
        }

        // 행추가
        function fnAdd() {
        	if ($M.getValue("curr_incen_grp_seq") == undefined || $M.getValue("curr_incen_grp_seq") == "") {
                alert("그룹을 선택해주세요.");
                return;
            }
            var item = new Object();
            item.incen_grp_seq = $M.getValue("curr_incen_grp_seq");
            item.seq_no = "0";
            item.incen_eval_cd = "";
            item.auto_cal_yn = "";
            item.weight_rate = "";
            item.use_yn = "Y";
            item.range_point_content = "";
            AUIGrid.addRow(auiGridRate, item, 'last');
        }

        // range설정 리턴함수
        function setRangePointContent(content, rowIndex) {
            AUIGrid.updateRow(auiGridRate, {"range_point_content": content}, rowIndex);
        }
        
        // 평가항목 코드관리
        function goAddPage(){
        	var param = {};
            $M.goNextPage('/acnt/acnt0608p03', $M.toGetParam(param), {popupStatus: ''});
        }

        ////////////////////////////////////////////////////////

    </script>
    <meta charset="UTF-8">
    <title>Insert title here</title>
</head>

<body>
<form id="main_form" name="main_form">
    <input type="hidden" id="total_weight" name="total_weight" value="0"/>
    <input type="hidden" id="curr_incen_grp_seq" name="curr_incen_grp_seq"/>
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <!-- 메인 타이틀 -->
                <div class="main-title">
                    <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
                </div>
                <!-- /메인 타이틀 -->
                <div class="contents">
                    <!-- 검색영역 -->
                    <div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="55px">
                                <col width="100px">
                                <col width="150px">
                                <col width="150px">
                                <col width="100px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>조회년도</th>
                                <td>
                                    <jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
										<jsp:param name="year_name" value="s_incen_year"/>
										<jsp:param name="sort_type" value="d"/>
										<jsp:param name="plus_minus" value="5"/>
									</jsp:include>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important" style="width: 50px;"
                                            onclick="javascript:goSearch();">조회
                                    </button>
                                </td>
                                <th>그룹과 평가항목 비중설정</th>
                                <td>
                                    <jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
										<jsp:param name="year_name" value="copy_incen_year"/>
										<jsp:param name="sort_type" value="d"/>
										<jsp:param name="plus_minus" value="5"/>
									</jsp:include>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important" style="width: 50px;"
                                            onclick="javascript:goCopy();">복사
                                    </button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- 조회결과 -->
                    <div class="row">
                        <!-- 그룹목록 -->
                        <div class="col-4">
                            <div class="title-wrap mt10">
                                <h4>그룹목록</h4>
                                <div class="right">
                                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                                        <jsp:param name="pos" value="TOP_L"/>
                                    </jsp:include>
                                </div>
                            </div>
                            <div id="auiGridGroup" style="margin-top: 5px; height: 500px;"></div>
                        </div>
                        <!-- /그룹목록 -->
                        <!-- 평가항목 비중관리 -->
                        <div class="col-8">
                            <div class="title-wrap mt10">
                                <h4>평가항목 비중관리</h4>
                                <div class="right">
                                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                                        <jsp:param name="pos" value="TOP_R"/>
                                    </jsp:include>
                                </div>
                            </div>
                            <div id="auiGridRate" style="margin-top: 5px; height: 500px;"></div>
                        </div>
                        <!-- /평가항목 비중관리-->
                    </div>
                    <!-- /조회결과 -->
                    <div class="btn-group mt5">
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                                <jsp:param name="pos" value="BOM_R"/>
                            </jsp:include>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>

</html>