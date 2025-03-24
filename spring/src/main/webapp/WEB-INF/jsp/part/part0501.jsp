<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 센터별부품관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var rowIndex;
		var tempOrg;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		
		$(document).ready(function() {
			createAUIGrid();
			fnInit();
		});
		
		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -12));
			
			// 권한에 따라 그리드 변경 (수정 중) 
			var hideList = ["cust_name", "avg_price"];
			if(${page.add.AVG_PRICE_SHOW_YN ne 'Y'}) {
				AUIGrid.hideColumnByDataField(auiGrid, hideList);
			}

			if("${page.fnc.F00541_001}" != "Y") {
				$("#s_warehouse_cd").prop("disabled", true);
			}
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_part_no", "s_part_name", "s_storage_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "_$uid",
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				// 테두리 제거
				showSelectionBorder : false,
				editable : true,
				enableFilter : true,
				enableCellMerge : true
			};
			var columnLayout = [
				{ 
					dataField : "part_storage_seq", 
					visible : false
				},
				{ 
					dataField : "warehouse_cd", 
					visible : false
				},
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "120",
					minWidth : "110",
					style : "aui-center",
					editable : false,               
					filter : {
		                  showIcon : true
		            }
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					style : "aui-left",
				    dataField: "part_name",
					width : "200",
					minWidth : "180",
					editable : false,               
					filter : {
		                  showIcon : true
		            }
				},
				{ 
					headerText : "매입처", 
					dataField : "cust_name", 
					width : "130",
					minWidth : "130",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "평균매입", 
					dataField : "avg_price", 
					width : "85",
					minWidth : "80",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false
				},
				{ 
					headerText : "판매단가", 
					dataField : "sale_price", 
					width : "85",
					minWidth : "80",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false
				},
				{ 
					headerText : "전체출고", 
					dataField : "all_out_stock", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "센터출고", 
					dataField : "center_out_stock", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "전체재고", 
					dataField : "all_qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "창고재고", 
					dataField : "center_stock", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				// 22.11.21 Q&A 15566 정비중, 이동중, 선주문, 가용재고 컬럼 추가
				{
					headerText : "정비중",
					dataField : "job_qty",
					headerStyle : "aui-fold",
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "이동중",
					dataField : "trans_qty",
					headerStyle : "aui-fold",
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "선주문",
					dataField : "preorder_qty",
					headerStyle : "aui-fold",
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "판매중",
					dataField : "sale_qty",
					headerStyle : "aui-fold",
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "가용재고",
					dataField : "use_qty",
					headerStyle : "aui-fold",
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "적정재고", 
					dataField : "safe_stock", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "과부족", 
					dataField : "under_over", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "발주수량", 
					dataField : "order_qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "54",
					minwidth : "54",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "재고조사일",
					dataField : "last_stock_dt",
					dataType : "date",
					width : "90",
					minWidth : "90",
					style : "aui-center aui-popup",
					formatString : "yyyy-mm-dd",
					editable : false,
				},
				{ 
					headerText : "저장위치", 
					dataField : "storage_name", 
					width : "180",
					minWidth : "180",
					style : "aui-center aui-popup",
					editable : false,
				},
				{
					headerText : "저장위치관리",
					width : "80",
					minWidth : "80",
					dataField : "storage_management",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							if($M.getValue("s_warehouse_cd") == "") {
								alert("센터를 먼저 선택해주세요.");
								return false;
							}
							if(tempOrg != $M.getValue("s_warehouse_cd")){
								alert("다시 조회해주세요.");
								return false;
							}
							rowIndex = event.rowIndex;
							param = {
									"part_no" : event.item["part_no"],
									"warehouse_cd" : $M.getValue("s_warehouse_cd")
							}
							var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=450, height=600, left=0, top=0";
							$M.goNextPage('/part/part0501p02', $M.toGetParam(param), {popupStatus : popupOption});
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '변경'
					},
					style : "aui-center",
					editable : false
				},
				{
					dataField : "old_storage_name",
					visible : false
				}
			]
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var frm = document.main_form;
				rowIndex = event.rowIndex;
				var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
				// 저장위치 클릭 시 저장변경이력 팝업 오픈
				if(event.dataField == 'storage_name' && event.item.storage_name != "" ) {
					if(tempOrg != $M.getValue("s_warehouse_cd")){
						alert("다시 조회해주세요.");
						return false;
					}
					var param = {
							part_no : event.item.part_no,
							warehouse_cd : event.item.warehouse_cd,
							part_name : event.item.part_name
						};
					var popupOption = "";
					$M.goNextPage('/part/part0501p03', $M.toGetParam(param), {popupStatus : popupOption});
				}
				// 22.09.13 정윤수 재고조사일 클릭 시 재고실사이력 팝업 호출
				if(event.dataField == "last_stock_dt") {

					if(event.item.last_stock_dt != "") {
						var param = {
							warehouse_cd 	: event.item.warehouse_cd,
							part_no 	: event.item.part_no

						};
						var poppupOption = "";

						$M.goNextPage("/part/part0501p04", $M.toGetParam(param), {popupStatus : poppupOption});
					}
				}

			}); 
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
			$("#auiGrid").resize();

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

		// 펼침
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
		}


		// 조회
		function goSearch() { 
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				// 22.09.13 정윤수 전체 조회 시 재고조사일 컬럼 미노출
				var hideList = ["last_stock_dt"];
				if($M.getValue("s_warehouse_cd") == "") {
					AUIGrid.hideColumnByDataField(auiGrid, hideList);
				} else {
					AUIGrid.showColumnByDataField(auiGrid, hideList);
				}
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}
	
		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			};
		}
		
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;  
				if (result.list.length > 0) {
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}
		
		//조회
		function fnSearch(successFunc) { 
			isLoading = true;
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return false;
			}; 

			 var stock_mon = '${inputParam.s_current_mon}';
				var param = {
						s_stock_mon : stock_mon,
						s_warehouse_cd : $M.getValue("s_warehouse_cd"),
						s_part_no : $M.getValue("s_part_no"),
						s_part_name : $M.getValue("s_part_name"),
						s_storage_name : $M.getValue("s_storage_name"),
						s_start_dt : $M.getValue("s_start_dt"),
						s_end_dt : $M.getValue("s_end_dt"),
						s_operator : $M.getValue("s_operator"),
						s_homi_yn  : $M.getValue("s_homi_yn"),
						s_current_qty  : $M.getValue("s_current_qty"),
						s_over_safe_stock  : $M.getValue("s_over_safe_stock"),
						s_out_history  : $M.getValue("s_out_history"),					
						s_single_check : $M.getValue("single_check"),
						s_sort_key : "part_no",
						s_sort_method : "asc",
						page : page,
						rows : $M.getValue("s_rows")
				};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get', timeout : 60 * 60 * 1000},
				function(result){
					isLoading = false;
					if(result.success) {
						successFunc(result);
						tempOrg = $M.getValue("s_warehouse_cd");
					};
				}
