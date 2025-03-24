<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 new > 상세 > 공구관리
-- 작성자 : jsk
-- 최초 작성일 : 2024-05-27 13:29:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var gridRowIndex;

		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});

		// 엔터키 이벤트
		function enter(fieldObj) {
			const field = ["s_tool_name"];
			field.forEach(name => {
				if (fieldObj.name == name) {
					goSearch();
				}
			});
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				editable : true,
				rowIdField : "_$uid",
				showRowNumColumn: true,
				fillColumnSizeMode: true
			};
			var columnLayout = [
				{
					dataField : "svc_tool_seq",
					visible : false
				},
				{
					headerText : "공구명",
					dataField : "tool_name",
					style : "aui-left  aui-editable",
					required : true,
					editable : true
				},
				{
					headerText : "정렬순서",
					dataField : "sort_no",
					style : "aui-center aui-editable",
					required : true,
					editable : true,
					width : "7%"
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					style : "aui-center",
					width : "10%",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				},
				{
					headerText : "등록자",
					dataField : "reg_mem_name",
					width : "10%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "등록일",
					dataField : "reg_date",
					dataType : "date",
					width : "15%",
					formatString : "yyyy-mm-dd",
					editable : false
				},
				{
					headerText : "변경자",
					dataField : "upt_mem_name",
					width : "10%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "변경일시",
					dataField : "upt_date",
					dataType : "date",
					width : "20%",
					formatString : "yy-mm-dd HH:MM:ss",
					editable : false
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);

			$("#auiGrid").resize();
		}

		// 그리드 이벤트 핸들러
		function auiCellEditHandler(event) {
			switch (event.type) {
				case "cellEditEndBefore" :
					if (event.dataField == "tool_name") {
						var isUnique = AUIGrid.isUniqueValue(auiGrid, event.dataField, event.value);
						if (isUnique == false && event.value != "" && event.oldValue != event.value && event.item.use_yn == "Y") {
							setTimeout(function() {
								AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "공구명이 중복됩니다.");
							}, 1);
						}
						return event.value;
					}
					break;
			}
		}

		// 조회
		function goSearch() {
			var param = {
					s_tool_name : $M.getValue("s_tool_name")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}

		// 행추가
		function fnAdd() {
			if(fnCheckGridEmpty()) {
				var item = new Object();
				item.svc_tool_seq = "";
				item.tool_name = "";
				item.sort_no = "";
				item.use_yn = "Y";

				AUIGrid.addRow(auiGrid, item, 'first');
			}
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validation(auiGrid);
		}

		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			}
			if (fnCheckGridEmpty(auiGrid) === false){
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			}

			var gridData = AUIGrid.getGridData(auiGrid);
			for (i = 0; i < gridData.length; i++) {
				if (gridData[i].use_yn == 'Y') {
					for (j=i+1; j < gridData.length-1; j++) {
						if (gridData[j].use_yn == 'Y' && gridData[i].tool_name == gridData[j].tool_name) {
							alert("중복된 공구명이 있습니다. 공구명: " + gridData[i].tool_name);
							return false;
						}
					}
				}
			}

			var editedData = AUIGrid.getEditedRowItems(auiGrid);
			var notCheckArr = [];
			for (i = 0; i < editedData.length; i++) {
				if (editedData[i].use_yn == 'N') {
					notCheckArr.push(editedData[i].svc_tool_seq);
				}
			}

			var frm = fnChangeGridDataToForm(auiGrid);
			$M.setHiddenValue(frm, "no_svc_tool_seq_str", $M.getArrStr(notCheckArr, {isEmpty : true}));

			$M.goNextPageAjaxSave(this_page +"/save", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						opener.${inputParam.parent_js_name}();
						location.reload();
					}
				}
			);
		}

		// 닫기
		function fnClose() {
			opener.${inputParam.parent_js_name}();
			window.close();
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
<!-- 검색조건 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="150px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>공구명</th>
							<td>
								<input type="text" class="form-control" id="s_tool_name" name="s_tool_name" >
							</td>
							<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R" /></jsp:include>
					</div>
				</div>
			</div>
<!-- 검색결과 -->
			<div id="auiGrid" style="margin-top: 5px; height: 320px;"></div>
			<div class="btn-group mt10">
				<div class="left">
						총 <strong class="text-primary"  id="total_cnt" >0</strong>건
				</div>		
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>