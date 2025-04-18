<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 메뉴관리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
-- 2022-12-08 jsk : erp3-2차 추가설정관리 추가
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	var auiGridBtnLeft;
	var auiGridBtnRight;
	var auiGridAdd;
	var isExpanded; // 멀티셀렉트 보이는지 체크
	var btnPosConvertArray = JSON.parse('${codeMapJsonObj['BTN_POS']}');
	var btnAccessArray = [{code_value : "G", code_name : "일반"}, {code_value : "W", code_name : "작성자"}, {code_value : "M", code_name : "관리"}];
	var btnClassIdArray = ${orgList};
	var btnGradeArray = JSON.parse('${codeMapJsonObj['GRADE']}');
	var btnMemArrayTemp = ${memListJson}
	var btnMemArray = [];
	
	$(document).ready(function() {
		fnInit();
		createAUIGrid();
		createBtnToNonPageAUIGrid();
		createBtnToPageAUIGrid();
		createAddAUIGrid();
		fnNew();
		goUpMenuSearch();
	});
	
	function fnInit() {
		btnMemArrayTemp.reduce(function(res, value) {
		  if (!res[value.mem_no]) {
		    res[value.mem_no] = { 
		    	mem_no: value.mem_no,
		    	mem_name : value.mem_name+"("+value.mem_no+")"
		    };
		    btnMemArray.push(res[value.mem_no]);
		  }
		  return res;
		}, {});
		console.log(btnMemArray);
	}
	
   //상위메뉴 select
	function goUpMenuSearch(up_menu_seq) {
	   console.log(up_menu_seq);
	   var param = {}
		$M.goNextPageAjax(this_page + "/upmenu", $M.toGetParam(param) , { method : 'get'},
			function(result) {            
				if(result.success){
					console.log(result);
					//페이지 정보 TABLE FORM의 상위메뉴select에 데이터 값 입력
					$("#up_menu_seq").html("");
					var comboList = result.list;
					$("#up_menu_seq").append("<option value=''>- 선택 -</option>");
					for(var i = 0 ; i < comboList.length ; i++) {
						var option = $("<option></option>");
						option.val(comboList[i].menu_seq);
						option.text(comboList[i].path_menu_name);	
						$("#up_menu_seq").append(option);
					};
					if (up_menu_seq != undefined){
						$M.setValue("up_menu_seq",up_menu_seq);
					}
					// $M.setValue("up_menu_seq","");
				};
			}
		)
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_menu_name", "s_url"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch('init');
			};
		});
	}
	
	//조회
	function goSearch(init) {
		var param = {
			"s_menu_name" : $M.getValue("s_menu_name"),
			"s_url" : $M.getValue("s_url"),
			"s_use_yn" : $M.getValue("s_use_yn"),
			"s_pop_yn" : $M.getValue("s_pop_yn"),
			"s_help_yn" : $M.getValue("s_help_yn")
		};
		$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					if (init != undefined) {
						fnNew();
						document.getElementById('menu_help_btn').style.visibility = "hidden";
					}
					AUIGrid.setGridData(auiGrid, result.list);
					AUIGrid.expandAll(auiGrid);
				}
			}
		);
	}
   
	//저장
	function goSave() {
		
		$M.setValue("search_dt_type_cd_str_temp", $M.getValue("search_dt_type_cd_str"));

		var frm = document.main_form;
		
		//대메뉴 체크확인
		var bigMenuChk = $("input:checkbox[id='up_menu_chk']").is(":checked"); 
		if($M.validation(frm) == false) {
			return;
		}

		//대메뉴인경우 상위메뉴번호 0셋팅
		if(bigMenuChk) {
			$("#up_menu_seq").attr("disabled",false);   
			$("#up_menu_seq").append("<option value='0'></option>");
			$M.setValue("up_menu_seq","0");
		};

		if($M.getValue("up_menu_seq") == '' && !bigMenuChk) {
			alert("상위메뉴는 필수입력입니다.");
			return;
		};

		if($M.getValue("sort_no")) {
			$("#hiddenParamDiv").empty();
		};

		if($M.validation(document.main_form, {field:['menu_name', 'url', 'sort_no']}) == false) {
			return;
		};

		// 팝업옵션 적용여부
		if($M.isCheckBoxSel("pop_option_apply")) {
			$M.setValue(frm, "pop_option_apply_yn", "Y");
		} else {
			$M.setValue(frm, "pop_option_apply_yn", "N");
		}

		// cmd가 C일 경우 등록
		if($M.getValue(frm, "cmd") == "C") {
			$M.goNextPageAjaxSave(this_page, frm , { method : 'POST'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);		
						// fnNew();
						goSearch();
						goUpMenuSearch($M.getValue("up_menu_seq"));
					}
				}
			)
		// cmd가 C가 아니면 수정
		} else {
			goUpdate();
		};
	}
	
	// 수정
	function goUpdate() {
		
		$M.setValue("search_dt_type_cd_str_temp", $M.getValue("search_dt_type_cd_str"));
		
		var frm = document.main_form;
		frm = $M.toValueForm(frm);
		
		if (confirm("기존 메뉴를 수정하시겠습니까?") == false) {
			return false;
		}

		$M.goNextPageAjax(this_page + "/" + $M.getValue("menu_seq"), frm , { method : 'POST'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGrid, result.list);		
					// fnNew();
					goSearch();
					goUpMenuSearch($M.getValue("up_menu_seq"));
				}
			}
		);
	}
   
	//갱신
	function fnNew() {
		var frm = document.main_form;
		$M.setValue(frm, "cmd", "C");
		var param = {
				pop_yn : "N",
				page_yn : "Y",
				menu_show_yn : "Y",
				use_yn : "Y",
				search_limit_yn : "N",
				menu_name : "",
				menu_seq : "",
				url : "",
				param : "",
				sort_no : "1",
				remark : "",
				up_menu_seq : "",
				pop_option : "",
				pop_option_apply_yn : "",
				pop_required_col_str : "",
				search_dt_type_cd_str : "",
				search_dt_type_cd : "",
				paper_gubun_cd : "",
				passwd_check_yn : "N",
				help_yn : "Y"
		};

		$M.setValue(param);
		$("#up_menu_seq").attr("class",""); 
		$("#up_menu_seq").attr("disabled",false);
		$("#up_menu_chk").prop("checked",false);
		$("#after_menu_push").prop("checked",true);
		$('input:checkbox.multi-check').prop('checked', false);
		$("#pop_option_apply").prop("checked", true);
		$("#selected").val("");
		$("#selected").html("- 선택 -");
		AUIGrid.clearSelection(auiGrid);
		AUIGrid.clearGridData(auiGridBtnLeft);
		AUIGrid.clearGridData(auiGridBtnRight);
		AUIGrid.clearGridData(auiGridAdd);
	}
   
	// 상세정보저장
	function goSaveMenuBtn () {
		var getData =AUIGrid.getEditedRowItems(auiGridBtnRight);
		if(getData.length==0){
			alert("변경된 데이터가 없습니다.")
		} else{
			fnSetValuesForHiddenDiv(getData, 'update');
		};
	}
   
	//->클릭시 hiddenDiv에 값 세팅
	function goAddMenuBtn() {
		var data = AUIGrid.getCheckedRowItems(auiGridBtnLeft);
		if(data.length != 0) {
			if (data.length > 20) {
				if (confirm("너무 많은 버튼을 선택했습니다. 계속 진행하시겠습니까?") == false) {
					return false;
				}
			}
			var tempArr = [];
			for (var i = 0; i < data.length; ++i) {
				tempArr.push(data[i].item);
			}
			fnSetValuesForHiddenDiv(tempArr, 'insert');
		} else {
			alert("선택된 항목이 없습니다.");
		};
	}
   
	function goRemoveMenuBtn() {
		var data = AUIGrid.getCheckedRowItems(auiGridBtnRight);
		if(data.length != 0) {
			var tempArr = [];
			for (var i = 0; i < data.length; ++i) {
				tempArr.push(data[i].item);
			}
			fnSetValuesForHiddenDiv(tempArr, 'delete');
		} else {
			alert("선택된 항목이 없습니다.");
		};
	}
   
	function goUpdateMenuBtn(data) {
		$M.goNextPageAjaxSave(this_page + "/"+data[0].menu_seq+"/btn/modify", document.data_form , { method : 'POST'},
			function(result) {
				if(result.success){
					goSearchMenuDetail();
				}
			}
		);
	}
   
	function goDeleteMenuBtn(data) {
		$M.setValue(data_form , "cmd", "D");
		$M.goNextPageAjax(this_page + "/"+data[0].menu_seq+"/btn/remove", document.data_form , { method : 'POST'},
			function(result) {
				if(result.success){
					goSearchMenuDetail();
				}
			}
		);
	}
   
	function goInsertMenuBtn(data) {
		$M.setValue(data_form , "cmd", "C");
		$M.goNextPageAjax(this_page + "/"+data[0].menu_seq+"/btn", document.data_form , { method : 'POST'},
			function(result) {
				if(result.success) {
					goSearchMenuDetail();
				}
			}
		);
	}
   
	//버튼정보 그리드 리로드
	function goSearchMenuDetail() {
		var param = {
			"menu_seq" : $M.getValue("menu_seq")
		};
		$M.goNextPageAjax(this_page + "/"+param.menu_seq+"/detail", $M.toGetParam(param),{ method : 'get'},
			function(result) {
				if(result.success){
					console.log("grid", result);
					AUIGrid.setGridData(auiGridBtnLeft, result.nonPageList);
					AUIGrid.setGridData(auiGridBtnRight, result.pageList);
					AUIGrid.setGridData(auiGridAdd, result.menuAddList);
					AUIGrid.setAllCheckedRows(auiGridBtnLeft,false);
					AUIGrid.setAllCheckedRows(auiGridBtnRight,false);
					$("#hiddenParamDiv").empty();
				}
			}
		);
	}
	
	//버튼 화살표 클릭했을때 data값이 삽입,삭제,변경 비교
	function fnSetValuesForHiddenDiv(data, method) {
		$("#hiddenParamDiv").empty();
		var paramDiv = document.getElementById('hiddenParamDiv');
		for(var key in data) {
			var subRows = data[key];
			subRows.menu_seq = $M.getValue("menu_seq");
			for(var subKey in subRows) {
				if(subKey != "id") {
					$M.setHiddenValue(paramDiv, subKey, subRows[subKey]);
				};
			};
		};
		if(method == 'insert') {
			goInsertMenuBtn(data);
		} else if(method == 'delete') {
			goDeleteMenuBtn(data);   
		} else if(method == 'update') {
			goUpdateMenuBtn(data);   
		};
	}
   
   //그리드셀 클릭시
   function goSearchDetail(param) {
		//param값 없으면 return
		if(param ==null) {
			return;
		}
		console.log(param);
		$M.goNextPageAjax(this_page + "/" + param.menu_seq, '', { method : 'get'},
			function(result) {
				if(result.success) {          
					//페이지 정보 TABLE FORM의 각각seletion에 데이터 값 입력
					var row = result.rowData;
					$M.setValue(row);

					if(row.pop_option_apply_yn == "Y") {
						$("#pop_option_apply").prop("checked", true);
					} else {
						$("#pop_option_apply").prop("checked", false);
					}

            		if(row.up_menu_seq == 0) {
						$("#up_menu_chk").prop("checked", true);
						$M.setValue("up_menu_seq", "");
                	} else {
						$("#up_menu_chk").prop("checked", false);
					};
					
					if(row.help_yn == 'Y'){
						document.getElementById('menu_help_btn').style.visibility = "visible";
						if(row.has_help_yn == 'Y'){
							document.getElementById('menu_help_btn').className = 'btn btn-md btn-rounded btn-darkgray';
						} else {
							document.getElementById('menu_help_btn').className = 'btn btn-md btn-rounded btn-lightgray';
						}
					} else {
						document.getElementById('menu_help_btn').style.visibility = "hidden";
					}
					
					fnUpMenuAction();
					goSearchMenuDetail();
					
					/* var searchDtDiv = $("#search_dt_type_cd_str_div"); 
					searchDtDiv.html("");
					console.log(row.search_dt_type_cd_str);
					for (var i = 0; i < row.search_dt_type_cd_str.length; ++i) {
						var cd = row.search_dt_type_cd_str[i];
						var nm = "";
						if (cd == "0D") {
							nm = "당일";
						} else if (cd == "1M") {
							nm = "1개월";
						} else if (cd == "3M") {
							nm = "3개월";
						} else if (cd == "6M") {
							nm = "6개월";
						} else if (cd == "1Y") {
							nm = "12개월";
						}
						if (row.search_dt_type_cd_str[i] != row.search_dt_type_cd) {
							searchDtDiv.append('<label><input type="radio" id="search_dt_type_cd" name="search_dt_type_cd" value="'+row.search_dt_type_cd_str[i]+'">'+nm+'</label>');
						} else {
							searchDtDiv.append('<label><input type="radio" checked id="search_dt_type_cd" name="search_dt_type_cd" value="'+row.search_dt_type_cd_str[i]+'">'+nm+'</label>');
						}
					} */
					
				}
			}
		);
	}
   
	//상위메뉴 onclick
	function fnUpMenuAction() {
		var upMenuChk = $("input:checkbox[id='up_menu_chk']").is(":checked");
		if(upMenuChk) {
			$("#up_menu_seq").attr("disabled",true);
			$("#up_menu_seq").attr("class","readonly"); 
		} else {
			$("#up_menu_seq").attr("disabled",false);
			$("#up_menu_seq").attr("class",""); 
		};
	}
   
	//메인그리드
	function createAUIGrid() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "menu_seq",
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			enableFilter :true,
			enableSorting : false
		};
		var columnLayout = [
			{ 
				headerText : "메뉴명",
				dataField : "menu_name",
				width : "90%", 
				style : "aui-left aui-link",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "순서",
				dataField : "sort_no",
				width : "10%",
				editable : false,
			}
		];
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);
		AUIGrid.bind(auiGrid, "cellClick", function(event){
			if (event.treeIcon == false) {
				var frm = document.main_form;
				$M.setValue(frm, "cmd", "U");
				var param = {
					"menu_seq" : event.item["menu_seq"]
				};
				goSearchDetail(param);
			}
		});
   }
      
	function createBtnToNonPageAUIGrid() {
		var gridPros = {
        	// rowIdField 설정
			rowIdField : "btn_seq",
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			//체크박스 출력 여부
			showRowCheckColumn : true,
			//전체선택 체크박스 표시 여부
			showRowAllCheckBox : true,
			enableFilter : true,
			independentAllCheckBox : true, // 필터됬을때 전체체크 방지
		};
		var columnLayout = [
        	{ 
				headerText : "미적용버튼", 
				dataField : "js_btn_name", 
				width : "100%", 
				style : "aui-left",
				editable : false,
				filter : {
					showIcon : true
				},
				labelFunction :  function( rowIndex, columnIndex, value, headerText, item ) {
					var viewValue = item['js_btn_name'] + "[" + item['js_name']  + "]";
					return viewValue;
				}
			},
			{
				dataField : "btn_seq",
				visible : false
			}
		];
		// 실제로 #grid_wrap 에 그리드 생성
		auiGridBtnLeft = AUIGrid.create("#auiGridBtnLeft", columnLayout, gridPros);
		AUIGrid.bind(auiGridBtnLeft, "rowAllChkClick", function( event ) {
			if(event.checked) {
				var uniqueValues = AUIGrid.getColumnDistinctValues(event.pid, "btn_seq");
				AUIGrid.setCheckedRowsByValue(event.pid, "btn_seq", uniqueValues);
			} else {
				AUIGrid.setCheckedRowsByValue(event.pid, "btn_seq", []);
			}
		});
		// 그리드 갱신
		AUIGrid.setGridData(auiGridBtnLeft, []);
	}
	
	function createBtnToPageAUIGrid() {
		var gridPros = {
        	// rowIdField 설정
			rowIdField : "btn_seq",
			//체크박스 출력 여부
			showRowCheckColumn : true,
			//전체선택 체크박스 표시 여부
			showRowAllCheckBox : true,
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			
			showStateColumn : true,
			//수정가능여부
			editable : true,
			enableFilter : true,
			independentAllCheckBox : true, // 필터됬을때 전체체크 방지
		};
		var columnLayout = [
			{ 
				headerText : "기본버튼명", 
				dataField : "js_btn_name", 
				width : "30%", 
				style : "aui-left",
				editable : false,
				filter : {
					showIcon : true
				},
				labelFunction :  function( rowIndex, columnIndex, value, headerText, item ) {
					var viewValue = item['js_btn_name'] + "[" + item['js_name']  + "]";
					return viewValue;
				}
			}, 
			{ 
				headerText : "수정버튼명", 
				dataField : "btn_name", 
				style : "aui-left",
				editable : true,
				labelFunction :  function( rowIndex, columnIndex, value, headerText, item ) {
					var viewValue = item['js_btn_name'];
					if (item['btn_name'] != ""){
						viewValue = item['btn_name'];
					}
					return viewValue;
				}
			}, 
			{ 
				headerText : "위치", 
				dataField : "btn_pos_cd", 
				width : "12%", 
				style : "aui-left",
				editRenderer : {
					showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
					type : "DropDownListRenderer",
					keyField : 'code_value',
					valueField : 'code_name',
					list : btnPosConvertArray,
					showEditorBtnOver : true,
					required : true                     
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<btnPosConvertArray.length; i++){
						if(value == btnPosConvertArray[i].code_value){
							return btnPosConvertArray[i].code_name;
						}
					}
					return value;
				}
			}, 
			{ 
				headerText : "순서", 
				dataField : "sort_no", 
				width : "8%", 
				style : "aui-center",
				editable : true
			},
			{ 
				headerText : "접근권한", 
				dataField : "access_gwm", 
				width : "11%", 
				style : "aui-left",
				editRenderer : {
					showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
					type : "DropDownListRenderer",
					keyField : 'code_value',
					valueField : 'code_name',
					list : btnAccessArray,
					showEditorBtnOver : true,
					required : true                     
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<btnAccessArray.length; i++){
						if(value == btnAccessArray[i].code_value){
							return btnAccessArray[i].code_name;
						}
					}
					return value;
				}
			},
			{ 
				headerText : "관리레벨 부서", 
				dataField : "mng_org_code_str", 
				width : "20%", 
				style : "aui-left",
				editRenderer : {
					showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
					type : "DropDownListRenderer",
					keyField : 'org_code',
					valueField : 'org_name',
					list : btnClassIdArray,
					showEditorBtnOver : true,
					required : true,
					multipleMode : true,
					delimiter : "^"
				},
				labelFunction : function(rowIndex, columnIndex, value) {
					var retStr = "";
					if (value != null && value != "") {
						var valueArr = value.split("^");
						var tempValueArr = [];
						for(var i=0; i<btnClassIdArray.length; i++){
							if(valueArr.indexOf(btnClassIdArray[i]["org_code"]) >= 0) {
								tempValueArr.push(btnClassIdArray[i]["org_name"]) ;
							}
						}
						if (tempValueArr.length > 1) {
							var remain = tempValueArr.length-1;
							return tempValueArr[0] + " 외 "+remain;
						} else {
							return tempValueArr.sort().join("^");							
						}
					} else {
						return "";
					}
				}
			},
			{ 
				headerText : "관리레벨 직급", 
				dataField : "mng_grade_str", 
				width : "15%", 
				style : "aui-left",
				editRenderer : {
					showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
					type : "DropDownListRenderer",
					keyField : 'code_value',
					valueField : 'code_name',
					list : btnGradeArray,
					showEditorBtnOver : true,
					required : true,
					multipleMode : true,
					delimiter : "^"
				},
				labelFunction : function(rowIndex, columnIndex, value) {
					var retStr = "";
					if (value != null && value != "") {
						var valueArr = value.split("^");
						var tempValueArr = [];
						for(var i=0; i<btnGradeArray.length; i++){
							if(valueArr.indexOf(btnGradeArray[i]["code_value"]) >= 0) {
								tempValueArr.push(btnGradeArray[i]["code_name"]) ;
							}
						}
						if (tempValueArr.length > 1) {
							var remain = tempValueArr.length-1;
							return tempValueArr[0] + " 외 "+remain;
						} else {
							return tempValueArr.sort().join("^");							
						} 
					} else {
						return "";
					}
				}
			},
			{ 
				headerText : "관리레벨 사용자", 
				dataField : "mng_mem_str", 
				width : "15%", 
				style : "aui-left",
				editRenderer : {
					showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
					type : "DropDownListRenderer",
					keyField : 'mem_no',
					valueField : 'mem_name',
					list : btnMemArray.sort(compare),
					showEditorBtnOver : true,
					required : true,
					multipleMode : true,
					delimiter : "^"
				},
				labelFunction : function(rowIndex, columnIndex, value) {
					var retStr = "";
					if (value != null && value != "") {
						var valueArr = value.split("^");
						var tempValueArr = [];
						for(var i=0; i<btnMemArray.length; i++){
							if(valueArr.indexOf(btnMemArray[i]["mem_no"]) >= 0) {
								tempValueArr.push(btnMemArray[i]["mem_name"]) ;
							}
						}
						if (tempValueArr.length > 1) {
							var remain = tempValueArr.length-1;
							return tempValueArr[0] + " 외 "+remain;
						} else {
							return tempValueArr.sort(compare).join("^");							
						}
					} else {
						return "";
					}
				}
			},
			{
				dataField : "btn_seq",
				visible: false
			}
		];
		 // 실제로 #grid_wrap 에 그리드 생성
		auiGridBtnRight = AUIGrid.create("#auiGridBtnRight", columnLayout, gridPros);
		AUIGrid.bind(auiGridBtnRight, "rowAllChkClick", function( event ) {
			if(event.checked) {
				var uniqueValues = AUIGrid.getColumnDistinctValues(event.pid, "btn_seq");
				AUIGrid.setCheckedRowsByValue(event.pid, "btn_seq", uniqueValues);
			} else {
				AUIGrid.setCheckedRowsByValue(event.pid, "btn_seq", []);
			}
		});
		// 그리드 갱신
		AUIGrid.setGridData(auiGridBtnRight, []);
	}

	// 추가설정 그리드 생성
	function createAddAUIGrid() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "menu_add_cd",
			// rowNumber
			showRowNumColumn: true,
			enableFilter : true,
			independentAllCheckBox : true, // 필터됬을때 전체체크 방지
			showStateColumn: true,
		};
		var columnLayout = [

			{
				headerText : "",
				dataField : "use_yn",
				width : "4%",
				style : "aui-center",
				headerRenderer : { // 헤더 렌더러
					type : "CheckBoxHeaderRenderer",
					dependentMode : true
				},
				renderer : {
					type : "CheckBoxEditRenderer",
					checkValue : "Y", // true, false 인 경우가 기본
					unCheckValue : "N",
					editable : true
				}
			},
			{
				dataField : "cmd",
				visible : false,
			},
			{
				dataField : "menu_add_cd",
				visible : false
			},
			{
				headerText : "추가설정",
				dataField : "menu_add_name",
				style : "aui-left",
				editable : false,
				filter : {
					showIcon : true
				}
			}
		];
		// 실제로 #grid_wrap 에 그리드 생성
		auiGridAdd = AUIGrid.create("#auiGridAdd", columnLayout, gridPros);

		// 그리드 갱신
		AUIGrid.setGridData(auiGridAdd, []);
	}

	// 추가설정 저장
	function goSaveDetail() {
		var changeGridData = AUIGrid.getEditedRowItems(auiGridAdd); // 변경내역
		if(changeGridData.length==0){
			alert("변경된 데이터가 없습니다.");
			return false;
		}

		var frm = $M.toValueForm(document.main_form);
		var gridFrm = fnChangeGridDataToForm(auiGridAdd);
		$M.copyForm(gridFrm, frm);
		$M.goNextPageAjaxSave(this_page + "/"+$M.getValue('menu_seq')+"/add", gridFrm , { method : 'POST'},
			function(result) {
				if(result.success) {
					goSearchMenuDetail();
				}
			}
		);
	}
	
	function compare( a, b ) {
		if ( a.mem_name < b.mem_name ) {
			return -1;
		}
		if ( a.mem_name > b.mem_name ) {
			return 1;
		}
		return 0;
	}
	
	//각 메뉴 별 도움말 페이지 이동
	function goMenuHelpPopup() {
		var param = {
			"menu_seq" : $M.getValue('menu_seq')
		};
		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=720, height=850, left=0, top=0";
		$M.goNextPage('/comp/comp0710', $M.toGetParam(param) , {popupStatus : poppupOption});
	}
	
	function show(elementId) {
		document.getElementById(elementId).style.display="block";
	}
	function hide(elementId) {
		document.getElementById(elementId).style.display="none";
	}
	
	</script>
