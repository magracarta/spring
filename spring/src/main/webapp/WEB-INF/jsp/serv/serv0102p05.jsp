<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 자주쓰는 조치
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-16 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGrid;
	// 고장부위
	var breakPartJson = ${breakPartList};
	// 고장현상
	var breakStatusJson = JSON.parse('${codeMapJsonObj['BREAK_STATUS']}');
	// 고장원인
	var breakReasonJson = JSON.parse('${codeMapJsonObj['BREAK_REASON']}');
	// 행번호
	var rowNum = '${rowNum}' + 1;
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
	});

	// 행삭제
	function fnRemove() {
		var removeData = AUIGrid.getCheckedRowItems(auiGrid);
		if(removeData.length == 0) {
			alert("적용할 데이터를 체크해주세요.");
			return;
		}

		for(var i in removeData) {
			var isRemoved = AUIGrid.isRemovedById(auiGrid, removeData[i].item._$uid);
			if(isRemoved == false) {
				AUIGrid.removeRow(auiGrid, removeData[i].rowIndex);
				AUIGrid.update(auiGrid);
			} else {
				AUIGrid.restoreSoftRows(auiGrid, removeData[i].rowIndex);
				AUIGrid.update(auiGrid);
			}
		}
	}

	// 적용
	function goApplyInfo() {
		var checkedData = AUIGrid.getCheckedRowItems(auiGrid);
		if(checkedData.length == 0) {
			alert("적용할 데이터를 체크해주세요.");
			return;
		}

		for(var i in checkedData) {
			if(checkedData[i].item.save_yn == "N") {
				alert("저장하지 않은 내용은 선택할 수 없습니다.\n저장 후 진행해주세요.");
				return;
			}
		}

		console.log(checkedData);
		try {
			opener.${inputParam.parent_js_name}(checkedData);
			window.close();
		} catch(e) {
			alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
		}
	}

	// 행추가
	function fnAdd() {
		if(fnCheckGridEmpty()) {
			var item = new Object();
			item.break_part_seq = "";
			item.break_status_cd = "";
			item.break_reason_cd = "";
			item.remark = "";
			item.row_num = rowNum;
			item.break_part_bookmark_seq = "0";
			item.use_yn = "Y";
			item.save_yn = "N";

			AUIGrid.addRow(auiGrid, item, 'last');
		};

		rowNum++;
	}

	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["break_part_seq", "break_status_cd", "break_reason_cd"], "필수 항목은 반드시 값을 입력해야합니다.");
	}

	// 저장
	function goSave() {
		var frm = $M.toValueForm(document.main_form);
		var gridForm = fnChangeGridDataToForm(auiGrid, 'use_yn');

		// grid form 안에 frm 카피
		$M.copyForm(gridForm, frm);
		console.log(gridForm);

		$M.goNextPageAjaxSave(this_page + "/save", gridForm, {method : "POST"},
			function(result) {
				if(result.success) {
					alert("저장이 완료하였습니다.");
					location.reload();
				}
			}
		);
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			// 체크박스 출력 여부
			showRowCheckColumn : true,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : true,
			showStateColumn : true,
			editable : true
		};
		var columnLayout = [
			{ 
				headerText : "고장부위", 
				dataField : "break_part_seq",
				style : "aui-left aui-editable",
				width : "30%",
				showEditorBtn : false,
				showEditorBtnOver : false,
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					list : breakPartJson,
					keyField : "break_part_seq",
					valueField  : "path_break_part_name"
				},
				labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
					var retStr = value;
					for(var j = 0; j < breakPartJson.length; j++) {
						if(breakPartJson[j]["break_part_seq"] == value) {
							retStr = breakPartJson[j]["path_break_part_name"];
							break;
						}
					}
					return retStr;
				},
			},
			{
				headerText : "고장현상", 
				dataField : "break_status_cd",
				style : "aui-left aui-editable",
				width : "15%",
				showEditorBtn : false,
				showEditorBtnOver : false,
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					list : breakStatusJson,
					keyField : "code_value",
					valueField  : "code_name"
				},
				labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
					var retStr = value;
					for(var j = 0; j < breakStatusJson.length; j++) {
						if(breakStatusJson[j]["code_value"] == value) {
							retStr = breakStatusJson[j]["code_name"];
							break;
						}
					}
					return retStr;
				},
			},
			{
				headerText : "고장원인", 
				dataField : "break_reason_cd",
				style : "aui-left aui-editable",
				width : "15%",
				showEditorBtn : false,
				showEditorBtnOver : false,
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					list : breakReasonJson,
					keyField : "code_value",
					valueField  : "code_name"
				},
				labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
					var retStr = value;
					for(var j = 0; j < breakReasonJson.length; j++) {
						if(breakReasonJson[j]["code_value"] == value) {
							retStr = breakReasonJson[j]["code_name"];
							break;
						}
					}
					return retStr;
				},
			},
			{
				headerText : "특이사항", 
				dataField : "remark",
				style : "aui-left aui-editable",
				width:"40%"
			},
			{
				headerText : "고장부위명",
				dataField : "mng_name",
				visible : false
			},
			{
				headerText : "행번호",
				dataField : "row_num",
				visible : false
			},
			{
				headerText : "자주쓰는번호",
				dataField : "break_part_bookmark_seq",
				visible : false
			},
			{
				headerText : "사용여부",
				dataField : "use_yn",
				visible : false
			},
			{
				headerText : "저장여부",
				dataField : "save_yn",
				visible : false
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${breakBookmarkList});
		
		$("#auiGrid").resize();
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
<!-- 의견추가내역 -->
			<div class="title-wrap">
				<h4>조치목록</h4>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>

				</div>
			</div>				
			<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
<!-- /의견추가내역 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">						
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