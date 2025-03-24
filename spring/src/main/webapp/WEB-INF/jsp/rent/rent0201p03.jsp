<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 렌탈장비대장 > null > GPS대장조회
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {			
				// rowIdField 설정
				rowIdField : "row", 
				showRowNumColumn : true
			};
			var columnLayout = [
				{ 
					dataField : "gps_seq",
					visible : false
				},
				{ 
					headerText : "개통일", 
					dataField : "open_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "13%", 
					style : "aui-center"
				},
				{
					headerText : "고객구분", 					
					dataField : "own_name", 
					width : "12%",  
					style : "aui-center"
				},
				{ 
					headerText : "종류", 
					dataField : "gps_type_name",					
					width : "12%", 
					style : "aui-center"
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					style : "aui-center"
				},
				{ 
					headerText : "개통번호", 
					dataField : "gps_no", 
					width : "13%",  
					style : "aui-center"
				},
				{ 
					headerText : "계약번호", 
					dataField : "contract_no", 
					width : "13%", 
					style : "aui-center"
				},
				{ 
					headerText : "GPS모델", 
					dataField : "gps_model_name", 
					width : "13%", 
					style : "aui-center"
				},
				{
					headerText : "사용기간",
					dataField : "use_time", 
					width : "12%", 
					style : "aui-center"

				},	
				{
					headerText : "관리센터",
					dataField : "center_org_name", 
					width : "12%", 
					style : "aui-center"
				},
				{
					dataField : "last_inst_dt",
					visible : false
				},
				{
					dataField : "last_machine_seq",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				try{
					if (event.item.body_no != null && event.item.body_no != "") {
						alert("이미 다른 장비에 장착된 GPS입니다.");
						return false;
					}
					if ("${inputParam.machine_seq}" == event.item.last_machine_seq && 
						"${inputParam.s_current_dt}" == event.item.last_inst_dt) {
						alert("같은 장비에서 오늘 탈거된 GPS를 오늘 다시 장착할 수 없습니다.");
						return false;
					}
					opener.${inputParam.parent_js_name}(event.item);
					window.close();	
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				};
			});	
		}
		
		// 조회
		function goSearch() {
			var param = {
				"s_gps_no" : $M.getValue("s_gps_no")
				, "s_contract_no" : $M.getValue("s_contract_no")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}

		// 닫기
		function fnClose() {
			window.close();
		}
		
		// 엔터
		function enter(fieldObj) {
	       var field = ["s_gps_no","s_contract_no"];
	       $.each(field, function() {
	          if (fieldObj.name == this) {
	             goSearch(document.main_form);
	          }
	       });
	    }
		
	</script>
</head>
<body  class="bg-white" >
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">				
			<div>
				<div class="title-wrap">
					<h4>GPS대장조회</h4>				
				</div>
<!-- 검색영역 -->					
				<div class="search-wrap mt5">				
					<table class="table table-fixed">
						<colgroup>
							<col width="60px">
							<col width="120px">		
							<col width="60px">
							<col width="120px">				
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>GPS번호</th>
								<td>
									<input type="text" class="form-control" id="s_gps_no" name="s_gps_no">
								</td>
								<th>계약번호</th>
								<td>
									<input type="text" class="form-control" id="s_contract_no" name="s_contract_no">
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();" >조회</button>
								</td>					
							</tr>						
						</tbody>
					</table>					
				</div>
<!-- /검색영역 -->
				<div  id="auiGrid"  style="margin-top: 5px; height: 450px;"></div>
				<div class="btn-group mt10">						
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>			
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>