<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 부품연관팝업 > 부품연관팝업 > null > 부품요청
-- 작성자 : 강명지
-- 최초 작성일 : 
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		var checkGridData;
		var confirmYn = "${inputParam.confirm_yn}";
		
		$(document).ready(function() {
			createAUIGrid();
			fnInit();
		});
		
		function goEnd() {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0) {
				alert("체크된 항목이 없습니다.");
				return false;
			};
			var preorderNoStr = [];
			var preorderCnt = 0;
			for (var i = 0; i < rows.length; ++i) {
				if (rows[i].part_preorder_status_cd == "0") {
					preorderNoStr.push(rows[i].preorder_no);
				}
				if(rows[i].part_preorder_type_cd == "4") {
					preorderCnt++;
				}
			};
			if(preorderCnt > 0) {
				alert("선주문은 임의마감할 수 없습니다.");
				return false;
			}
			
			if (preorderNoStr.length == 0) {
				alert("체크된 미결 자료가 없습니다.");
				return false;
			}
			var param = {
				preorder_no_str : $M.getArrStr(preorderNoStr)
			}
			
			$M.goNextPageAjaxMsg("마감처리하시겠습니까?", this_page + "/end", $M.toGetParam(param), {method : 'post'},
					function(result) {
						if(result.success) {
							goSearch();
						};
					}
				);
		}
	
		//조회
		function goSearch() { 
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			}; 
			var custNo = "${inputParam.s_cust_no}";
			var param = {
				s_cust_no : custNo,
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_order_org_code_str : $M.getValue("s_order_org_code_str"),
				s_part_preorder_type_cd : $M.getValue("s_part_preorder_type_cd"),
				s_part_preorder_status_cd : $M.getValue("s_part_preorder_status_cd"),
				s_sort_key : "order_proc_dt desc nulls last, reg_dt",
				s_sort_method : "desc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.list.length);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		} 
		
		function fnInit() {
			goSearch();
		}
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "preorder_no",
				wrapSelectionMove : false,
				showRowCheckColumn : true,
				showRowAllCheckBox : true,
				showRowNumColumn: true,
				enableFilter :true,
				editable : false,
				independentAllCheckBox: true, // 필터됐을 때 전체체크 방지
				rowStyleFunction : function(rowIndex, item) {
					if (item.order_yn != "0") {
						return "aui-status-complete";
					}
				}
			};
			var columnLayout = [
				{
					dataField : "cust_no",
					visible : false
				},
				{
					dataField : "preorder_no",
					visible : false
				},
				{
					dataField : "preorder_inout_doc_no",
					visible : false
				},
				{
					dataField : "part_preorder_status_cd",
					visible : false
				},
				{
					dataField : "part_preorder_type_cd",
					visible : false
				},
				{ 
					headerText : "요청센터", 
					dataField : "order_org_name", 
					width : "80", 
					minWidth : "80", 
				},
				{ 
					headerText : "요청자", 
					dataField : "request_mem_name", 
					width : "60", 
					minWidth : "60", 
				},
				{ 
					headerText : "요청일자", 
					dataField : "reg_dt",
					dataType : "date",
					width : "65", 
					minWidth : "65", 
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "요청구분", 
					dataField : "part_preorder_type_name", 
					width : "55", 
					minWidth : "55", 
				},
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "120", 
					minWidth : "120", 
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					style : "aui-left",
					width : "150", 
					minWidth : "150", 
				},
				{
					headerText : "매입처1",
					dataField : "client_name",
					filter : {
						showIcon : true
					},
					width : "120", 
					minWidth : "120", 
				},
				{
					headerText : "매입처2",
					dataField : "client_name2",
					filter : {
						showIcon : true
					},
					width : "120", 
					minWidth : "120", 
				},
				{
					dataField : "current_stock",
					headerText : "현재고",
					width : "60", 
					minWidth : "60", 
				},
				
				{ 
					headerText : "요청", 
					dataField : "request_order_qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "60", 
					minWidth : "60", 
				},
				{ 
					headerText : "요청처", 
					dataField : "order_cust_name", 
					width : "130", 
					minWidth : "130", 
				},
				{ 
					headerText : "비고", 
					dataField : "memo",
					style : "aui-left",
					width : "130", 
					minWidth : "130", 
				},
				{ 
					headerText : "상태", 
					dataField : "part_preorder_status_name", 
					width : "55", 
					minWidth : "55", 
				},
				/* { 
					headerText : "발주처리일", 
					dataField : "order_proc_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{ 
					headerText : "발주", 
					dataField : "order_qty", 
					width : "5%", 
				}, */
				/* { 
					headerText : "계약납기일", 
					dataField : "delivary_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				}, */
				/* { 
					headerText : "입고예정일", 
					dataField : "in_plan_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{ 
					headerText : "입고확정일", 
					dataField : "in_fix_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				}, */
				/* { 
					headerText : "발주번호", 
					dataField : "part_order_no", 
					width : "10%", 
				},
				{ 
					headerText : "발주자", 
					dataField : "order_mem_no", 
					width : "6%", 
				}, */
				/* { 
					headerText : "입고여부", 
					dataField : "last_in_dt", 
					width : "6%", 
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				    	return (item['last_in_dt']=='' || item['last_in_dt']==null) ?'미입고':'입고'
					}
				}, */
				{
					headerText : "최종입고일",
					dataField : "last_in_dt", 
					visible : false,
				},
				{
					dataField : "part_mng_cd",
					headerText : "관리구분코드",
					visible : false
				},
				{
					dataField : "part_mng_name",
					headerText : "관리구분명",
					visible : false
				},
				{
					dataField : "money_unit_cd",
					headerText : "화폐단위코드",
					visible : false
				},
				{
					dataField : "unit_price",
					headerText : "단가",
					visible : false
				},
				{
					dataField : "unit_price2",
					headerText : "단가2",
					visible : false
				},
				{
					dataField : "mi_qty",
					visible : false
				},
				{
					dataField : "be0_out_total_qty",
					visible : false
				},
				{
					dataField : "be1_out_total_qty",
					visible : false
				},
				{
					dataField : "be2_out_total_qty",
					visible : false
				},
				{
					dataField : "delivary_cnt",
					visible : false
				},
				{
					dataField : "part_name_change_yn",
					visible : false
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 22.11.21 필터적용 후 전체선택 시 필터적용된 값만 체크되도록 수정
			AUIGrid.bind(auiGrid, "rowAllChkClick", function( event ) {
				if(event.checked) {
					var uniqueValues = AUIGrid.getColumnDistinctValues(event.pid, "client_name");
					AUIGrid.setCheckedRowsByValue(event.pid, "client_name", uniqueValues);
				} else {
					AUIGrid.setCheckedRowsByValue(event.pid, "client_name", []);
				}
			});
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "rowCheckClick", function( event ) {
				//AUIGrid.addCheckedRowsByValue(auiGrid, "part_no", event.item.part_no);
			});
		}
		
		//적용
		function goApply() {
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			var dealCust2Check = $("input:radio[id='deal_cust2']").is(":checked"); // 매입처2 체크여부
			if (itemArr.length == 0) {
				alert("선택된 부품발주요청 건이 없습니다.");
				return false;
			}
			// 23.02.28 정윤수 부품발주 부품추가 시 정상재고 아닌 경우 확인창 띄움
			for (var i = 0; i < itemArr.length; i++) {
				if(itemArr[i].part_mng_cd != "1" && confirmYn == 'Y'){
					if(confirm("정상재고가 아닌 부품이 선택되었습니다. ("+itemArr[i].part_no+")\n계속 진행 하시겠습니까?") == false){
						return;
					}
					confirmYn = "N";
				}
				// 23.06.16 정윤수 매입처1, 2 단가 선택하여 적용하도록 추가
				if(dealCust2Check){ // 단가적용이 매입처2인 경우 매입처2의 단가로 적용
					itemArr[i].unit_price = itemArr[i].unit_price2;
				}
			}
			fnClose();
			opener.${inputParam.parent_js_name}(itemArr);
		}
		
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
       <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
