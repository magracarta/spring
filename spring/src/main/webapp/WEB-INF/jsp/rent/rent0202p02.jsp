<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 어태치먼트대장 > null > 어태치먼트 조회
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-07-22 20:38:49
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
				showRowNumColumn: true
			};
			var columnLayout = [
				{ 
					headerText : "어태치먼트명", 
					dataField : "attach_name", 
					width : "10%",
					style : "aui-left",
				},
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					style : "aui-center"
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					style : "aui-left",
				},
				{ 
					headerText : "매입가", 
					dataField : "buy_price", 
					style : "aui-right",
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "이자율", 
					dataField : "interest_rate",
					dataType : "numeric",
					style : "aui-right",
					formatString : "#,##0",
					width : "10%",
				},
				{ 
					headerText : "어태치먼트가액", 
					dataField : "attach_price", 
					dataType : "numeric",
					style : "aui-right",
					width : "10%",
					formatString : "#,##0"
				},
				{
					dataField : "part_no_machine",
					visible : false
				},
				{
					dataField : "cost_yn",
					visible : false
				}
				/* { 
					headerText : "최소판가", 
					dataField : "min_sale_price",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				}, */
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// Row행 클릭 시 반영
				try{
					opener.${inputParam.parent_js_name}(event.item);
					window.close();	
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				};
			});
			$("#auiGrid").resize();
		}
		
		// 조회
		function goSearch() {
			var param = {
				  "s_attach_name" : $M.getValue("s_attach_name")
				, "s_sort_key" : "p.part_name"
				, "s_sort_method" : "desc"
			};
			console.log(param);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}
		
		// 엔터
		function enter(fieldObj) {
	       var field = ["s_attach_name"];
	       $.each(field, function() {
	          if (fieldObj.name == this) {
	             goSearch(document.main_form);
	          }
	       });
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
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="40px">
						<col width="65px">							
						<col width="155px">
					</colgroup>
					<tbody>
						<tr>
							<th>어태치먼트명</th>
							<td>
								<input type="text" class="form-control" id="s_attach_name" name="s_attach_name">
							</td>
							<td>
								<button type="button" class="btn btn-important" style="width: 50px;"   onclick="javascript:goSearch()"   >조회</button>
							</td>									
						</tr>												
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
<!-- 검색결과 -->
			<div id="auiGrid" class="mt10" style="width: 100%;height: 600px;"></div>
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
</form>
</body>
</html>