// 				function(result) {
// 					if(result.success) {
// 						AUIGrid.setGridData(auiGrid, result.list);
// 						$("#total_cnt").html(result.total_cnt);
// 						tempOrg = $M.getValue("s_warehouse_cd");
// 					};
// 				}
			);
		} 

		
		// 조회
// 		function goSearch() {
// 			 var stock_mon = '${inputParam.s_current_mon}';
// 				var param = {
// 						s_stock_mon : stock_mon,
// 						s_warehouse_cd : $M.getValue("s_warehouse_cd"),
// 						s_part_no : $M.getValue("s_part_no"),
// 						s_part_name : $M.getValue("s_part_name"),
// 						s_storage_name : $M.getValue("s_storage_name"),
// 						s_start_dt : $M.getValue("s_start_dt"),
// 						s_end_dt : $M.getValue("s_end_dt"),
// 						s_operator : $M.getValue("s_operator"),
// 						s_homi_yn  : $M.getValue("s_homi_yn"),
// 						s_current_qty  : $M.getValue("s_current_qty"),
// 						s_over_safe_stock  : $M.getValue("s_over_safe_stock"),
// 						s_out_history  : $M.getValue("s_out_history"),					
// 						s_single_check : $M.getValue("single_check"),
// 						s_sort_key : "part_no",
// 						s_sort_method : "asc",
// 						s_search_dt_type_cd : $M.getValue("s_search_dt_type_cd"),
// 						this_page : this_page,
// 				};
// 			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get', timeout : 60 * 60 * 1000},
// 				function(result) {
// 					if(result.success) {
// 						AUIGrid.setGridData(auiGrid, result.list);
// 						$("#total_cnt").html(result.total_cnt);
// 						tempOrg = $M.getValue("s_warehouse_cd");
// 					};
// 				}
// 			);
// 		}
		
		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			if($M.getValue("s_warehouse_cd") == "") {
				alert("센터는 필수선택입니다.");
				return false;
			}
			
			if(tempOrg != $M.getValue("s_warehouse_cd")){
				alert("조회센터가 변경되었습니다.\n다시 조회해주세요.");
				return false;
			}
			
			$M.setValue("warehouse_cd", $M.getValue("s_warehouse_cd"));
			
