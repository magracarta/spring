<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 구매품의서 > 구매품의서 등록 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var orgListJson = JSON.parse('${orgList}');     // 사용부서
	var assetTypeJson = JSON.parse('${codeMapJsonObj['ASSET_TYPE']}');			//자산물품구분
	var btnMemArrayTemp = ${memListJson}
	var btnMemArray = [];
	
	var orgList = [];
	
	for (var i in orgListJson) {
		orgList.push(orgListJson[i].org_code);
	}
	
	var rowNum = 0;
	
	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileCount = 5;
	
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
// 		$("#normal_remark").addClass("dpn");
		$("#normal_form").addClass("dpn");
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
	
	// 일반 - 첨부파일
	function fnAddFile() {
		if($("input[name='file_seq']").size() >= fileCount) {
			alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
			return false;
		}
		
		var param = {
			upload_type	: "DOC",
			file_type : "both",
		};
		
		openFileUploadPanel('setFileInfo', $M.toGetParam(param));
		
	}
	
	function setFileInfo(result) {
		var str = ''; 
		str += '<div class="table-attfile-item doc_file_' + fileIndex + '" style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
		str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
		str += '</div>';
		$('.doc_file_div').append(str);
		fileIndex++;
	}
	
	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) {
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".doc_file_" + fileIndex).remove();
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
				style : "aui-center aui-editable",
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
				}
			},
			{
				headerText: "사용자",
				dataField: "use_mem_no_str",
				width : "200",
				style : "aui-center aui-editable",
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
				}
			},
			{
				headerText: "구매사유",
				dataField: "buy_text",
				width : "160",
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText: "구매물품",
				dataField: "asset_type_cd",
				width : "80",
				style : "aui-center aui-editable",
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
			},
			{
				headerText: "구매처",
				dataField: "buy_office",
				width : "100",
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText: "제품명",
				dataField: "prod_name",
				width : "120",
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText: "수량",
				dataField: "buy_qty",
				width : "55",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true,
				      min : 1,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
			},
			{
				headerText: "구매가격",
				dataField: "unit_amt",
				width : "100",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right aui-editable",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true,
				      min : 1,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
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
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText: "자산지금품관리",
				dataField: "asset_yn",
				width : "100",
				style : "aui-center aui-editable",
				editable : true,
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				}
			},
			{
				headerText: "첨부파일",
				dataField: "origin_file_name",
				width : "120",
				style : "aui-center aui-editable",
				editable : false,
				renderer : { // HTML 템플릿 렌더러 사용
					type : "TemplateRenderer"
				},
				labelFunction : function( rowIndex, columnIndex, value, dataField, item) {
					if(item.buy_file_seq_1 == 0) {
						return '<button type="button" class="btn btn-default" style="width: 90%" onclick="javascript:goUploadImg(' + rowIndex + ');">이미지등록</button>';
					} else {
						// 21.08.31 (SR:12427) 파일다운로드 방식으로 변경 - 황빛찬
						var template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:fileDownload(' + item.buy_file_seq_1 + ');">' + value + '</span>' + '</div>';
						return template;
					}
				}
			},
			{
				headerText: "비고",
				dataField: "remark",
				width : "180",
				style : "aui-left aui-editable",
				editable : true,
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
		
		AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
			if ('${page.fnc.F02010_001}' != 'Y') {
				if (event.dataField == "use_org_code") {
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
		if ('${page.fnc.F02010_001}' == 'Y') {
			flag = true;
		}
		
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
    		item.row_num = rowNum,
    		item.asset_payment_no = "",
//     		item.use_org_code = "",
    		item.use_org_code = flag == true ? "" : '${inputParam.login_org_code}',
    		item.use_mem_no_str = "",
    		item.buy_text = "",
    		item.asset_type_cd = "",
    		item.buy_office = "",
    		item.prod_name = "",
    		item.buy_qty = 1,
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
				var rowIndex = gridData[i].row_num;
 			    AUIGrid.showToastMessage(auiGrid, rowIndex, 4, "사용부서, 사용자중 하나는 필수 입력입니다.");
 			    return false;
			}
			
			if (gridData[i].asset_type_cd == "") {
				var rowIndex = gridData[i].row_num;
			    AUIGrid.showToastMessage(auiGrid, rowIndex, 6, "구매물품은 필수 입력입니다.");
			    return false;
			}

			if (gridData[i].buy_office == "") {
				var rowIndex = gridData[i].row_num;
 			    AUIGrid.showToastMessage(auiGrid, rowIndex, 7, "구매처는 필수 입력입니다.");
 			    return false;
			}

            if (gridData[i].asset_yn == "Y" && gridData[i].prod_name == "") {
                var rowIndex = gridData[i].row_num;
                AUIGrid.showToastMessage(auiGrid, rowIndex, 8, "자산지급품 관리일때 제품명은 필수 입력입니다.");
                return false;
            }

			if (gridData[i].buy_qty == 0) {
				var rowIndex = gridData[i].row_num;
			    AUIGrid.showToastMessage(auiGrid, rowIndex, 9, "수량은 1개 이상이어야 합니다.");
			    return false;
			}

			if (gridData[i].unit_amt == 0) {
				var rowIndex = gridData[i].row_num;
				AUIGrid.showToastMessage(auiGrid, rowIndex, 10, "금액은 필수 입력입니다.");
				return false;
			}
		}
		
// 		return AUIGrid.validateGridData(auiGrid, ["asset_type_cd", "buy_office", "buy_qty", "unit_amt"], "필수 항목은 반드시 값을 입력해야합니다.");
		return true;
	}
	
	// 목록
	function fnList() {
// 		history.back();
		
		// 탭 클릭시 그리드를 그리는 방식이므로, 페이지를 다시 호출하는 방식 사용.
		var param = {
				"init_yn" : "Y"
			}
		$M.goNextPage("/mmyy/mmyy011102", $M.toGetParam(param));
	}
	
	// 그리드 폼 변경
	function fnChangeGrid(val) {
		var docBuyCd = val;
		
		if(confirm("구분 변경시 입력한 상세내역 데이터가 초기화됩니다.\n변경하시겠습니까?") == false) {
			// 취소 클릭시 체크 원래대로 돌리기.
			if (docBuyCd == "01") {
				$("#doc_buy_cd_01").prop("checked", false);
				$("#doc_buy_cd_02").prop("checked", true);
			} else {
				$("#doc_buy_cd_01").prop("checked", true);
				$("#doc_buy_cd_02").prop("checked", false);
			}
			return false;
		}
		
		// 구분 : 구매일경우 그리드 / 일반일경우 text
		if (docBuyCd == "01") {
			$("#normal_remark").val('');
			$("#normal_form").addClass("dpn");
			$("#auiGrid").removeClass("dpn");
			$("#buy_form").removeClass("dpn");
			$("#_fnAdd").show();
            $('input[name=doc_buy_use_cd]').attr('disabled', false);
		} else {
			AUIGrid.clearGridData(auiGrid);
			$("#auiGrid").addClass("dpn");
			$("#buy_form").addClass("dpn");
			$("#normal_form").removeClass("dpn");
			$("#_fnAdd").hide();
			$("#doc_buy_text").val('');
            $('input[name=doc_buy_use_cd]').attr('disabled', true);
            $('input[name=doc_buy_use_cd]').attr('checked', false);
		}
	}
	
	// 결재요청
	function goRequestApproval() {
		goSave('requestAppr');
	}
	
	// 저장
	function goSave(isRequestAppr) {
		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		// 구분 : 일반일경우 상세내역 벨리데이션 체크
		if ($M.getValue("doc_buy_cd") == '02') {
			if ($M.getValue("normal_remark") == "") {
				alert("내용은 필수 입력입니다.");
				$("#normal_remark").focus();
				return;
			}
		}
    
        // 용도 : 구매 일 경우 벨리데이션
        if($M.getValue('doc_buy_cd') == '01') {
          if($M.getValue('doc_buy_use_cd') == "") {
            alert("구분이 구매 일 경우 용도 선택은 필수 입니다.");
            return;
          }
        }
		
		var gridData = AUIGrid.getGridData(auiGrid);
		for (var i = 0; i < gridData.length; i++) {
			if (gridData[i].use_org_code == "" && gridData[i].use_mem_no_str == "") {
				var rowIndex = gridData[i].row_num;
 			    AUIGrid.showToastMessage(auiGrid, rowIndex, 4, "사용부서, 사용자중 하나는 필수 입력입니다.");
				return;
			}
			
			if (gridData[i].asset_type_cd == "") {
				var rowIndex = gridData[i].row_num;
			    AUIGrid.showToastMessage(auiGrid, rowIndex, 6, "구매물품은 필수 입력입니다.");
			    return;
			}

			if (gridData[i].buy_office == "") {
				var rowIndex = gridData[i].row_num;
 			    AUIGrid.showToastMessage(auiGrid, rowIndex, 7, "구매처는 필수 입력입니다.");
				return;
			}

            if (gridData[i].asset_yn == "Y" && gridData[i].prod_name == "") {
                var rowIndex = gridData[i].row_num;
                AUIGrid.showToastMessage(auiGrid, rowIndex, 8, "자산지급품 관리일때 제품명은 필수 입력입니다.");
                return;
            }

			if (gridData[i].buy_qty == 0) {
				var rowIndex = gridData[i].row_num;
			    AUIGrid.showToastMessage(auiGrid, rowIndex, 9, "수량은 1개 이상이어야 합니다.");
				return;
			}

			if (gridData[i].unit_amt == 0) {
				var rowIndex = gridData[i].row_num;
				AUIGrid.showToastMessage(auiGrid, rowIndex, 10, "금액은 필수 입력입니다.");
				return;
			}
		}

		var msg = "";
		if (isRequestAppr != undefined) {
			$M.setValue("save_mode", "appr"); // 결재요청
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "save"); // 저장
			msg = "저장 하시겠습니까?";
		}

        if (confirm(msg) == false) {
            return false;
        }

		var idx = 1;
		$("input[name='file_seq']").each(function() {
			var str = 'doc_file_seq_' + idx;
            if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
                $M.setValue(str, $(this).val());
            }
			idx++;
		});

		for(; idx <= fileCount; idx++) {
			$M.setValue('doc_file_seq_' + idx, '');
		}
		var frm = $M.toValueForm(document.main_form);
		var gridFrm = fnChangeGridDataToForm(auiGrid);
		$M.copyForm(gridFrm, frm);

		$M.goNextPageAjax(this_page + "/save", gridFrm , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			fnList();
				}
			}
		);
	}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<input type="hidden" id="buy_row_index" name="buy_row_index" />
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail ">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
<%-- 						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/> --%>
						<h2>품의서 등록</h2>
                    </div>
