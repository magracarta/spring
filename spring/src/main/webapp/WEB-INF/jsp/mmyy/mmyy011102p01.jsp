<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 구매품의서 > null > 구매품의서 상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileMaxCount = 5;
	
	var orgListJson = JSON.parse('${orgList}');     // 사용부서
	var assetTypeJson = JSON.parse('${codeMapJsonObj['ASSET_TYPE']}');			//자산물품구분
	var btnMemArrayTemp = ${memListJson}
	var btnMemArray = [];
	
	var orgList = [];
	
	for (var i in orgListJson) {
		orgList.push(orgListJson[i].org_code);
	}
	
	var rowNum = '${rowNum}' + 1;
	
	var regMemNo = '${info.mem_no}';
	var memNo = '${SecureUser.mem_no}';
	
	$(document).ready(function() {
		// 사용자 멀티콤보그리드
		btnMemArrayTemp.reduce(function(res, value) {
		  if (!res[value.mem_no]) {
			  if (orgList.includes(value.org_code)) {
			    res[value.mem_no] = { 
			    	mem_no: value.mem_no,
			    	mem_name : value.mem_name+"("+value.org_name+")",
			    	org_code : value.org_code
			    };
			    btnMemArray.push(res[value.mem_no]);
			  }
		  }
		  return res;
		}, {});
		
		// 그리드 생성
		createAUIGrid();

		if ($M.getValue("doc_buy_cd") == "01") {
			$("#normal_form").addClass("dpn");
			$("#auiGrid").removeClass("dpn");
			$("#buy_form").removeClass("dpn");
			
			AUIGrid.setGridData(auiGrid, ${dtlListJson});
		} else {
			$("#auiGrid").addClass("dpn");
			$("#buy_form").addClass("dpn");
			$("#normal_form").removeClass("dpn");
			
		}
		
		// 파일 세팅
		<c:forEach var="list" items="${doc_file}">setFileInfo('${list.file_seq}', '${list.file_name}');</c:forEach>
        
	    // 결재상태에 따라 수정가능 제어
	    if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
	          || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y')
	    )) {
	       $("#main_form :input").prop("disabled", true);
	       $("#main_form :checkbox").prop("disabled", false);
	       $("#main_form :button[onclick='javascript:fnPrint();']").prop("disabled", false);
	       $("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
	       $("#main_form :button[onclick='javascript:goApproval();']").prop("disabled", false);
	       $("#main_form :button[onclick='javascript:goApprCancel();']").prop("disabled", false);
	    }
	    
	    if ($M.getValue("appr_proc_status_cd") == "05") {
			$("#_fnPrint").show();
		} else {
			$("#_fnPrint").hide();
		}
	    
	});
	
	function compare( a, b ) {
		if ( a.mem_name < b.mem_name ) {
			return -1;
		}
		if ( a.mem_name > b.mem_name ) {
			return 1;
		}
		return 0;
	}
	
	// 파일 업로드
	function goUploadImg(rowIndex) {
		var param = {
			upload_type: "DOC",
			file_type: "both",
		};

		$M.setValue("buy_row_index", rowIndex);
		openFileUploadPanel("fnSetBuyImage", $M.toGetParam(param));
	}
	
	// 구매 - 첨부파일 이미지 Setting
	function fnSetBuyImage(result) {
		console.log("result : ", result);
		if (result !== null && result.file_seq !== null) {
			AUIGrid.updateRow(auiGrid, {buy_file_seq_1 : result.file_seq}, $M.getValue("buy_row_index"));
			AUIGrid.updateRow(auiGrid, {origin_file_name : result.file_name}, $M.getValue("buy_row_index"));
		}
	}
	
	function fnPreview(fileSeq) {
		var params = {
			file_seq : fileSeq
		};
		var popupOption = "";
		$M.goNextPage('/comp/comp0709', $M.toGetParam(params), {popupStatus : popupOption});
	}
	
	// 일반 : 파일첨부
	function fnAddFile(){
		if($("input[class='doc_file_list']").size() >= fileMaxCount) {
			alert("파일은 " + fileMaxCount + "개만 첨부하실 수 있습니다.");
			return false;
		}
		
        var param = {
            upload_type: 'DOC',
            file_type: 'both',
        };
        
		openFileUploadPanel('fnPrintFileInfo', $M.toGetParam(param));
	}
	
	function fnPrintFileInfo(result) {
		setFileInfo(result.file_seq, result.file_name)
	}
	
	//첨부파일 세팅
	function setFileInfo(fileSeq, fileName) {
		var str = ''; 
		str += '<div class="table-attfile-item doc_file_' + fileIndex + '" style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue;">' + fileName + '</a>&nbsp;';
		str += '<input type="hidden" class="doc_file_list" name="doc_file_seq_'+ fileIndex + '" value="' + fileSeq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '</div>';
		$('.doc_file_div').append(str);
		fileIndex++;
	}
	
	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) { 
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".doc_file_" + fileIndex).remove();
			$("#doc_file_seq_" + fileIndex).remove();
		} else {
			return false;
		}
	}
	
	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			enableFilter :true,
			editable : true,
			showFooter : true,
			footerPosition : "top",
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				dataField: "row_num",
				visible : false
			},
			{
				dataField: "seq_no",
				visible : false
			},
			{
				dataField: "buy_file_seq_1",
				visible : false
			},
			{
				dataField: "asset_payment_no",
				visible : false
			},
			{
				headerText: "사용부서",
				dataField: "use_org_code",
				width : "80",
				style : "aui-center",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : orgListJson,
					keyField : "org_code", 
					valueField : "org_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<orgListJson.length; i++){
						if(value == orgListJson[i].org_code){
							return orgListJson[i].org_name;
						}
					}
					return value;
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "사용자",
				dataField: "use_mem_no_str",
				width : "200",
				style : "aui-center",
				editable : true,
				editRenderer : {
					showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
					type : "DropDownListRenderer",
					keyField : 'mem_no',
					valueField : 'mem_name',
// 					list : btnMemArray.sort(compare),
					listFunction : function(rowIndex, columnIndex, value, item, dataField){
						var useMemList = btnMemArray.sort(compare);
						var orgCode = value.use_org_code;
						
						if (orgCode != "") {
							useMemList = useMemList.filter(function(value,index,arr){
								return arr[index].org_code == orgCode;
							});
						} 
						
						return useMemList;
					},
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
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "구매사유",
				dataField: "buy_text",
				width : "160",
				style : "aui-left",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "구매물품",
				dataField: "asset_type_cd",
				width : "80",
				style : "aui-center",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : assetTypeJson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<assetTypeJson.length; i++){
						if(value == assetTypeJson[i].code_value){
							return assetTypeJson[i].code_name;
						}
					}
					return value;
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "구매처",
				dataField: "buy_office",
				width : "100",
				style : "aui-left",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "제품명",
				dataField: "prod_name",
				width : "120",
				style : "aui-left",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "수량",
				dataField: "buy_qty",
				width : "55",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-center",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true,
				      min : 1,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "구매가격",
				dataField: "unit_amt",
				width : "100",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true,
				      min : 1,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "총금액",
				dataField: "buy_amt",
				width : "100",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
				expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
					// 수량 * 단가 계산
					return ( item.buy_qty * item.unit_amt ); 
				}
			},
			{
				headerText: "제품코드",
				dataField: "prod_spec",
				width : "150",
				style : "aui-left",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "자산지금품관리",
				dataField: "asset_yn",
				width : "100",
				style : "aui-center",
				editable : true,
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "첨부파일",
				dataField: "origin_file_name",
				width : "80",
				style : "aui-center",
				editable : false,
				renderer : { // HTML 템플릿 렌더러 사용
					type : "TemplateRenderer"
				},
				labelFunction : function( rowIndex, columnIndex, value, dataField, item) {
					if(item.buy_file_seq_1 == 0) {
						return '<button type="button" class="btn btn-default" style="width: 90%" onclick="javascript:goUploadImg(' + rowIndex + ');">이미지등록</button>';
					} else {
						// 21.08.31 (SR:12427) 파일다운로드 방식으로 변경 - 황빛찬
// 						var template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:fnPreview(' + item.buy_file_seq_1 + ');">' + value + '</span>' + '</div>';
						var template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:fileDownload(' + item.buy_file_seq_1 + ');">' + value + '</span>' + '</div>';
						return template;
					}
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "비고",
				dataField: "remark",
				width : "180",
				style : "aui-left",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
					       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "60",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
						} else {
							AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
						}
					}
				},
				labelFunction : function(rowIndex, columnIndex, value,
										 headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : true
			}
		];
		
		// 푸터레이아웃
		var footerColumnLayout = [
			{
				labelText : "합계",
				positionField : "prod_name",
				style : "aui-center aui-footer",
			}, 
			{
				dataField : "buy_qty",
				positionField : "buy_qty",
				operation : "SUM",
				style : "aui-center aui-footer",
			},
			{
				dataField : "unit_amt",
				positionField : "unit_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
			{
				dataField : "buy_amt",
				positionField : "buy_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setFooter(auiGrid, footerColumnLayout);
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();
		
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
			if ('${page.fnc.F02011_001}' != 'Y' && '${page.fnc.F02011_002}' != 'Y') {
				if (event.dataField == "use_org_code") {
					return false;
				}
			}
			
			if ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02011_002}' == 'Y') {
				if (event.dataField) {
					return true;
				}
			}
			
			if (($M.getValue("appr_proc_status_cd") != 01 || regMemNo != memNo)) {
				if (event.dataField) {
					return false;
				}
			}
		});
		
		AUIGrid.bind(auiGrid, "cellEditEnd", function( event ) {		
			if (event.dataField == "use_mem_no_str" || event.dataField == "asset_yn") {
				var item = event.item.use_mem_no_str;
				var arr = item.split('^');
				
				if (event.item.asset_yn == "Y") {
					AUIGrid.updateRow(auiGrid, { "buy_qty" : arr.length}, event.rowIndex);
				}
			}
			
			if (event.dataField == "buy_qty") {
				if (event.item.asset_yn == "Y") {
					var item = event.item.use_mem_no_str;
					var arr = item.split('^');
					
					// 사용자가 선택되었다면 수량은 사용자 명수와 동일해야함.
					if (arr[0] != "") {
						if (arr.length != event.value) {
							setTimeout(function() {
								   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "사용자 명수와 수량은 같아야 합니다.");
							}, 1);
							
							if (event.oldValue == null) {
								return 1;
							} else {
								AUIGrid.updateRow(auiGrid, { "buy_qty" : event.oldValue}, event.rowIndex);
							}
						}
					}
				}
			}
		});
	}	
	
	// 행추가
	function fnAdd() {
		// 관리부, 최승희대리는 부서 선택 가능 / 나머지 직원은 해당 부서 세팅.
		var flag = false;
		if ('${page.fnc.F02011_002}' == 'Y' || '${page.fnc.F02011_001}' == 'Y') {
			flag = true;
		}
		
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
    		item.row_num = rowNum, 
    		item.seq_no = "", 
    		item.asset_payment_no = "",
//     		item.use_org_code = "",
    		item.use_org_code = flag == true ? "" : '${inputParam.login_org_code}',
    		item.use_mem_no_str = "",
    		item.buy_text = "",
    		item.asset_type_cd = "",
    		item.buy_office = "",
    		item.prod_name = "",
    		item.buy_qty = "",
    		item.unit_amt = "",
    		item.buy_amt = "",
    		item.prod_spec = "",
    		item.asset_yn = "N",
    		item.remark = "",
    		item.origin_file_name = "",
    		item.buy_file_seq_1 = 0;
    		
    		rowNum++;
    		AUIGrid.addRow(auiGrid, item, 'last');
		}	
	}
	
	// 그리드 벨리데이션
	function fnCheckGridEmpty() {
		var gridData = AUIGrid.getGridData(auiGrid);
		for (var i = 0; i < gridData.length; i++) {
			if (gridData[i].use_org_code == "" && gridData[i].use_mem_no_str == "") {
 			    AUIGrid.showToastMessage(auiGrid, i, 5, "사용부서, 사용자중 하나는 필수 입력입니다.");
 			    return false;
			}
			
			if (gridData[i].asset_type_cd == "") {
			    AUIGrid.showToastMessage(auiGrid, i, 7, "구매물품은 필수 입력입니다.");
			    return false;
			}

			if (gridData[i].buy_office == "") {
 			    AUIGrid.showToastMessage(auiGrid, i, 8, "구매처는 필수 입력입니다.");
 			    return false;
			}

            if (gridData[i].asset_yn == "Y" && gridData[i].prod_name == "") {
                AUIGrid.showToastMessage(auiGrid, i, 9, "자산지급품 관리일때 제품명은 필수 입력입니다.");
                return false;
            }

			if (gridData[i].buy_qty == 0) {
			    AUIGrid.showToastMessage(auiGrid, i, 10, "수량은 1개 이상이어야 합니다.");
			    return false;
			}

			if (gridData[i].unit_amt == 0) {
				AUIGrid.showToastMessage(auiGrid, i, 11, "금액은 필수 입력입니다.");
				return false;
			}
		}
		
// 		return AUIGrid.validateGridData(auiGrid, ["asset_type_cd", "buy_office", "buy_qty", "unit_amt"], "필수 항목은 반드시 값을 입력해야합니다.");
		return true;
	}
	
	function fnClose() {
		window.close();
	}
	
	// 결재취소
	function goApprCancel() {
		var param = {
			appr_job_seq: "${apprBean.appr_job_seq}",
			seq_no: "${apprBean.seq_no}",
			appr_cancel_yn: "Y"
		};
		openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
	}
	
	function goApprovalResultCancel(result) {
		$M.goNextPageAjax('/session/check', '', {method: 'GET'},
			function (result) {
				if (result.success) {
					alert("결재취소가 완료됐습니다.");
					location.reload();
				}
			}
		);
	}
	
	// 결재처리
	function goApproval() {
		var param = {
			appr_job_seq: "${apprBean.appr_job_seq}",
			seq_no: "${apprBean.seq_no}"
		};
		$M.setValue("save_mode", "approval"); // 승인
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}
	
	// 결재처리 결과
	function goApprovalResult(result) {
		// 반려이면 페이지 리로딩
		if (result.appr_status_cd == '03') {
			$M.goNextPageAjax('/session/check', '', {method: 'GET'},
				function (result) {
					if (result.success) {
						alert("반려가 완료되었습니다.");
						location.reload();
					}
				}
			);
		} else if (result.appr_status_cd == '05') {
            $M.goNextPageAjax('/session/check', '', {method: 'GET'},
                function (result) {
                    if (result.success) {
                        alert("종결처리가 완료되었습니다.");
                        location.reload();
                    }
                }
            );
        } else {
			$M.goNextPageAjax('/session/check', '', {method: 'GET'},
				function (result) {
					if (result.success) {
						alert("처리가 완료되었습니다.");
						location.reload();
					}
				}
			);
		}
	}
	
	// 결재요청
	function goRequestApproval() {
		goModify('requestAppr');
	}

    // 종결처리
    function goApprovalEnd() {
        var param = {
            appr_job_seq : "${apprBean.appr_job_seq}",
            seq_no : "${apprBean.seq_no}",
            appr_end_only : 'Y',
        };
        openApprPanel("goApprovalResult", $M.toGetParam(param));
    }
	
	// 수정
	function goModify(isRequestAppr) {
		// validationcheck
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		var gridData = AUIGrid.getGridData(auiGrid);
		for (var i = 0; i < gridData.length; i++) {
			if (gridData[i].use_org_code == "" && gridData[i].use_mem_no_str == "") {
 			    AUIGrid.showToastMessage(auiGrid, i, 5, "사용부서, 사용자중 하나는 필수 입력입니다.");
 			    return false;
			}
			
			if (gridData[i].asset_type_cd == "") {
			    AUIGrid.showToastMessage(auiGrid, i, 7, "구매물품은 필수 입력입니다.");
			    return false;
			}

			if (gridData[i].buy_office == "") {
 			    AUIGrid.showToastMessage(auiGrid, i, 8, "구매처는 필수 입력입니다.");
 			    return false;
			}

            if (gridData[i].asset_yn == "Y" && gridData[i].prod_name == "") {
                AUIGrid.showToastMessage(auiGrid, i, 9, "자산지급품 관리일때 제품명은 필수 입력입니다.");
                return false;
            }

			if (gridData[i].buy_qty == 0) {
			    AUIGrid.showToastMessage(auiGrid, i, 10, "수량은 1개 이상이어야 합니다.");
			    return false;
			}

			if (gridData[i].unit_amt == 0) {
				AUIGrid.showToastMessage(auiGrid, i, 11, "금액은 필수 입력입니다.");
				return false;
			}
		}

		var idx = 1;
		$("input[class='doc_file_list']").each(function() {
			var str = 'doc_file_seq_' + idx;
			$M.setValue(str, $(this).val());
			idx++;
		});
		
		for(; idx <= fileMaxCount; idx++) {
			$M.setValue('doc_file_seq_' + idx, 0);
		}

		var msg = "";
		if (isRequestAppr != undefined) {
			// 결재요청 Setting
			$M.setValue("save_mode", "appr");
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "modify");
			msg = "수정 하시겠습니까?";
		}
		
		var frm = $M.toValueForm(document.main_form);
		var gridFrm = fnChangeGridDataToForm(auiGrid);
		$M.copyForm(gridFrm, frm);
		
		var gridData = AUIGrid.getGridData(auiGrid);
		console.log(gridData);

		console.log(gridFrm);

		$M.goNextPageAjaxMsg(msg, this_page + "/modify", gridFrm, {method: "POST"},
			function (result) {
				if (result.success) {
					alert("처리가 완료되었습니다.");
					window.location.reload();
	    			if(opener != null && opener.goSearch) {
		    			opener.goSearch();
	    			}
				}
			}
		);
	}
	
	// 삭제
	function goRemove() {
		var frm = $M.toValueForm(document.main_form);
		
// 		var concatCols = [];
// 		var concatList = [];
// 		var gridIds = [auiGrid];
// 		for (var i = 0; i < gridIds.length; ++i) {
// 			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
// 			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
// 		}
		
// 		var gridFrm = fnGridDataToForm(concatCols, concatList);
// 		$M.copyForm(gridFrm, frm);
		
		console.log("gridFrm : ", frm);

		$M.goNextPageAjaxRemove(this_page + "/remove", frm, {method: "POST"},
			function (result) {
				if (result.success) {
					alert("처리가 완료되었습니다.");
	    			fnClose();
	    			if (opener != null && opener.goSearch) {
	    				opener.goSearch();
	    			}
				}
			}
		);
	}	
	
	// 인쇄
	function fnPrint() {

		var apprListJson = JSON.parse(`${apprMemoListJson}`);
		var apprMemoListJson = [];
		for(var i=0; i<apprListJson.length; i++){
			apprMemoListJson.push(apprListJson[i]);
			if(apprListJson[i].appr_status_cd == '03'){
				apprMemoListJson = [];
			}
		}
		
		apprMemoListJson[0].grade_name = "작성자";
		
		
		
		var gridData = AUIGrid.getGridData(auiGrid);
		for(var i=0; i<gridData.length; i++){
			for (var j=0; j<assetTypeJson.length; j++) {
				if(gridData[i].asset_type_cd == assetTypeJson[j].code_value){
					gridData[i].asset_type_name = assetTypeJson[j].code_name;
					break;
				}				
			}
		}
		for (var j in gridData) {
			// 사용자 가공
			var value = gridData[j].use_mem_no_str;
			if (value != null && value != "") {
				var valueArr = value.split("^");
				var tempValueArr = [];
				for(var i=0; i<btnMemArray.length; i++){
					if(valueArr.indexOf(btnMemArray[i]["mem_no"]) >= 0) {
						tempValueArr.push(btnMemArray[i]["mem_name"]) ;
					}
				}
				tempValueArr[0] = tempValueArr[0].replace("(", "\n(");
				if (tempValueArr.length > 1) {
					var remain = tempValueArr.length-1;
					gridData[j].use_mem_no_str = tempValueArr[0] + "\n 외 "+remain;
				} else {
					gridData[j].use_mem_no_str = tempValueArr.sort(compare).join("^");							
				}
			} else {
				gridData[j].use_mem_no_str = "";
			}
		}
		
		
		var data = {
			"mem_name" : "${info.mem_name}"
			, "doc_dt" : "${info.apply_date}"
			, "org_name" : "${info.org_name}"
			, "grade_name" : "${info.grade_name}"
			, "doc_buy_cd" : $M.getValue("doc_buy_cd")
			, "normal_remark" : $M.getValue("normal_remark")
			, "title" : $M.getValue("title")
			, "doc_buy_text" : $M.getValue("doc_buy_text")
			, "doc_name" : $M.getValue("doc_buy_cd") == "01" ? "품의서" : "일반품의서"
            , "doc_buy_use_name" : "${info.doc_buy_use_name}" // 23.11.22 용도추가
		};
		
		
		var param = {
			"data" : data
			, "dtlData" : gridData
			, "apprData" : apprMemoListJson
		}
		
		// openReportPanel('mmyy/mmyy011102p01_01.crf', param);
		openReportPanel('mmyy/mmyy011102p01_01_231122.crf', param); // 용도 추가로 인하여 수정
	}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="doc_no" name="doc_no" value="${info.doc_no}">
