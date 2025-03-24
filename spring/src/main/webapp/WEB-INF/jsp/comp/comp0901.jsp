<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 회계연관팝업 > 회계연관팝업 > null > 계정조회
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-24 11:45:19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var acntTypeJson = JSON.parse('${codeMapJsonObj['ACNT_TYPE']}');
		
		$(document).ready(function() {
			createAUIGrid();
		});
	
		function enter(fieldObj) {
			var field = ["s_acnt_code", "s_acnt_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		function goSearch() {
			var param = {
					"s_acnt_code" : $M.getValue("s_acnt_code"),
					"s_acnt_name" : $M.getValue("s_acnt_name"),
					// "s_search_type" : $M.getValue("s_search_type"),
					"s_sort_key" : "acnt_code",
					"s_sort_method" : "asc"
			};
			console.log(param);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					};
				}
			);
		}
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "acnt_code",
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				// rowNumber 
				showRowNumColumn: true,
				editable : false,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "계정코드",
				    dataField: "acnt_code",
				    width : "30%",
					style : "aui-center"
				},
				{
				    headerText: "계정명",
				    dataField: "acnt_name_print",
				    width : "50%",
					style : "aui-center"
				},				
				{
				    headerText: "계정명",
				    dataField: "acnt_name",
				    visible:false
				},				
				{
				    headerText: "분류",
				    dataField: "acnt_type_cd",
				    width : "20%",
					style : "aui-center",
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : acntTypeJson,
						keyField : "code_value",
						valueField  : "code_name"
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = value;
						for(var j = 0; j < acntTypeJson.length; j++) {
							if(acntTypeJson[j]["code_value"] == value) {
								retStr = acntTypeJson[j]["code_name"];
								break;
							} else if (value == "0") {
								retStr = "";
								break;
							}
						}
						return retStr;
					}
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#total_cnt").html(${total_cnt});
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// Row행 클릭 시 반영
				try{
					opener.${inputParam.parent_js_name}(event.item);
					window.close();	
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				}
			});
			$("#auiGrid").resize();
		}
		
		// 추가검색
		function goMore() {
			var param = {
					
			};
			openAccountInfoPanel("more${inputParam.parent_js_name}", $M.toGetParam(param));
			/* fnClose(); */
		}

		//팝업 닫기
		function fnClose() {
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
							<col width="70px">
							<col width="100px">
							<col width="50px">
							<col width="120px">
							<col width="*">
						</colgroup>
						<tbody>
							<tr>
								<th>계정코드</th>
								<td>
									<input type="text" class="form-control" id="s_acnt_code" name="s_acnt_code">
								</td>
								<th>계정명</th>
								<td>
									<input type="text" class="form-control" id="s_acnt_name" name="s_acnt_name">
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
								<%-- <td style="float:right; line-height: 2">
									<label><input type="radio" name="s_search_type" value="" <c:if test="${empty inputParam.s_search_type}">checked</c:if>>전체</label>
									<label><input type="radio" name="s_search_type" value="CARD" <c:if test="${not empty inputParam.s_search_type and  'CARD' eq inputParam.s_search_type}">checked</c:if>>카드비용</label>
									<label><input type="radio" name="s_search_type" value="IMPREST" <c:if test="${not empty inputParam.s_search_type and  'IMPREST' eq inputParam.s_search_type}">checked</c:if>>전도금</label>
								</td>--%>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
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