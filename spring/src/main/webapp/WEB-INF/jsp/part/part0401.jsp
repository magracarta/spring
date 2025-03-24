<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 부품발주요청 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
	
		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			createAUIGrid(); // 메인 그리드
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
		
		// 조회
		function goSearch() { 
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}
		
		function fnInit() {
			/* var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1)); */
			//goSearch();
		}
		
		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true,
				enableSorting : true,
				showRowCheckColumn : true,	
				showRowAllCheckBox : false,
				rowCheckableFunction : function(rowIndex, isChecked, item) {
					if(item.part_preorder_status_name != "대기" || item.dis_part_order_no != "") {	// (Q&A 12832) 발주서 등록된 요청서도 체크되지 않도록 추가 21.09.29 박예진
						alert("진행상태가 \"대기\"이면서 발주 등록하지 않은 자료만 선택 가능합니다.");
						return false;
					}
					return true;
				},
			};
			var columnLayout = [
				{
					dataField : "preorder_no",
					visible : false
				},
				{ 
					headerText : "요청센터", 
					dataField : "center_name", 
					width : "65",
					minWidth : "50"
				},
				{ 
					headerText : "요청자", 
					headerStyle : "aui-fold",
					dataField : "request_mem_name", 
					width : "65",
					minWidth : "50"
				},
				{ 
					headerText : "요청일자", 
					dataField : "reg_dt",
					dataType : "date",
					width : "65",
					minWidth : "50",
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "요청구분", 
					dataField : "part_preorder_type_name", 
					width : "65",
					minWidth : "50"
				},
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "100",
					minWidth : "90"
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					width : "150",
					minWidth : "90",
					style : "aui-left"
				},
				{ 
					headerText : "요청", 
					dataField : "request_order_qty", 
					width : "45",
					minWidth : "45",
					dataType : "numeric"
				},
				{ 
					headerText : "요청처", 
					headerStyle : "aui-fold",
					dataField : "order_cust_name", 
					width : "120",
					minWidth : "110"
				},
				{ 
					headerText : "비고", 
					dataField : "memo",
					style : "aui-left",
					width : "140",
					minWidth : "130"
				},
				{ 
					headerText : "상태", 
					dataField : "part_preorder_status_name", 
					width : "45",
					minWidth : "45"
				},
				{ 
					headerText : "발주처리일", 
					dataField : "order_proc_dt",
					dataType : "date",
					width : "75",
					minWidth : "75",
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "발주", 
					dataField : "approval_qty", 
					width : "45",
					minWidth : "45"
				},
				{ 
					headerText : "계약납기일", 
					headerStyle : "aui-fold",
					dataField : "delivary_dt",
					dataType : "date",
					width : "75",
					minWidth : "75",
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "입고예정일", 
					dataField : "in_plan_dt",
					dataType : "date",
					width : "75",
					minWidth : "75",
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "입고확정일", 
					headerStyle : "aui-fold",
					dataField : "in_fix_dt",
					dataType : "date",
					width : "75",
					minWidth : "75",
					formatString : "yy-mm-dd",
				},
				{ 
					dataField : "part_order_no",
					visible : false
				},
				{
					headerText : "발주번호", 
					dataField : "dis_part_order_no",
					width : "90",
					minWidth : "85"
				},
				{ 
					headerText : "발주자", 
					dataField : "order_mem_name", 
					width : "65",
					minWidth : "50"
				},
				{ 
					headerText : "입고여부", 
					dataField : "mi_qty", 
					width : "55",
					minWidth : "55",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				    	return value == "0" && item.part_preorder_status_name == "발주" ? "입고" : "미입고"
					}
				},
				{
					dataField : "preorder_inout_doc_no",
					visible : false
				},
				{
					dataField : "preorder_yn",
					visible : false
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			// AUIGrid.setFixedColumnCount(auiGrid, 5);
			
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
			
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
		
		function fnSearch(successFunc) {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			};
			isLoading = true;
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_order_org_code : $M.getValue("s_order_org_code"),
				s_part_preorder_type_cd : $M.getValue("s_part_preorder_type_cd"),
				s_part_preorder_status_cd : $M.getValue("s_part_preorder_status_cd"),
				s_sort_key : "order_proc_dt desc nulls last, reg_dt",
				s_sort_method : "desc",
				page : page,
				rows : $M.getValue("s_rows")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			);
		}
		
		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y"  && isLoading == false) {
				goMoreData();
			};
		}
		
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;  
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}
		
		function goRemove() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("선택된 행이 없습니다.");
				return false;
			}
			var param = {
				'preorder_no_str' : $M.getArrStr(items, {key : 'preorder_no'}),
				'preorder_inout_doc_no_str' : $M.getArrStr(items, {key : 'preorder_inout_doc_no'}),
				'preorder_yn_str' : $M.getArrStr(items, {key : 'preorder_yn'}),
				
			}
			var msg = "발주요청자료를 삭제하시겠습니까?\n이미 부품발주에 등록된 자료는 삭제되지않습니다.";
			$M.goNextPageAjaxMsg(msg, this_page + "/remove", $M.toGetParam(param), {method : "POST"},
					function(result) {
			    		if(result.success) {
			    			goSearch();
						};
					}
				);
		}
		
		function goSave() {
			var param = {
				's_part_no' : "" 
			};
			openOrderPartPanel('fnSetOrderPartResult',  $M.toGetParam(param));
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGrid, "부품발주요청내역", exportProps);
		}
		
		function fnSetOrderPartResult(row) {
			console.log(row);
			goSearch();
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
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
							<col width="65px">
							<col width="260px">
							<col width="30px">
							<col width="100px">
							<col width="75px">
							<col width="70px">
							<col width="80px">
							<col width="70px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="rs">요청일자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group date-wrap">
												<input type="text" class="form-control border-right-0 calDate rb" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="요청 시작일" required="required" value="${searchDtMap.s_start_dt }">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group date-wrap">
												<input type="text" class="form-control border-right-0 calDate rb" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" alt="요청 종료일" required="required" value="${searchDtMap.s_end_dt }">
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
									<!-- 센터일 경우, 소속 센터만 조회가능하므로 셀렉트박스로 안함. -->
									<c:if test="${page.fnc.F00315_001 ne 'Y'}">
										<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
										<input type="hidden" value="${SecureUser.org_code}" id="s_order_org_code" name="s_order_org_code" readonly="readonly"> 
									</c:if>
									<!-- 본사의 경우, 전체 센터목록 선택가능 -->
									<c:if test="${page.fnc.F00315_001 eq 'Y'}">
										<input type="text" style="width : 200px";
											value="${SecureUser.org_code}"
											id="s_order_org_code" 
											name="s_order_org_code" 
											idfield="code_value"
											easyui="combogrid"
											header="Y"
											easyuiname="centerList" 
											panelwidth="200"
											maxheight="155"
											enter="goSearch()"
											textfield="code_name"
											multi="N"/>
									</c:if>
								</td>
								<th>요청구분</th>
								<td>
									<select class="form-control" id="s_part_preorder_type_cd" name="s_part_preorder_type_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['PART_PREORDER_TYPE']}">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>상태구분</th>
								<td>
									<select class="form-control" id="s_part_preorder_status_cd" name="s_part_preorder_status_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['PART_PREORDER_STATUS']}">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
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
							<label for="s_toggle_column" style="color:black;">
								<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
							</label>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
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