<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${info.appr_proc_status_cd}">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${info.appr_job_seq}" />
<input type="hidden" id="doc_type_cd" name="doc_type_cd" value="${info.doc_type_cd}" />
<input type="hidden" id="buy_row_index" name="buy_row_index" />
<input type="hidden" id="normal_seq_no" name="normal_seq_no" value="${dtlList[0].seq_no}"/>
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
        	<div class="text-right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
            </div>
<!-- 폼테이블 -->						
            <div class="title-wrap mt10">
                <div class="left approval-left">
                    <h4 class="primary">품의서상세</h4>		
                </div>
<!-- 결재영역 -->
				<div class="pl10">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
<!-- /결재영역 -->
            </div>								
            <table class="table-border mt10">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
                    <tr>
                        <th class="text-right">작성자</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.mem_name}">
                            <input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
                        </td>		
                        <th class="text-right">작성일</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly id="doc_dt" name="doc_dt" value="${info.doc_dt}" dateformat="yyyy-MM-dd">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right">부서</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.org_name}">
                            <input type="hidden" id="org_code" name="org_code" value="${info.org_code}">
                        </td>		
                        <th class="text-right">직위</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.grade_name}">
                            <input type="hidden" id="grade_cd" name="grade_cd" value="${info.grade_cd}">
                            <input type="hidden" id="job_cd" name="job_cd" value="${info.job_cd}">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right">구분</th>
                        <td>
                            <%-- 코드맵으로 변경 --%>
                            <c:forEach items="${codeMap['DOC_BUY']}" var="item">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" id="doc_buy_cd_${item.code_value}" name="doc_buy_cd" value="${item.code_value}" ${info.doc_buy_cd == item.code_value ? 'checked="checked"' : ''} disabled>
                                    <label class="form-check-label" for="doc_buy_cd_${item.code_value}">${item.code_name}</label>
                                </div>
                            </c:forEach>
                        </td>
                        <c:if test="${info.doc_buy_cd == '01'}">
                            <th class="text-right">결제수단</th>
                            <td>
                                <c:forEach items="${codeMap['DOC_BUY_USE']}" var="item">
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" id="doc_use_cd_${item.code_value}" name="doc_use_cd" value="${item.code_value}" ${info.doc_buy_use_cd == item.code_value ? 'checked="checked"' : ''} disabled>
                                        <label class="form-check-label" for="doc_use_cd_${item.code_value}">${item.code_name}</label>
                                    </div>
                                </c:forEach>
                            </td>
                        </c:if>
                    </tr>
                    <tr>
                        <th class="text-right essential-item">제목</th>
                        <td colspan="3">
                            <input type="text" class="form-control rb" id="title" name="title" value="${info.title}">
                        </td>						
                    </tr>		
                    <tr class="buy_form" id="buy_form">
                        <th class="text-right">내용</th>
                        <td colspan="3">
                            <textarea class="form-control" style="margin-top: 5px; height: 100px;" placeholder="내용을 입력하세요." id="doc_buy_text" name="doc_buy_text" alt="내용">${info.doc_buy_text}</textarea>
                        </td>						
                    </tr>                    			
                </tbody>
            </table>	
