<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 회계연관팝업 > 회계연관팝업 > null > 예금조회
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-09-03 18:20:36
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	$(document).ready(function() {
		createAUIGrid();
	});

	function enter(fieldObj) {
		var field = ["s_deposit_code", "s_deposit_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch(document.main_form);
			};
		});
	}
	
	function goSearch() {
		var param = {
				"s_deposit_code" : $M.getValue("s_deposit_code"),
				"s_deposit_name" : $M.getValue("s_deposit_name"),
				"acnt_code_str" : '${inputParam.s_acnt_code}',
				"s_sort_key" : "acnt_code",
				"s_sort_method" : "asc"
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
			    headerText: "예금코드",
			    dataField: "deposit_code",
			    width : "15%",
				style : "aui-center"
			},
			{
			    headerText: "예금코드명",
			    dataField: "deposit_name",
			    width : "35%",
				style : "aui-center"
			},				
			{
			    headerText: "계좌번호",
			    dataField: "account_no",
				style : "aui-center"
			},				
			{
			    headerText: "계좌번호",
			    dataField: "acnt_code",
			    visible:false
			},				
			{
			    headerText: "예금구분",
			    dataField: "use_not_text",
			    width : "10%",
				style : "aui-center",
			}
		];
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${list});
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
		$("#total_cnt").html(${total_cnt});
	}
	
	//팝업 닫기
	function fnClose() {
		window.close(); 
	}
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="acnt_code">
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
							<col width="90px">
							<col width="120px">
							<col width="*">
						</colgroup>
						<tbody>
							<tr>
								<th>예금코드</th>
								<td>
									<input type="text" class="form-control" id="s_deposit_code" name="s_deposit_code">
								</td>
								<th>예금코드명</th>
								<td>
									<input type="text" class="form-control" id="s_deposit_name" name="s_deposit_name">
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
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