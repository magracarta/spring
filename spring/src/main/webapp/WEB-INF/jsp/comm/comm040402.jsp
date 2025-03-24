<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 서비스관련코드 > 점검리스트항목관리 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-16 10:05:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function() {
			createAUIGrid();
			fnInit();
		});

		// 초기셋팅
		function fnInit() {
			goSearch();
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_code_v1", "s_code_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}

		// 조회
		function goSearch() {
			var params = {
				"s_code_v1": $M.getValue("s_code_v1"),
				"s_code_name": $M.getValue("s_code_name"),
				"s_front_code": $M.getValue("s_front_code")
			};

			$M.goNextPageAjax("/comm/comm0404/search", $M.toGetParam(params), {method: 'GET'},
					function (result) {
						if (result.success) {
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		// 행추가
		function fnAdd() {
			if(fnCheckGridEmpty(auiGrid)) {
				var item = new Object();
				item.svc_code = "";
				item.code_v1 = "";
				item.code_name = "";
				item.sort_no = "";
				item.use_yn = "Y";

				AUIGrid.addRow(auiGrid, item, 'first');
			}
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["svc_code", "code_v1", "code_name", "sort_no"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 저장
		function goSave() {

			var frm = $M.toValueForm(document.main_form);

			// 추가된 행
			var addedRow = AUIGrid.getAddedRowItems("#auiGrid");
			// 수정된 행
			var editedRow = AUIGrid.getEditedRowItems("#auiGrid");

			var code = [];
			var code_v1= [];
			var code_name = [];
			var sort_no = [];
			var use_yn = [];
			var cmd = [];

			for(var i in addedRow) {
				var codeValue = $M.getValue("s_front_code") + addedRow[i].svc_code;
				code.push(codeValue);
				code_v1.push(addedRow[i].code_v1);
				code_name.push(addedRow[i].code_name);
				sort_no.push(addedRow[i].sort_no);
				use_yn.push(addedRow[i].use_yn);
				cmd.push("C");
			}

			for(var i in editedRow) {
				var codeValue = $M.getValue("s_front_code") + editedRow[i].svc_code;
				code.push(codeValue);
				code_v1.push(editedRow[i].code_v1);
				code_name.push(editedRow[i].code_name);
				sort_no.push(editedRow[i].sort_no);
				use_yn.push(editedRow[i].use_yn);
				cmd.push("U");
			}

			var option = {
				isEmpty : true
			};

			$M.setValue(frm, "code_str", $M.getArrStr(code, option));
			$M.setValue(frm, "code_v1_str", $M.getArrStr(code_v1, option));
			$M.setValue(frm, "code_name_str", $M.getArrStr(code_name, option));
			$M.setValue(frm, "sort_no_str", $M.getArrStr(sort_no, option));
			$M.setValue(frm, "use_yn_str", $M.getArrStr(use_yn, option));
			$M.setValue(frm, "cmd_str", $M.getArrStr(cmd, option));

			$M.goNextPageAjaxSave("/comm/comm0404/save", frm, {method : "POST"},
					function(result) {
						if(result.success) {
							location.reload();
						}
					}
			);
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid", // rowIdField 설정
				editable: true, // 수정가능여부
				showRowNumColumn: true,
				showStateColumn: true
			};

			var columnLayout = [
				{
					headerText: "origin_코드",
					dataField: "code",
					visible: false
				},
				{
					headerText: "코드",
					dataField: "svc_code",
					dataType: "numeric",
					width: "10%",
					style: "aui-center aui-editable",
					editRenderer : {
						type : "InputEditRenderer",
						length : 3,
						maxlength : 3,
						onlyNumeric : true,
						auiGrid : "#auiGrid",
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText: "분류",
					dataField: "code_v1",
					width: "20%",
					style: "aui-left aui-editable",
				},
				{
					headerText: "점검항목",
					dataField: "code_name",
					width: "50%",
					style: "aui-left aui-editable",
				},
				{
					headerText: "정렬순서",
					dataField: "sort_no",
					dataType: "numeric",
					width: "10%",
					style: "aui-center aui-editable",
				},
				{
					headerText: "사용여부",
					dataField: "use_yn",
					width: "10%",
					style: "aui-center",
					renderer: {
						type: "CheckBoxEditRenderer",
						editable: true,
						checkValue: "Y",
						unCheckValue: "N"
					}
				},
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
		}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
	<input type="hidden" id="s_front_code" name="s_front_code" value="R">
	<!-- contents 전체 영역 -->
	<div class="content-box" style="width : 60%;">
		<div class="contents">
			<!-- 검색영역 -->
			<div class="search-wrap mt10">
				<table class="table table-fixed">
					<colgroup>
						<col width="55px">
						<col width="120px">
						<col width="65px">
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>분류명</th>
						<td>
							<input type="text" class="form-control" id="s_code_v1" name="s_code_v1">
						</td>
						<th>점검항목</th>
						<td>
							<input type="text" class="form-control" id="s_code_name" name="s_code_name">
						</td>
						<td>
							<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색영역 -->
			<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="title-wrap mt10">
				<div class="btn-group">
					<h4>점검리스트코드 조회결과</h4>
					<div>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->
			<div id="auiGrid" style="margin-top: 5px; height: 480px;"></div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	<!-- /contents 전체 영역 -->
</form>
</body>
</html>