// 			if($M.getValue("warehouse_cd") == "") {
// 				$M.setValue("warehouse_cd", "${SecureUser.org_code}");
// 			}
// 			var rows = AUIGrid.getEditedRowItems(auiGrid);
// 	         for(var i = 0; i < rows.length; i++) {
// 	        	 alert(rows[i].warehouse_cd);
// 	        	if(rows[i].warehouse_cd == "" || rows[i].warehouse_cd == undefined) {
// 		            rowIndex = rows[i].rownum;
// 					AUIGrid.updateRow(auiGrid, { "warehouse_cd" : "${SecureUser.org_code}" }, rowIndex);
// 	        	}
// 	         }
         
			var frm = fnChangeGridDataToForm(auiGrid);
			console.log(frm);
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					};
				}
			);
		}
		
		function fnDownloadExcel() {
			  fnExportExcel(auiGrid, "센터별부품관리");
		}
		
		// 재고조사 팝업
		function goPartStockPopup() {
			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1250, height=600, left=0, top=0";
			$M.goNextPage('/part/part0501p01', '', {popupStatus : popupOption});
		}

		function fn_validCheckMulti() {
			var multiCheck = document.getElementsByClassName("multi-check");
			var checked = 0;
			$("input[type='radio'][name='single_check']").prop("checked", false);
			for(i = 0; i < multiCheck.length; i++){
				if(multiCheck[i].checked == true){
					checked += 1;
				}
			}
			if(checked == 0){
				$("#s_homi_yn").prop("checked", true);
				$("#s_current_qty").prop("checked", true);
				return;
			}

		}
		
 		function fn_validCheck(chkIdx) {
			$(".multi-check").prop("checked", false);
		}
 		
		// 저장위치관리 데이터
		function fnSetStorage(data) {
		    AUIGrid.updateRow(auiGrid, { "storage_name" : data }, rowIndex);
// 		    AUIGrid.updateRow(auiGrid, { "part_storage_seq" : data.part_storage_seq }, rowIndex);
		}

		</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- <input type="hidden" id="warehouse_cd" name="warehouse_cd"> -->