<!-- /타이틀영역 -->
    <div class="content-wrap">	  
    <input type="hidden" id="s_cust_no" name="s_cust_no" value="${inputParam.s_cust_no}">
    <%-- <input type="hidden" id="s_part_preorder_status_cd" name="s_part_preorder_status_cd" value="${inputParam.s_part_preorder_status_cd}"> --%>
<!-- 검색조건 -->
		<div class="search-wrap">				
					<table class="table">
						<colgroup>
							<col width="65px">
							<col width="260px">
							<col width="30px">
							<col width="100px">
							<col width="75px">
							<col width="100px">
							<col width="80px">
							<col width="100px">
							<col width="120px">
							<col width="70px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>요청일자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.s_start_dt}" alt="요청 시작일">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_end_dt}" alt="요청 종료일">
											</div>
										</div>
									</div>
								</td>
								<th>센터</th>
								<td>
									<!-- 센터일 경우, 소속 센터만 조회가능하므로 셀렉트박스로 안함. -->
									<c:if test="${page.fnc.F00401_001 ne 'Y'}">
										<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
										<input type="hidden" value="${SecureUser.org_code}" id="s_order_org_code_str" name="s_order_org_code_str" readonly="readonly"> 
									</c:if>
									<!-- 본사의 경우, 전체 센터목록 선택가능 -->
									<c:if test="${page.fnc.F00401_001 eq 'Y'}">
										<input type="text" style="width : 220px";
											id="s_order_org_code_str" 
											name="s_order_org_code_str" 
											idfield="org_code"
											easyui="combogrid"
											header="Y"
											easyuiname="centerList" 
											panelwidth="250"
											maxheight="155"
											enter="goSearch()"
											textfield="org_name"
											enter="goSearch"
											multi="Y"/>
									</c:if>
								</td>
								<th>요청구분</th>
								<td>
									<select class="form-control" id="s_part_preorder_type_cd" name="s_part_preorder_type_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['PART_PREORDER_TYPE']}">
											<option value="${item.code_value}"<c:if test="${inputParam.s_part_preorder_type_cd eq item.code_value }"> selected="selected"</c:if>>${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>상태구분</th>
								<td>
									<select class="form-control" id="s_part_preorder_status_cd" name="s_part_preorder_status_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['PART_PREORDER_STATUS']}">
											<option value="${item.code_value}"<c:if test="${inputParam.s_part_preorder_status_cd eq item.code_value }"> selected="selected"</c:if>>${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
									<button type="button" class="btn btn-warning" onclick="javascript:goEnd()">임의마감</button>
								</td>
								<th class="text-right">단가적용</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="deal_cust1" name="deal_cust" value="1" checked="checked">
										<label class="form-check-label" for="deal_cust1">매입처1</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="deal_cust2" name="deal_cust" value="2">
										<label class="form-check-label" for="deal_cust2">매입처2</label>
									</div>
								</td>
							</tr>										
						</tbody>
					</table>					
				</div>
<!-- /검색영역 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>부품발주요청내역</h4>
					<div class="btn-group">
						<div class="right">
							
						</div>
					</div>
				</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

				<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

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