<!-- 결재영역 -->
                    <div class="pl10">
                    	<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
                    </div>
<!-- /결재영역 -->
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->					
                    <table class="table-border ">
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
                                    <input type="text" class="form-control width120px" readonly id="mem_name" name="mem_name" value="${info.kor_name}">
                                    <input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
                                </td>		
                                <th class="text-right">작성일</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="doc_dt" name="doc_dt" value="${inputParam.s_current_dt}" dateformat="yyyy-MM-dd">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right">부서</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="org_name" name="org_name" value="${info.org_name}">
                                    <input type="hidden" id="org_code" name="org_code" value="${info.org_code}">
                                </td>		
                                <th class="text-right">직위</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="grade_name" name="grade_name" value="${info.grade_name}">
                                    <input type="hidden" id="grade_cd" name="grade_cd" value="${info.grade_cd}">
                                    <input type="hidden" id="job_cd" name="job_cd" value="${info.job_cd}">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right essential-item">구분</th>
                                <td>
                                    <%-- 코드맵으로 변경 --%>
                                    <c:forEach items="${codeMap['DOC_BUY']}" var="item">
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="radio" id="doc_buy_cd_${item.code_value}" name="doc_buy_cd" value="${item.code_value}" ${'01' == item.code_value ? 'checked="checked"' : ''} onchange="javascipt:fnChangeGrid(this.value);">
                                            <label class="form-check-label" for="doc_buy_cd_${item.code_value}">${item.code_name}</label>
                                        </div>
                                    </c:forEach>
                                </td>
                                <th class="text-right essential-item">결제수단</th>
                                <td>
                                    <c:forEach items="${codeMap['DOC_BUY_USE']}" var="item">
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="radio" id="doc_buy_use_cd_${item.code_value}" name="doc_buy_use_cd" value="${item.code_value}">
                                            <label class="form-check-label" for="doc_buy_use_cd_${item.code_value}">${item.code_name}</label>
                                        </div>
                                    </c:forEach>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right essential-item">제목</th>
                                <td colspan="3">
                                    <input type="text" class="form-control rb" id="title" name="title" required="required" alt="제목">
                                </td>						
                            </tr>
                            <tr class="buy_form" id="buy_form">
                                <th class="text-right">내용</th>
                                <td colspan="3">
                                    <textarea class="form-control" style="margin-top: 5px; height: 100px;" placeholder="내용을 입력하세요." id="doc_buy_text" name="doc_buy_text" alt="내용"></textarea>
                                </td>						
                            </tr>					
                        </tbody>
                    </table>				