<div class="layout-box">
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
								<col width="60px">
								<col width="260px">
								<col width="40px">
								<col width="100px">
								<col width="65px">
								<col width="80px">
								<col width="70px">
								<col width="120px">
								<col width="70px">
								<col width="100px">								
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-success">중복선택 :</th>
									<td colspan="3">
										<div class="form-check form-check-inline">
											<input class="form-check-input multi-check" type="checkbox" name="s_homi_yn" id="s_homi_yn"  value="Y" checked="checked" onclick="javascript:fn_validCheckMulti();">
											<label for="s_homi_yn" class="form-check-label">HOMI 지정품</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input multi-check" type="checkbox" name="s_current_qty" id="s_current_qty" value="Y" checked="checked"  checked onclick="javascript:fn_validCheckMulti();">
											<label for="s_current_qty" class="form-check-label">현재고 0 아닌것</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input multi-check" type="checkbox" name="s_over_safe_stock" id="s_over_safe_stock" value="Y" onclick="javascript:fn_validCheckMulti();">
											<label for="s_over_safe_stock" class="form-check-label">적정 &gt; 0</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input multi-check" type="checkbox" name="s_out_history" id="s_out_history" value="Y" onclick="javascript:fn_validCheckMulti();">
											<label for="s_out_history" class="form-check-label">3년 출고내역</label>
										</div>
									</td>
									<th>연산</th>
									<td>
										<select class="form-control" name="s_operator" id="s_operator" >
											<option value="OR">OR</option>
											<option value="AND">AND</option>
										</select>
									</td>
									<th class="text-success">단독선택 :</th>
									<td colspan="4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="single_check" id="s_zero_stock"  value="Z" onclick="javascript:fn_validCheck();">
											<label for="s_zero_stock" class="form-check-label">현재 &#61; 0, 적정 &#61; 0</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="single_check" id="s_current_under_safe" value="C" onclick="javascript:fn_validCheck();">
											<label for="s_current_under_safe" class="form-check-label">현재 &lt; 적정</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="single_check" id="s_under_current" value="U"onclick="javascript:fn_validCheck();">
											<label for="s_under_current" class="form-check-label">현재 &lt; 0</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="single_check" id="s_out_mng_yn" value="O" onclick="javascript:fn_validCheck();">
											<label for="s_out_mng_yn" class="form-check-label">출하관리품</label>
										</div>
									</td>
								</tr>
								<tr>
									<th>출고일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}" alt="요청 시작일">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" alt="요청 종료일">
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
									<th>센터</th>
									<td>
										<select class="form-control" name="s_warehouse_cd" id="s_warehouse_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['WAREHOUSE']}">
												<c:if test="${item.code_value ne '4000' && item.code_value ne '5010' && item.code_value ne '5110'}"><option value="${item.code_value}" ${item.code_value == (SecureUser.warehouse_cd ne '' ? SecureUser.warehouse_cd : SecureUser.org_code) ? 'selected' : 'item.code_value' }>${item.code_name}</c:if></option>
											</c:forEach>
										</select>
									</td>
<!-- 									<td> -->
<!-- 										센터일 경우, 소속 센터만 조회가능하므로 셀렉트박스로 안함. -->
<%-- 										<c:if test="${SecureUser.org_type eq 'CENTER'}"> --%>
<%-- 											<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly"> --%>
<%-- 											<input type="hidden" value="${SecureUser.org_code}" id="s_warehouse_cd" name="s_warehouse_cd" readonly="readonly">  --%>
<%-- 										</c:if> --%>
<!-- 										본사의 경우, 전체 센터목록 선택가능 -->
<%-- 										<c:if test="${SecureUser.org_type ne 'CENTER'}"> --%>
<!-- 											<select class="form-control" name="s_warehouse_cd" id="s_warehouse_cd"> -->
<!-- 												<option value="">- 전체 -</option> -->
<%-- 												<c:forEach var="item" items="${codeMap['WAREHOUSE']}"> --%>
<%-- 													<c:if test="${item.code_value ne '4000'}"><option value="${item.code_value}" ${item.code_value == SecureUser.org_code ? 'selected' : 'item.code_value' }>${item.code_name}</c:if></option> --%>
<%-- 												</c:forEach> --%>
<!-- 											</select> -->
<%-- 										</c:if> --%>
<!-- 									</td> -->
									<th>부품번호</th>
									<td>
										<input type="text" class="form-control" id="s_part_no" name="s_part_no">
									</td>
									<th>부품명</th>
									<td>
										<input type="text" class="form-control" id="s_part_name" name="s_part_name">
									</td>
									<th>저장위치</th>
									<td>
										<input type="text" class="form-control" id="s_storage_name" name="s_storage_name">
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>	
								</tr>																
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<div class="form-check form-check-inline">
									<label for="s_toggle_column" style="color:black;">
										<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
									</label>
								</div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>	
					</div>			
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
						
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>