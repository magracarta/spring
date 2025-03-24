<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 센터별부품관리 > null > 재고조사
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var rowIndex;
	
		$(document).ready(function() {
			createAUIGrid();
		
			if ('${inputParam.s_stock_yn}' == 'A' ){
				$M.setValue("s_stock_yn","");				
			}

			if ('${inputParam.s_part_no}' != '' && '${inputParam.s_warehouse_cd}' != '' ){
				
				goSearch();
			}
			
		});
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "rownum",
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				// 테두리 제거
				showSelectionBorder : false,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				editable : true,
				rowStyleFunction : function(rowIndex, item) {
					// 당일조사 완료 bg컬러 그레이
					if(item.day_comp_yn == "Y") {
						return "aui-background-darkgray";
					}
					return "";
				}
			};
			var columnLayout = [
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "12%", 
					style : "aui-center",
					editable : false
				},			
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					width : "16%", 
					style : "aui-left",
					editable : false
				},
				{ 
					headerText : "부품창고", 
					dataField : "warehouse_cd", 
					visible : false
				},				
				
				{ 
					headerText : "저장위치", 
					dataField : "storage_name", 
					width : "9%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "전체재고", 
					dataField : "all_qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "4%", 
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "창고재고", 
					dataField : "center_stock", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "4%", 
					style : "aui-center",
					editable : false
				},
					// 22.11.21 Q&A 15566 정비중, 이동중, 선주문, 가용재고 컬럼 추가
				{
					headerText : "정비중",
					dataField : "job_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "4%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "이동중",
					dataField : "trans_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "4%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "선주문",
					dataField : "preorder_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "4%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "판매중",
					dataField : "sale_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "4%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "가용재고",
					dataField : "use_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "4%",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "적정재고", 
					dataField : "safe_stock",
					dataType : "numeric",
					formatString : "#,##0",
					width : "4%", 
					style : "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? "0" : value;
					},
				},
				{ 
					headerText : "재고실사수량", 
					dataField : "check_stock", 
					width : "7%", 
					style : "aui-center aui-editable",
					dataType : "numeric",
					formatString : "#,##0",
					editable : true,
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true,
					    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
					    allowPoint : false, // 소수점(.) 입력 가능 설정
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (item["day_comp_yn"] != "Y") {
							return "aui-part-col-style";
						}
						return false;
					}
				},
				{ 
					headerText : "재고차이수량", 
					dataField : "diff_cnt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "7%", 
					style : "aui-center",
					editable : false,
// 					expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
// 						// 합계 계산
// 						return item.check_stock - item.center_stock; 
// 					}
				},
				{ 
					headerText : "재고조사일", 
					dataField : "stock_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd", 
					width : "8%", 
					style : "aui-center aui-popup",
					editable : false
				},
				{ 
					headerText : "비고", 
					dataField : "remark", 
					style : "aui-left  aui-editable",
					editable : true,
					editRenderer : {
					      type : "InputEditRenderer",
					      // 에디팅 유효성 검사
					     validator : function(oldValue, newValue, item) {
							var isValid = false;
							// 리턴값은 Object 이며 validate 의 값이 true 라면 패스, false 라면 message 를 띄움
							if(newValue != '' || item.diff_cnt == 0) {
								isValid = true;
							}
							return { "validate" : isValid, "message"  : "현 재고와 실 재고가 맞지 않습니다. \n비고란에 사유를 입력하시기 바랍니다." };
						}
					}
				},
				{
					dataField : "report_sort",
					visible : false
				},
			]

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function( event ) {
				AUIGrid.bind(auiGrid, "cellClick", cellClickHandler);
			});
// 			AUIGrid.bind(auiGrid, "cellEditBegin", function( event ) {
// 				if(event.dataField == 'check_stock'){
// 					AUIGrid.updateRow(auiGrid, { "stock_dt" : "${inputParam.s_current_dt}" }, event.rowIndex);		//재고조사일을 오늘날짜로 세팅
// 				}
// 			});
// 			AUIGrid.bind(auiGrid, "cellEditEnd", function( event ) {
// 				if(event.dataField == 'check_stock'){
// 					var checkStock = event.value;
// 					var centerStock = event.item['center_stock'];
// 					AUIGrid.updateRow(auiGrid, { "diff_cnt" : checkStock-centerStock }, event.rowIndex);
// 					if (event.value == "") {
// 						AUIGrid.updateRow(auiGrid, { "check_stock" : 0 }, event.rowIndex);	
						