<!-- /폼테이블 -->	
<!-- 하단 내용 -->                  
                    <div class="title-wrap mt10 ">
                        <h4>상세내역</h4>
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
                    </div>
<!--                     <input type="hidden" id="buy_row_num"  name="buy_row_num" value="1"> -->
					<div class="normal_form" id="normal_form">
	                    <textarea class="form-control rb" style="margin-top: 5px; height: 200px;" placeholder="내용을 입력하세요." id="normal_remark" name="normal_remark" alt="내용"></textarea>
                    </div>                    
					<div id="auiGrid" style="margin-top: 5px; height: 250px;"></div>
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
                    <div class="doc-com  ">
                        <div class="text">
                            위와 같이 품의서를 신청 하오니 재가하여 주시기 바랍니다.<br>
                            ${inputParam.s_current_dt.substring(0,4)}년 ${inputParam.s_current_dt.substring(4,6)}월 ${inputParam.s_current_dt.substring(6,8)}일
                        </div>
                        <div class="detail-info">
                            부서 : ${info.org_name}<br>
                            성명 : ${info.kor_name}
                        </div> 
                    </div>			
<!-- /하단 내용 -->
					<div class="btn-group mt10 ">
						<div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>						
			</div>		
		</div>
<!-- /contents 전체 영역 -->
</div>
<input type="hidden" id="doc_file_seq_1" name="doc_file_seq_1" value=""/>
<input type="hidden" id="doc_file_seq_2" name="doc_file_seq_2" value=""/>
<input type="hidden" id="doc_file_seq_3" name="doc_file_seq_3" value=""/>
<input type="hidden" id="doc_file_seq_4" name="doc_file_seq_4" value=""/>
<input type="hidden" id="doc_file_seq_5" name="doc_file_seq_5" value=""/>
</form>	
</body>
</html>