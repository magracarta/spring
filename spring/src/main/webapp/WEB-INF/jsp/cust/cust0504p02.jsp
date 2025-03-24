<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객app관리 > 부품컨텐츠관리 > 부품명동의어관리 > 
-- 작성자 : 정윤수
-- 최초 작성일 : 2024-02-28 13:38:02
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function() {
			createAUIGrid();
			goSearch();

		});
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : true,
				showStateColumn : true,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					dataField: "detail_seq",
					visible : false
				},
				{
					dataField: "synonym_seq",
					visible : false
				},
				{
					dataField: "origin_part_name",
					visible : false
				},
				{
					headerText: "부품세부명칭",
					dataField: "detail_part_name",
					required : true,
					width : "35%",
					style : "aui-center aui-editable"
				},
				{
					headerText: "동의어",
					dataField: "synonym_part_name",
					required : true,
					width : "55%",
					style : "aui-left aui-editable",
				},
				{
					dataField: "removeBtn",
					headerText: "삭제",
					width: "10%",
					renderer: {
						type: "ButtonRenderer",
						onClick: function (event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGrid, {use_yn: "N"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
								AUIGrid.updateRow(auiGrid, {use_yn: "Y"}, event.rowIndex);
							}
						}
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style: "aui-center",
					editable: false
				},
				{
					dataField: "cmd",
					visible : false
				},
				{
					dataField: "use_yn",
					visible : false
				},

			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}

		//조회
		function goSearch() {
			var param = {
				"s_detail_part_name" : $M.getValue("s_detail_part_name"), // 부품세부명칭
				"s_synonym_part_name" : $M.getValue("s_synonym_part_name"), // 동의어
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					};
				}
			);
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["detail_part_name", "synonym_part_name"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			if (fnCheckGridEmpty(auiGrid) === false){
				return false;
			}
			if(confirm("저장하시겠습니까?") == false) {
				return false;
			}

			// 변경내역 form으로 변경
			var gridFrm = fnChangeGridDataToForm(auiGrid, "Y");

			$M.goNextPageAjax(this_page + "/save", gridFrm, {method : 'POST'},
					function(result) {
						if (result.success) {
							goSearch();
						}
					});
		}
		
		
		// 행추가
		function fnAdd() {
			if (fnCheckGridEmpty(auiGrid) === false){
				return false;
			}
			var param = {};
			$M.goNextPageAjax(this_page + '/getSeqNo', $M.toGetParam(param), {method : 'get'},
					function(result){
						if(result.success) {
							var item = new Object();
							item.detail_seq = result.c_part_name_seq;
							item.synonym_seq = "";
							item.detail_part_name = "";
							item.synonym_part_name = "";
							item.origin_part_name = "";
							item.cmd = "C";
							item.use_yn = "Y";
							AUIGrid.addRow(auiGrid, item, "last");
						};
					}
			);
			
		
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_synonym_part_name", "s_detail_part_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "부품명 동의어", "");
		}
		
		//팝업 닫기
		function fnClose(){
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
			<!-- 폼테이블 -->
			<div>
				<!-- 검색영역 -->
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="80px">
							<col width="150px">
							<col width="50px">
							<col width="150px">
							<col width="*">
						</colgroup>
						<tbody>
						<tr>
							<th>부품세부명칭</th>
							<td>
								<input type="text" class="form-control" id="s_detail_part_name" name="s_detail_part_name">
							</td>

							<th>동의어</th>
							<td>
								<input type="text" class="form-control" id="s_synonym_part_name" name="s_synonym_part_name">
							</td>
							<td class="">
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색영역 -->
				<div class="title-wrap">
					<h4>조회결과</h4>
					<div class="btn-group mt10">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px;height: 370px;"></div>
			</div>
			<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>