<!-- /폼테이블 -->
<!-- 하단 내용 -->                  
                    <div class="title-wrap mt10 ">
                        <h4>상세내역</h4>
                        <c:if test="${info.doc_buy_cd eq '01'}">
	                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
                        </c:if>
                    </div>
<!--                     <input type="hidden" id="buy_row_num"  name="buy_row_num" value="1"> -->
					<div class="normal_form" id="normal_form">
	                    <textarea class="form-control" style="margin-top: 5px; height: 200px;" placeholder="내용을 입력하세요." id="normal_remark" name="normal_remark">${dtlList[0].remark}</textarea>
                    </div>                    
					<div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>
	                    <table class="table-border mt10">
	                        <colgroup>
	                            <col width="100px">
	                            <col width="">
	                        </colgroup>
	                        <tbody>
	                            <tr>
	                                <th class="text-right">첨부파일</th>
	                                <td>
										<div class="table-attfile doc_file_div" style="width:100%;">
											<div class="table-attfile" style="float:left">
											<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
											&nbsp;&nbsp;
											</div>
										</div>
	                                </td>							
	                            </tr>			
	                        </tbody>
	                    </table>
                    <div class="doc-com ">
                        <div class="text">
                            위와 같이 품의서를 신청 하오니 재가하여 주시기 바랍니다.<br>
                            ${info.apply_date.substring(0,4)}년 ${info.apply_date.substring(4,6)}월 ${info.apply_date.substring(6,8)}일
                        </div>
                        <div class="detail-info">
                    부서 : ${info.org_name}<br>
                    성명 : ${info.mem_name}
                        </div> 
                    </div>			
