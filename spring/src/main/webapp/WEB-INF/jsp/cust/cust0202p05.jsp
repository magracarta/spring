<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 매출처리 > null > 렌탈참조
-- 작성자 : 박예진
-- 최초 작성일 : 2020-10-12 16:21:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
			fnInit();
		});
		
		function fnInit() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
			
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "rental_doc_no",
				// No. 제거
				showRowNumColumn: true,
				editable : false
			};
			var columnLayout = [
				{
					headerText : "렌탈시작일자", 
					dataField : "rental_st_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "12%",
					style : "aui-center"
				},
				{ 
					headerText : "렌탈종료일자", 
					dataField : "rental_ed_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "12%",
					style : "aui-center"
				},
				{ 
					headerText : "렌탈 회차", 
					dataField : "rental_depth", 
					width : "10%",
					style : "aui-center",
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "13%",
					style : "aui-center",
				},
				{ 
					headerText : "메이커명", 
					dataField : "maker_name", 
					width : "15%",
					style : "aui-center",
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "15%",
					style : "aui-center",
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					style : "aui-center",
				},
				{ 
					headerText : "접수자", 
					dataField : "receipt_mem_name", 
					width : "13%",
					style : "aui-center",
				},
				{ 
					dataField : "receipt_mem_no", 
					visible : false
				},
				{ 
					dataField : "cust_no", 
					visible : false
				},
				{ 
					dataField : "maker_cd", 
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// Row행 클릭 시 반영
				try{
					opener.${inputParam.parent_js_name}(event.item);
					window.close();	
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				}
			});	
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_body_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		//조회
		function goSearch() { 
			var param = {
					"s_sort_key" : "rental_doc_no", 
					"s_sort_method" : "asc",
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_body_no" : $M.getValue("s_body_no"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt")
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
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
			<div class="title-wrap">
				<h4>렌탈현황</h4>
			</div>
<!-- 검색영역 -->					
			<div class="search-wrap mt5">				
				<table class="table table-fixed">
					<colgroup>
						<col width="65px">
						<col width="260px">
						<col width="55px">
						<col width="100px">
						<col width="65px">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>렌탈일자</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="">
										</div>
									</div>
									<div class="col-auto text-center">~</div>
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${inputParam.s_current_dt}">
										</div>
									</div>
								</div>
							</td>
							<th>고객명</th>
							<td>
								<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
							</td>
							<th>차대번호</th>
							<td>
								<input type="text" class="form-control" id="s_body_no" name="s_body_no">
							</td>
							<td>	
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
							</td>									
						</tr>						
					</tbody>
				</table>					
			</div>
<!-- /검색영역 -->
<!-- 폼테이블 -->					
			<div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
			</div>
<!-- /폼테이블-->					
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