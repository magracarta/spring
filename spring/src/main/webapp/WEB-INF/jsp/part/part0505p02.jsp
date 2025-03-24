<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 재고조정요청현황 > null > 센터실사자료참조
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();	
			fnInit();
		});
		
		function fnInit() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
		}
		
		
		function goSearch() {
			
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),					
				s_warehouse_cd : "${inputParam.s_warehouse_cd}",
				s_sort_key     : "stock_dt",
				s_sort_method  : "asc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
							
					};
				}
			);
		}
		
		function goApply() {
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			console.log(itemArr);
			opener.setCheckStockInfo(itemArr);
			window.close();
		}
		
		//팝업 닫기
		function fnClose() {
			window.close(); 
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "조사일",
				    dataField: "stock_dt",
					style : "aui-center",
					dataType : "date",  
					formatString : "yyyy-mm-dd"
				},
				{
					headerText : "조사자",
					dataField : "reg_mem_name",
					style : "aui-center"
				},
				{
				    headerText: "품번",
				    dataField: "part_no",
				    width: "15%",
					style : "aui-center"
				},
				{
				    headerText: "품명",
				    dataField: "part_name",
				    width: "20%",
					style : "aui-left"
				},
				{
				    dataField: "part_check_stock_seq",
				    visible : false
				},
				{
				    dataField: "storage_name",
				    visible : false
				},
				
				{
				    headerText: "센터현재고",
				    dataField: "current_stock",
				 	dataType : "numeric",
				 	formatString : "#,##0",
					style : "aui-right"
				},
				{
				    headerText: "실사",
				    dataField: "check_stock",
				    width: "5%",
				 	dataType : "numeric",
				 	formatString : "#,##0",
					style : "aui-right"
				},
				{
				    headerText: "차이",
				    dataField: "diff_cnt",
				    width: "5%",
				 	dataType : "numeric",
				 	formatString : "#,##0",
					style : "aui-right"
				},
				{
				    headerText: "소비자금액",
				    dataField: "sale_amt",
				 	dataType : "numeric",
				 	formatString : "#,##0",
					style : "aui-right"
				},
				{
				    dataField: "sale_price",
					visible : false
				},
				{
				    dataField: "buy_price",
					visible : false
				},
				{
				    dataField: "buy_amt",
					visible : false
				},
				{
				    headerText: "비고",
				    dataField: "remark",
				    width: "20%",
					style : "aui-left"
				},
				
			];
			

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			 AUIGrid.setGridData(auiGrid, []);

		}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
<!-- 검색영역 -->					
			<div class="search-wrap">				
				<table class="table">
					<colgroup>
						<col width="50px">
						<col width="260px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>조사일</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0  calDate" id="s_start_dt" 
												name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" 
												value="${inputParam.s_current_dt}">
										</div>
									</div>
									<div class="col-auto">~</div>
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0  calDate" id="s_end_dt" 
												name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" 
												value="${inputParam.s_current_dt}">
										</div>
									</div>
								</div>							
							</td>						
							<td>
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
							</td>			
						</tr>										
					</tbody>
				</table>					
			</div>
<!-- /검색영역 -->
<!-- 그리드영역 -->
			<div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			</div>
<!-- /그리드영역 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>