<!-- /하단 내용 -->
<!-- 결재자 의견 -->   
            <div class="title-wrap mt10">
                <div class="left">
                    <h4>결재자 의견</h4>
                </div>                    
            </div>
				<table class="table mt5">
					<colgroup>
						<col width="40px">
						<col width="">
						<col width="60px">
						<col width="">
					</colgroup>
					<thead>
					<tr>
						<td colspan="5">
							<div class="fixed-table-container" style="width: 100%; height: 110px;">
								<!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
								<div class="fixed-table-wrapper">
									<table class="table-border doc-table md-table">
										<colgroup>
											<col width="40px">
											<col width="140px">
											<col width="55px">
											<col width="">
										</colgroup>
										<thead>
										<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
										<tr>
											<th class="th" style="font-size: 12px !important">구분</th>
											<th class="th" style="font-size: 12px !important">결재일시</th>
											<th class="th" style="font-size: 12px !important">담당자</th>
											<th class="th" style="font-size: 12px !important">특이사항</th>
										</tr>
										</thead>
										<tbody>
										<c:forEach var="list" items="${apprMemoList}">
											<tr>
												<td class="td"
													style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
												<td class="td"
													style="font-size: 12px !important">${list.proc_date }</td>
												<td class="td"
													style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
												<td class="td" style="font-size: 12px !important">${list.memo }</td>
											</tr>
										</c:forEach>
										</tbody>
									</table>
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
<!-- /결재자 의견 -->
			<div class="btn-group mt10">
				<div class="right">
					<!-- 관리부는 수정가능 -->
					<c:if test="${page.fnc.F02011_002 eq 'Y' and info.appr_proc_status_cd == '05'}">
						<button type="button" class="btn btn-info" id="_goModify" name="_goModify" onclick="javascript:goModify()">수정</button>
					</c:if>					
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/><jsp:param name="appr_yn" value="Y"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
<input type="hidden" id="doc_file_seq_1" name="doc_file_seq_1" value="${info.doc_file_seq_1 }" />
<input type="hidden" id="doc_file_seq_2" name="doc_file_seq_2" value="${info.doc_file_seq_2 }" />
<input type="hidden" id="doc_file_seq_3" name="doc_file_seq_3" value="${info.doc_file_seq_3 }" />
<input type="hidden" id="doc_file_seq_4" name="doc_file_seq_4" value="${info.doc_file_seq_4 }" />
<input type="hidden" id="doc_file_seq_5" name="doc_file_seq_5" value="${info.doc_file_seq_5 }" />
</body>
</html>