</head>
<body>
<!-- script -->
<!-- /script -->
<!-- contents 전체 영역 -->
<form id="main_form" name="main_form">
	<input type="hidden" id="cmd" name="cmd" value="C">
	<input type="hidden" id="pop_option_apply_yn" name="pop_option_apply_yn">
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
								<col width="50px">
								<col width="250px">
								<col width="50px">
								<col width="250px">
								<col width="75px">
								<col width="80px">
								<col width="55px">
								<col width="80px">
								<col width="80px">
								<col width="80px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>							
									<th>메뉴명</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" id="s_menu_name" name="s_menu_name" class="form-control">
										</div>
									</td>
									<th>URL</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" id="s_url" name="s_url" class="form-control">
										</div>
									</td>
									<th>팝업여부</th>
									<td>
										<select id="s_pop_yn" name="s_pop_yn" class="form-control">
											<option value="">- 전체 -</option>
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>
									<th>사용여부</th>
									<td>
										<select id="s_use_yn" name="s_use_yn" class="form-control">
											<option value="">- 전체 -</option>
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>
									<th>도움말여부</th>
									<td>
										<select id="s_help_yn" name="s_help_yn" class="form-control">
											<option value="">- 전체 -</option>
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>
									<td class="">
										<button type="button" onclick="javascript:goSearch('init');" class="btn btn-important" style="width: 50px;">조회</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<div class="row">
						<!-- 메뉴목록 -->
						<div class="col-3">
							<div class="title-wrap mt10">
								<h4>메뉴목록</h4>
								<div class="btn-group">
									<div class="right">
										<button type="button" onclick=AUIGrid.expandAll(auiGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
										<button type="button" onclick=AUIGrid.collapseAll(auiGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>
									</div>
								</div>						
							</div>
							<div id="auiGrid" style="margin-top: 5px;height: 635px;"></div>
						</div>
						<!-- /메뉴목록 -->						
						<div class="col-9">
							<!-- 메뉴정보 -->
							<div class="row">
								<div class="col-12">
									<div class="title-wrap mt10">
										<h4>메뉴정보</h4>
										<div id="help_btn">
											<p><button type="button" class="btn btn-md btn-rounded btn-lightgray" id="menu_help_btn" onclick="javascript:goMenuHelpPopup()" style="visibility: hidden;"><i class="material-iconshelp_outline text-white mr3"></i> 도움말 </button></p>
										</div>
									</div>									
									<!-- 폼테이블 -->	
									<div>
										<table class="table-border">
											<colgroup>
												<col width="85px"> <!-- 100에서 75로수정-->
												<col width="">
												<col width="85px">
												<col width="">
												<col width="75px"> <!-- 100에서 75로수정-->
												<col width="">
											</colgroup>
											<tbody>
												<tr>
													<th class="text-right essential-item">메뉴명</th>
													<td>
														<input type="text" class="form-control essential-bg width230px" id="menu_name" name="menu_name" alt="메뉴명">
													</td>
													<th class="text-right essential-item">URL</th>
													<td>
														<input type="text" id="url" name="url" class="form-control essential-bg width230px" alt="URL" placeholder="/cust/cust0102">
													</td>
													<th class="text-right essential-item">사용여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="Y" id="use_yn_y">
															<label class="form-check-label" for="use_yn_y">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="N" id="use_yn_n">
															<label class="form-check-label" for="use_yn_n">N</label>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">메뉴여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="page_yn" value="Y" id="page_yn_y">
															<label class="form-check-label" for="page_yn_y">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="page_yn" value="N" id="page_yn_n">
															<label class="form-check-label" for="page_yn_n">N</label>
														</div>
														<input type="text" id="menu_seq" name="menu_seq" disabled="disabled" style="position: absolute;">
													</td>
													<th class="text-right essential-item">상위메뉴</th>
													<td colspan="3">
														<div class="form-row inline-pd">
															<div class="col-auto">
																<select id="up_menu_seq" name="up_menu_seq" class="form-control essential-bg width280px" style="height:24px; max-width: 280px;">
																	<option value="">- 선택 -</option>
																</select>
															</div>
															<div class="col-auto">
																<div class="form-check form-check-inline" style="margin-right: 0; margin-left: 5px" onclick="fnUpMenuAction();">
																	<input class="form-check-input" id="up_menu_chk" name="up_menu_chk" type="checkbox" style="margin-top: 6px; margin-right: 3px;">
																	<label class="form-check-label" for="up_menu_chk">대메뉴</label>
																</div>
															</div>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">순서</th>
													<td>
														<div class="form-row inline-pd">
															<div class="col-auto">
																<input type="text" class="form-control essential-bg width40px" id="sort_no" name="sort_no" format="num" alt="순서" style="padding : 5px;" min="1" datatype="int" required="required">
															</div>
															<div class="col-auto">
																<div class="form-check form-check-inline" style="margin-right: 0; margin-left: 5px">
																	<input class="form-check-input" id="after_menu_push" name="after_menu_push" type="checkbox" style="margin-top: 6px; margin-right: 3px;">
																	<label class="form-check-label" for="after_menu_push">후순위 메뉴밀기</label>
																</div>
															</div>
														</div>
													</td>
													<th class="text-right essential-item">조회제한<br>여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" id="search_limit_yn_y" name="search_limit_yn" value="Y">
															<label class="form-check-label" for="search_limit_yn_y">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" id="search_limit_yn_n" name="search_limit_yn" value="N">
															<label class="form-check-label" for="search_limit_yn_n">N</label>
														</div>
													</td>
													<th class="text-right essential-item">레프트메뉴 노출여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" id="menu_show_yn_y" name="menu_show_yn" value="Y">
															<label class="form-check-label" for="menu_show_yn_y">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" id="menu_show_yn_n" name="menu_show_yn" value="N">
															<label class="form-check-label" for="menu_show_yn_n">N</label>
														</div>
													</td>
												</tr>
												
												<tr>
													<th class="text-right essential-item">팝업여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="pop_yn" value="Y" id="pop_yn_y">
															<label class="form-check-label" for="pop_yn_y">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="pop_yn" value="N" id="pop_yn_n">
															<label class="form-check-label" for="pop_yn_n">N</label>
														</div>
													</td>
													<th class="text-right essential-item">팝업필수키</th>
													<td>
														<input type="text" class="form-control essential-bg" id="pop_required_col_str" name="pop_required_col_str" placeholder="여러항목은 ^로 구분">
													</td>
													<th class="text-right">쪽지구분<br>코드</th>
													<td>
														<select class="form-control" id="paper_gubun_cd" name="paper_gubun_cd">
															<option value="">- 선택 -</option>
															<c:forEach items="${codeMap['PAPER_GUBUN']}" var="item" varStatus="status">
																<c:if test="${item.code ne '---'}">
																	<option value="${item.code_value}" >${item.code_name}</option>
																</c:if>
															</c:forEach>
														</select>
													</td>
												</tr>
												<tr>
													<th class="text-right">팝업옵션</th>
													<td colspan="5">
														<div class="form-row inline-pd">
															<div class="col-10">
																<input type="text" class="form-control" id="pop_option" name="pop_option" style="padding : 5px;" maxlength="1500">
															</div>
															<div class="col-auto">
																<div class="form-check form-check-inline" style="margin-right: 0; margin-left: 5px">
																	<input class="form-check-input" id="pop_option_apply" name="pop_option_apply" type="checkbox" style="margin-top: 6px; margin-right: 3px;">
																	<label class="form-check-label" for="pop_option_apply">적용여부</label>
																</div>
															</div>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-right">비고</th>
													<td>
														<input id="remark" name="remark" type="text" class="form-control">
													</td>
													<th class="text-right essential-item">도움말여부<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show('help_operation')" onmouseout="javascript:hide('help_operation')"></i></th>
													<!-- 마우스 오버시 레이어팝업 -->
														<div class="con-info" id="help_operation" style="max-height: 500px; top: 70%; left: 41.5%; width: 230px; display: none;">
															<ul class="">
																<ol style="color: #666;">&nbsp;선택한 메뉴에서의 도움말 기능 사용 여부</ol>
															</ul>
														</div>
													<!-- /마우스 오버시 레이어팝업 -->	
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" id="help_yn_y" name="help_yn" value="Y">
															<label class="form-check-label" for="help_yn_y">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" id="help_yn_n" name="help_yn" value="N">
															<label class="form-check-label" for="help_yn_n">N</label>
														</div>
													</td>
													<th class="text-left">비밀번호<br>확인여부<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show('pw_operation')" onmouseout="javascript:hide('pw_operation')"></i></th>
													<!-- 마우스 오버시 레이어팝업 -->
														<div class="con-info" id="pw_operation" style="max-height: 500px; top: 70%; left: 74%; width: 250px; display: none;">
															<ul class="">
																<ol style="color: #666;">&nbsp;선택한 메뉴 페이지 진입 시 비밀번호 확인 여부</ol>
															</ul>
														</div>
													<!-- /마우스 오버시 레이어팝업 -->	
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="passwd_check_yn" value="Y" id="passwd_check_yn_y">
															<label class="form-check-label" for="passwd_check_yn_y">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="passwd_check_yn" value="N" id="passwd_check_yn_n">
															<label class="form-check-label" for="passwd_check_yn_n">N</label>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-right">기본날짜조회</th>
													<td colspan="5">
														<div id="search_dt_type_cd_str_div">
														
														</div>
														<c:forEach items="${codeMap['SEARCH_DT_TYPE']}" var="item" varStatus="status">
															<label>
																<input type="checkbox" name="search_dt_type_cd_str" value="${item.code_value}">${item.code_name }
															</label>
															<input type="radio" name="search_dt_type_cd" value="${item.code_value}" ${rowData.search_dt_type_cd eq item.code_value ? 'checked' : ''}>
															<c:if test="${status.last ne true}">
																	<div style="padding: 5px; display: inline-block;">|</div>
															</c:if>
														</c:forEach>
														<br>- 체크 : 날짜 선택 표시, - 라디오 : 선택된 값이 없을때 보여줄 기본값
													</td>
												</tr>
											</tbody>
										</table>
									</div>
									<!-- /폼테이블 -->
									<!-- 그리드 서머리, 컨트롤 영역 -->
									<div class="btn-group mt5">					
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BASE_R"/></jsp:include>
										</div>
									</div>
									<!-- /그리드 서머리, 컨트롤 영역 -->
								</div>
							</div>
							<!-- /메뉴정보 -->
							<!-- 버튼정보 -->
							<div class="row">
								<div class="col-12">
									<div class="title-wrap">
										<h4>버튼정보</h4>					
									</div>
									<div style="margin-top: 5px; height: 180px; display: flex; padding-right: 0" class="col-12">
										<div style="display: inline-block; width: 30%">
											<div id="auiGridBtnLeft" style="height: 100%;"></div>
										</div>
										<div style="text-align: center; border: 0; vertical-align: middle; float: left; display: inline-block; width: 4%">
											<div style="margin-bottom: 5px; margin-top: 55px;">
												<button type="button" class="btn mint" style="width: 30px;"
													onclick="goAddMenuBtn();"><i class="large material-icons">navigate_next</i></button>
											</div>
											<div>
												<button type="button" class="btn mint" style="width: 30px;"
													onclick="goRemoveMenuBtn();"><i class="large material-icons">navigate_before</i></button>
											</div>
										</div>
										<!-- 그리드 서머리, 컨트롤 영역 -->
										<div style="display: inline-block; width: 70%">
											<div id="auiGridBtnRight" style="height: 100%;"></div>
										</div>
										<!-- 그리드 서머리, 컨트롤 영역 -->
									</div>
								</div>
							</div>
							<div class="btn-group mt5">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
								</div>
							</div>
							<!-- /버튼정보 -->
							<!-- 추가설정 -->
							<div class="row">
								<div class="col-12">
									<div class="title-wrap">
										<h4>추가설정</h4>
									</div>
									<div style="margin-top: 5px; height: 180px; display: flex; padding-right: 0" class="col-12">
										<div style="display: inline-block; width: 100%">
											<div id="auiGridAdd" style="height: 100%;"></div>
										</div>
									</div>
								</div>
							</div>
							<!-- /추가설정 -->
						</div>
					</div>
					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
		</div>
<!-- /contents 전체 영역 -->
</form>
<div style="display: none;">
	<form id="data_form" name="data_form">
		<div id="hiddenParamDiv"></div>
	</form>
</div>	
</body>
</html>