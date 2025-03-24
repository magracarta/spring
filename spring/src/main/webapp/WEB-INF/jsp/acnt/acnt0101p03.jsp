<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 비용관리 > 카드사용내역관리 > null > 계정과목
-- 작성자 : 손광진
-- 최초 작성일 : 2020-05-06 15:06:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function () {
			createAUIGrid();
			goSearch();
		});
		
		// 계정과목 목록 검색
		function goSearch() {
	
			var param = {
				"s_acnt_code" : $M.getValue("s_acnt_code"),
				"s_acnt_name" : $M.getValue("s_acnt_name"),
				"s_sort_key" 		: "acnt_code",
				"s_sort_method" 	: "asc",
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);	
						$("#total_cnt").html(result.total_cnt);
					};
				}
			);
		}
	
		function fnClose() {
			window.close();
		}
	
		// 검색 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_acnt_code", "s_acnt_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		
		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부
				showRowNumColum : true,
			}
	
			var columnLayout = [
				{
					headerText : "계정과목코드",
					dataField : "acnt_code"
				},
				{
					headerText : "계정과목명",
					dataField : "acnt_name"
				}
			]
	
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			// 클릭한 셀 데이터 받음
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				try {
					opener.${inputParam.parent_js_name}(event.item);
					window.close(); 
				} catch(e) {
					alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
				}

			});
		}
	</script>
</head>
<body>
<!-- 팝업 -->
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<!-- 검색영역 -->
		<div class="search-wrap mt5">
			<table class="table table-fixed">
				<colgroup>
					<col width="40px">
					<col width="95px">
					<col width="50px">
					<col width="95px">
					<col width="">
				</colgroup>
				<tbody>
				<tr>
					<th>코드</th>
					<td>
						<input type="text" class="form-control" id="s_acnt_code" name="s_acnt_code">
					</td>
					<th>과목명</th>
					<td>
						<input type="text" class="form-control" id="s_acnt_name" name="s_acnt_name">
					</td>
					<td>
						<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
					</td>
				</tr>
				</tbody>
			</table>
		</div>
		<!-- /검색영역 -->
		<!-- 계정과목 -->
		<div id="auiGrid" style="margin-top: 5px; width: 100%; height: 315px;"></div>
		<!-- /계정과목 -->
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

</body>
</html>