// 					}
// 				}
// 			});
			AUIGrid.bind(auiGrid, "cellEditEndBefore", function( event ) {
				if(event.dataField == 'check_stock'){
					var checkStock = event.value;
					var centerStock = event.item['center_stock'];
					AUIGrid.updateRow(auiGrid, { "diff_cnt" : checkStock-centerStock }, event.rowIndex);
					if (event.value == "") {
						AUIGrid.updateRow(auiGrid, { "check_stock" : 0 }, event.rowIndex);	
						
					}
					AUIGrid.updateRow(auiGrid, { "stock_dt" : "${inputParam.s_current_dt}" }, event.rowIndex);		//재고조사일을 오늘날짜로 세팅
				}
				if(event.dataField == 'remark'){
					AUIGrid.updateRow(auiGrid, { "stock_dt" : "${inputParam.s_current_dt}" }, event.rowIndex);		//재고조사일을 오늘날짜로 세팅
				}
			});
			$("#auiGrid").resize();
		}
		
		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			
			if(event.dataField == "stock_dt") {		
				
				if(event.item.stock_dt != "") {					
					var param = {
	 						warehouse_cd 	: event.item.warehouse_cd,
	 						part_no 	: event.item.part_no
	 	
	 					};
					var poppupOption = "";
					
					$M.goNextPage("/part/part0501p04", $M.toGetParam(param), {popupStatus : poppupOption});		
				}					
			}			
		};
	
		
		
		function goSearch() {
			 var stock_mon = '${inputParam.s_current_mon}';
				var param = {
						"s_stock_mon" : stock_mon,
						"s_warehouse_cd" : $M.getValue("s_warehouse_cd"),
						"s_part_no" : $M.getValue("s_part_no"),
						"s_part_name" : $M.getValue("s_part_name"),
						"s_storage_name" : $M.getValue("s_storage_name"),
						"s_storage_yn" : $M.getValue("s_storage_yn"),
						"s_stock_yn" : $M.getValue("s_stock_yn"),
						"s_day_stock_qty" : $M.getValue("s_day_stock_qty"),
						"s_day_yn" : $M.getValue("s_day_yn"),
// 						s_sort_key : "part_storage_seq",
// 						s_sort_method : "desc"
				};
				$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
						function(result) {
							if(result.success) {
								AUIGrid.setGridData(auiGrid, result.list);
								$("#total_cnt").html(result.total_cnt);
								AUIGrid.setAllCheckedRows(auiGrid, true);
							};
						}
					);
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

		
		/*
			// 그리드 빈값 체크
	 		function fnCheckGridEmpty() {
	 			return AUIGrid.validateGridData(auiGrid, ["check_stock"], "재고실사수량 값을 입력해주세요.");
	 		}
	
	 		// 재고차이수량 체크
	 		function fnCheckQtyGridEmpty() {
	 			return AUIGrid.validateGridData(auiGrid, ["diff_cnt"], "창고재고와 실사재고수량이 맞지 않으면 \n비고에 사유를 입력하셔야 합니다.");
	 		}
			
	 		// 재고조사일 체크 (오늘날짜로 입력됬는지) 		
				function fnCheckStockDtGrid() {
	 			return AUIGrid.showToastMessage(auiGrid, rowIndex, 9, "재고조사일은 당일이어야합니다.");
	 		}
		*/
		
		// 저장
		function goSave() {
			var row = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(row.length == 0) {
				alert("선택된 재고대상이 없습니다.");
				return false;
			}
			for(var i = 0; i < row.length; i++) {
				rowIndex = row[i].rownum-1;
				var checkStock = row[i].check_stock;
				var centerStock = row[i].center_stock;
				AUIGrid.updateRow(auiGrid, { "diff_cnt" : checkStock-centerStock }, rowIndex);
			}
			
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			for(var i = 0; i < rows.length; i++) {
				rowIndex = rows[i].rownum;
				if(rows[i].check_stock == undefined) {
					return AUIGrid.showToastMessage(auiGrid, rowIndex, 7, "재고실사수량 값을 입력해주세요.");
				}

				
				if(rows[i].diff_cnt != 0 && rows[i].remark == '') {
					return AUIGrid.showToastMessage(auiGrid, rowIndex, 8, "창고재고와 실사재고수량이 맞지 않으면 \n비고에 사유를 입력하셔야 합니다.");
				}
				
				//체크된 내역의 재고조사일이 오늘이 아닌경우 실사재고수량을 새로 입력하도록 처리
				if(rows[i].stock_dt != "${inputParam.s_current_dt}") {
					// 재고조사일 체크 (오늘날짜로 입력됬는지)
					return AUIGrid.showToastMessage(auiGrid, rowIndex, 9, "재고조사일은 당일이어야합니다.");
				}
				
				
			}
			
			var partNoArr = [];
			var warehouseCdArr = [];
			var stockDtArr = [];
			var currentStockArr = [];
			var checkStockArr = [];
			var diffCntArr = [];
			var remarkArr = [];
			for (var i = 0; i < rows.length; ++i) {
				partNoArr.push(rows[i].part_no);
				warehouseCdArr.push($M.getValue("s_warehouse_cd"));
				stockDtArr.push(rows[i].stock_dt);
				currentStockArr.push(rows[i].center_stock);
				checkStockArr.push(rows[i].check_stock);
				diffCntArr.push(rows[i].diff_cnt);
				remarkArr.push(rows[i].remark);
			}
			var option = {
					isEmpty : true
			};
 			var param = {
 					part_no_str : $M.getArrStr(partNoArr, option),
 					warehouse_cd_str : $M.getArrStr(warehouseCdArr, option),
 					stock_dt_str : $M.getArrStr(stockDtArr, option),
 					current_stock_str : $M.getArrStr(currentStockArr, option),
 					check_stock_str : $M.getArrStr(checkStockArr, option),
 					diff_cnt_str : $M.getArrStr(diffCntArr, option),
 					remark_str : $M.getArrStr(remarkArr, option)
			}
			$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			// AUIGrid.clearGridData(auiGrid);
						goSearch();
		    			if (opener != null && opener.goSearch) {
		    				opener.goSearch();	
		    			}
		    			
					}
				}
			);
		}
		
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "센터재고실사");
		}
		
		function goPrint() {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (rows.length == 0) {
				alert("체크된 행이 없습니다.");
				return false
			}
			
			// (Q&A 12814) 강성하님 요청으로 재고조사 리스트와 출력물 정렬 순서 동일하게 수정 21.09.29 박예진
			rows.sort(function(a, b) { 
				var o1 = a['report_sort'];
				var o2 = b['report_sort'];
				
				if(a.report_sort == ""){
			      return 1;
			    } else if(b.report_sort == ""){
			      return -1;
			    } else if (a.report_sort > b.report_sort) {
					return 1;
				} else if (a.report_sort < b.report_sort) {
					return -1;
				}
				
			});
			
// 			rows.sort(function(a, b) { // 오름차순
// 				  var o1 = a['storage_name']
// 				  var o2 = b['storage_name']
// 				  var p1 = a['part_no']
// 				  var p2 = b['part_no']
// 				  if (o1 == "") {
// 					  return 1;
// 				  }
// 				  if (o2 == "") {
// 					  return -1;
// 				  }
// // 				  if (o1 != "" && o2 != "" && o1 < o2) {
// // 					  return -1;
// // 				  }
// // 				  if (o1 != "" && o2 != "" && o1 > o2) {
// // 					  return 1;
// // 				  }
// // 				  if ((o1 == "" || o2 == "") && p1 < p2) {
// // 					  return -1;
// // 				  }
// // 				  if ((o1 == "" || o2 == "") && p1 > p2) {
// // 					  return 1;
// // 				  }
				  
// 				  if (o1 < o2) return -1;
// 				  if (o1 > o2) return 1;
// 				  if (p1 < p2) return -1;
// 				  if (p1 > p2) return 1;
// 				  return 0;
				  
// // 				if(a.storage_name == ""){
// // 			      return 1;
// // 			    } else if(b.storage_name == ""){
// // 			      return -1;
// // 			    } else if (a.storage_name > b.storage_name) {
// // 					return 1;
// // 				} else if (a.storage_name < b.storage_name) {
// // 					return -1;
// // 				}
			
// // 				if(a.part_no > b.part_no) {
// // 					return -1;
// // 				} 
// // 				if (a.part_no < b.part_no) {
// // 					return 1;
// // 				}
// // 			    return a.storage_name < b.storage_name ? -1 : a.storage_name > b.storage_name ? 1 : 0;
// 			});
			
// 			rows.sort(function(a, b) { // 오름차순
				
// 				var o1 = a['storage_name']
// 				var o2 = b['storage_name']
// 				var p1 = a['part_no']
// 				var p2 = b['part_no']

// 				if(o1 == "" && o2 == "") {
// 					  if (p1 < p2) return -1;
// 					  if (p1 > p2) return 1;
// 				}
// 			});
			
			var org_name = "";
			var org_type = "${page.fnc.F00542_001}";
			if (org_type == "Y") {
				org_name = $M.getValue("s_warehouse_name");
			} else {
				org_name = $("#s_warehouse_cd option:checked").text();	
			}
			var data = {
				"kor_name" : "${SecureUser.kor_name}"
				, "org_name" : org_name
			}
			var param = {
				"data" : data
				, "part_list" : rows 
			}
			openReportPanel('part/part0501p01_01.crf', param);	
		}
		
		// 닫기
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
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4 class="primary">센터재고실사</h4>	
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>						
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="50px">
							<col width="80px">
							<col width="60px">
							<col width="100px">
							<col width="60px">
							<col width="100px">
							<col width="50px">
							<col width="100px">
							<col width="60px">
							<col width="130px">
							<col width="60px">
							<col width="90px">
							<col width="125px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>사업부</th>
								<td>
									<!-- 센터일 경우, 소속 센터만 조회가능하므로 셀렉트박스로 안함. -->
									<c:if test="${page.fnc.F00542_001 eq 'Y'}">
										<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly" id="s_warehouse_name" name="s_warehouse_name">
										<input type="hidden" value="${SecureUser.org_code}" id="s_warehouse_cd" name="s_warehouse_cd" readonly="readonly"> 
									</c:if>
									<!-- 본사의 경우, 전체 센터목록 선택가능 -->
									<c:if test="${page.fnc.F00542_001 ne 'Y'}">
										<select class="form-control" name="s_warehouse_cd" id="s_warehouse_cd">
											<c:forEach var="item" items="${codeMap['WAREHOUSE']}">
												<c:if test="${item.code_value ne '4000' && item.code_value ne '5010' && item.code_value ne '5110'}"><option value="${item.code_value}" ${  item.code_value == ( inputParam.s_warehouse_cd != '' ? inputParam.s_warehouse_cd : SecureUser.org_code )  ? 'selected' : '' }>${item.code_name}</c:if></option>
											</c:forEach>
										</select>
									</c:if>
								</td>
								<th>저장위치</th>
								<td>
									<input type="text" class="form-control width120px" id="s_storage_name" name="s_storage_name">
								</td>
								<th>부품번호</th>
								<td>
									<input type="text" class="form-control width120px"  id="s_part_no" name="s_part_no" value="${inputParam.s_part_no}" >
								</td>
								<th>부품명</th>
								<td>
									<input type="text" class="form-control width120px" id="s_part_name" name="s_part_name">
								</td>
								<th>창고재고</th>
								<td>
									<select class="form-control" id="s_stock_yn" name="s_stock_yn">
										<option value="">- 전체 -</option>
										<option value="Y" selected>재고 有(HOMI포함)</option>
										<option value="N">재고 無</option>
									</select>
								</td>
								<th>위치설정</th>
								<td>
									<select class="form-control" id="s_storage_yn" name="s_storage_yn">
										<option value="">- 전체 -</option>
										<option value="Y">저장위치 有</option>
										<option value="N">저장위치 無</option>
									</select>
								</td>
								<td>
									<div class="form-check form-check-inline ml15">
										<input class="form-check-input" type="checkbox" id="s_day_yn" name="s_day_yn" value="Y">
										<label class="form-check-label mr5" for="s_day_yn">당일조사반영</label>
									</div>
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
<!-- 재고조사 대상부품목록 -->
				<div class="title-wrap mt10">
					<h4>재고조사 대상부품목록</h4>
					<div class="btn-group">
						<div class="right dpf">
							<span class="mr5">일일 재고조사수량설정</span>
							<select class="form-control mr5 v-align-middle" style="width: 70px" id="s_day_stock_qty" name="s_day_stock_qty">
								<option value="ALL">- 전체 -</option>
								<option value="5">5개</option>
								<option value="10">10개</option>
								<option value="20">20개</option>
								<option value="30" selected="selected">30개</option>
								<option value="50">50개</option>
								<option value="100">100개</option>
								<option value="200">200개</option>
							</select>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</div>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>
<!-- /재고조사 대상부품목록 -->
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