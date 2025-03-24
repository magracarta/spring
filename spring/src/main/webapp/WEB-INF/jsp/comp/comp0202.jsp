<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 문자발송 > null > 템플릿선택
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		
		$(document).ready(function() {
			createAUIGrid();
		});
		
 		//조회
		function goSearch() { 
			var param = {
					"s_org_code" : $M.getValue("s_org_code"),
					"s_template_name" : $M.getValue("s_template_name"),
					"s_template_text" : $M.getValue("s_template_text"),
					"s_sort_key" : "reg_date",
					"s_sort_method" : "desc"
			}; 

			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					};
				}
			)
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_template_name", "s_template_text"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		} 
		
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "sms_template_seq",
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
			};
			
			var columnLayout = [
				{
					dataField : "sms_template_seq", 
					visible : false
					
				},
				{
					headerText : "템플릿명", 
					dataField : "template_name", 
					width : "17%", 
					style : "aui-center",
					
				},
				{ 
					headerText : "내용", 
					dataField : "template_text", 
					style : "aui-left",
				}
			]
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				try{
					opener.${inputParam.parent_js_name}(event.item);
					window.close();	
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				};
			});
			$("#auiGrid").resize();
		}
		
		//팝업 끄기
		function fnClose() {
			window.close(); 
		}
		
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	  
<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="100px">
						<col width="60px">
						<col width="100px">
						<col width="40px">
						<col width="140px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>센터</th>
							<td>
								<select class="form-control" id="s_org_code" name="s_org_code">
									<option value="">- 전체 -</option>
									<c:forEach var="item" items="${orgCenterList}">
										<option value="${item.org_code}">${item.org_name}</option>
									</c:forEach>
								</select>
							</td>	
							<th>템플릿명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control width100px" id="s_template_name" name="s_template_name">
									<button type="button" class="icon-btn-cancel"></button>
								</div>
							</td>
							<th>내용</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control width140px" id="s_template_text" name="s_template_text">
									<button type="button" class="icon-btn-cancel"></button>
								</div>
							</td>
							<td class=""><button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
<!-- 검색결과 -->
			
			<div id="auiGrid" style="margin-top: 5px; height: 250px;"></div>
			
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
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