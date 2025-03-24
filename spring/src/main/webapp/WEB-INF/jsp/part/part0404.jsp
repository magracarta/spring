<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 미입고부품현황 > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();	
			fnInit();
		});
		
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
			
 		    // 구해진 칼럼 사이즈를 적용 시킴.
			//var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
		    //AUIGrid.setColumnSizeList(auiGrid, colSizeList);
		}
		
		function fnInit() {
			/* var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
			$M.setValue("s_end_dt", $M.toDate(now)); */			
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : true,
				showStateColumn : true,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "발주번호",
				    dataField: "part_order_no",
					style : "aui-center",
					width : "110",
					minWidth : "85",
					editable : false
				},
				{
					headerText : "발주처",
					dataField : "cust_name",
					style : "aui-center",
					width : "120",
					minWidth : "85",
					editable : false
				},
				{
				    headerText: "부품번호",
				    dataField: "part_no",
				    width : "120",
					minWidth : "85",
					style : "aui-center",
					editable : false
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
				    width : "150",
					minWidth : "85",
					style : "aui-center",
					editable : false
				},
				{
					headerText: "할당센터",
					headerStyle : "aui-fold",
					dataField: "warehouse_nm",
					width : "100",
					minWidth : "85",
					style : "aui-center",
					editable : false
				},
				{
				    headerText: "발주수량",
				    dataField: "order_qty",
					style : "aui-center",
					width : "55",
					minWidth : "50",
					editable : false
				},
				{
				    headerText: "입고수량",
				    headerStyle : "aui-fold",
				    dataField: "in_qty",
					style : "aui-center",
					width : "55",
					minWidth : "50",
					editable : false
				},
				{
				    headerText: "최종입고일",
				    headerStyle : "aui-fold",
				    dataField: "last_in_dt",
					style : "aui-center",
					dataType : "date",
					width : "75",
					minWidth : "50",
					formatString : "yy-mm-dd",
					editable : false
				},
				{
				    headerText: "미입고량",
				    dataField: "mi_qty",
					style : "aui-center",
					width : "55",
					minWidth : "50",
					editable : false
				},
				{
				    headerText: "발주처리일",
				    dataField: "order_proc_dt",
					style : "aui-center",
					dataType : "date",
					width : "75",
					minWidth : "50",
					formatString : "yy-mm-dd",
					editable : false
				},
				{
				    headerText: "계약납기일",
				    headerStyle : "aui-fold",
				    dataField: "delivary_dt",
					style : "aui-center",
					dataType : "date",
					width : "75",
					minWidth : "50",
					formatString : "yy-mm-dd",
					editable : false
				},
				{
				    headerText: "입고예정일",
				    dataField: "in_plan_dt",
				    dataType : "date",
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "50",
					style : "aui-center aui-editable",
					editable : false
				},
				{
				    headerText: "입고확정일",
				    headerStyle : "aui-fold",
				    dataField: "in_fix_dt",
				    dataType : "date",
				    width : "75",
					minWidth : "50",
					formatString : "yy-mm-dd",
					style : "aui-center aui-editable",
					editable : false
				},
				{
				    headerText: "현재고",
				    dataField: "current_qty",
					style : "aui-center",
					width : "55",
					minWidth : "50",
					editable : false
				},
				{
				    headerText: "상태",
				    dataField: "status",
					style : "aui-center",
					width : "65",
					minWidth : "50",
					editable : false
				},
				{
					dataField: "end_yn",
					visible : false
				},
				{
					dataField: "seq_no",
					visible : false
				}
			];
			
			
			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			
			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}

		}
		
		
	
		function goPlanDtSave() {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0){
				alert("선택된 행이 없습니다.");
				return;
			}
			
			for(var i = 0 ; i < rows.length ; i++) {
				if(rows[i].in_plan_dt == "" && $M.getValue("set_dt") == "") {
					alert("입고예정일을 지정을 하시기 바랍니다.");
					return;
				}
			}
			
			if($M.getValue("set_dt") == ""){
				alert("입고예정일을 지정 하시기 바랍니다.");
				return;
			}
			
			var param = {
				"part_order_no" : $M.getArrStr(rows, {key : "part_order_no", isEmpty : true})
				, "seq_no" : $M.getArrStr(rows, {key : "seq_no", isEmpty : true})
				, "set_dt" : $M.getValue("set_dt")
				, "flag" : "plan"
			}
			
			$M.goNextPageAjaxMsg("입고예정일을 지정하시겠습니까?",this_page + "/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					}
				}
			);
		}
		
		function goFixDtSave() {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0){
				alert("선택된 행이 없습니다.");
				return;
			}
			if($M.getValue("set_dt") == ""){
				alert("입고확정일을 지정 하시기 바랍니다.");
				return;
			}
			
			var param = {
				"part_order_no" : $M.getArrStr(rows, {key : "part_order_no", isEmpty : true})
				, "seq_no" : $M.getArrStr(rows, {key : "seq_no", isEmpty : true})
				, "set_dt" : $M.getValue("set_dt")
				, "flag" : "fix"
			}
			
			$M.goNextPageAjaxMsg("입고확정일을 지정하시겠습니까?",this_page + "/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					}
				}
			);
		}
		
		function goPartOrderDetail() {
		
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0){
				alert("선택된 행이 없습니다.");
				return;
			}
			
			if(rows.length > 1){
				alert("발주서 조회는 한개만 선택이 되어야 합니다.");
				return;
			}

			
			var param = {
					part_order_no : rows[0].part_order_no
			};
			var poppupOption = "";
			$M.goNextPage('/part/part0403p01', $M.toGetParam(param), {popupStatus : poppupOption});
			
		}
		
		function goDone() {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0){
				alert("선택된 행이 없습니다.");
				return;
			}
			
			
			for (var i = 0; i < rows.length; i++) {
				if (rows[i].end_yn == "Y" ) {
					alert("이미 마감처리된 정보가 있습니다.");
					return;
				}
			}
			
			var param = {
				"part_order_no" : $M.getArrStr(rows, {key : "part_order_no", isEmpty : true})
				, "seq_no" : $M.getArrStr(rows, {key : "seq_no", isEmpty : true})
				, "flag" : "done"
			}
			
			$M.goNextPageAjaxMsg("체크 항목을 마감처리 하시겠습니까?",this_page + "/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					}
				}
			);
		}
		
		// 21.07.23 (SR:11373) 마감취소기능추가 - 황빛찬
		function goCancelDone() {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0){
				alert("선택된 행이 없습니다.");
				return;
			}
			
			for (var i = 0; i < rows.length; i++) {
				if (rows[i].end_yn == "N" ) {
					alert("미마감처리된 정보가 있습니다.");
					return;
				}
			}
			
			var param = {
				"part_order_no" : $M.getArrStr(rows, {key : "part_order_no", isEmpty : true})
				, "seq_no" : $M.getArrStr(rows, {key : "seq_no", isEmpty : true})
				, "flag" : "cancelDone"
			}
			
			$M.goNextPageAjaxMsg("체크 항목을 마감취소 하시겠습니까?",this_page + "/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					}
				}
			);
		}
		
		function fnDownloadExcel() {
			// 엑셀 내보내기 속성
		 	var exportProps = {
				//제외항목
			};
			fnExportExcel(auiGrid, "미입고 부품현황", exportProps);
	    }
		
		
		
		function goSearch() {
			if($M.getValue("s_start_dt") != "" && $M.getValue("s_end_dt") != ""){
				if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
					return;
				}
			}
			var param = {
					s_start_dt : $M.getValue("s_start_dt")
					, s_end_dt : $M.getValue("s_end_dt")
					, s_status : $M.getValue("s_status")
					, s_cust_no : $M.getValue("s_cust_no")
					, s_part_production_cd : $M.getValue("s_part_production_cd")
			}
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			); 
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- /left -->
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
<!-- 검색영역 -->					
					<div class="search-wrap">				
						<table class="table">
							<colgroup>
								<col width="75px">
								<col width="270px">
								<col width="40px">
								<col width="150px">
								<col width="80px">
								<col width="80px">
								<col width="80px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>발주처리일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0  calDate" id="s_start_dt" 
														name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" 
														value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0  calDate" id="s_end_dt" 
														name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" 
														value="${searchDtMap.s_end_dt}">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
					                     		<jsp:param name="st_field_name" value="s_start_dt"/>
					                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
					                     		<jsp:param name="click_exec_yn" value="Y"/>
					                     		<jsp:param name="exec_func_name" value="goSearch();"/>
					                     	</jsp:include>	
										</div>
									</td>
									<th>발주처</th>
									<td>
										<div class="input-group">
											<input type="text" style="width : 220px";
												id="s_cust_no" 
												name="s_cust_no" 
												idfield="cust_no"
												easyui="combogrid"
												header="Y"
												easyuiname="combogrid" 
												panelwidth="370"
												maxheight="200"
												textfield="cust_name"
												multi="N"/>
										</div>
									</td>
									<th>상태구분</th>
									<td>
										<select id="s_status" name="s_status" class="form-control">
											<option value="">- 전체 -</option>
											<option value="Y">마감</option>
											<option value="N">미마감</option>
										</select>
									</td>
									<th>생산구분</th>
									<td>
										<select id="s_part_production_cd" name="s_part_production_cd" class="form-control">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['PART_PRODUCTION']}" var="item">
												<option value="${item.code_value}">${item.code_name }</option>
											</c:forEach>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch();" >조회</button>
									</td>			
								</tr>										
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						
						<div class="title-wrap mt10">
							<div class="right dpf">
								<div class="input-group mr5" style="width: 100px;">
									<input type="text" class="form-control border-right-0  calDate" id="set_dt" name="set_dt" dateformat="yyyy-MM-dd" alt="" value="${inputParam.s_current_dt}">
								</div>
							</div>
							<div class="btn-group">
								
								<div class="right">
									<label for="s_toggle_column" style="color:black;">
										<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
									</label>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
					</div>
				</div>	
									
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>