<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 선 주문 미 출하현황 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2021-07-20 18:01:33
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "선 주문 미 출하현황", "");
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

		// 목록 조회
		function fnSearch(successFunc) { 
			if ($M.validation(document.main_form) == false) {
				return;
			};
			
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
				return;
			}; 
			
			var param = {
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt"),
					"s_inout_doc_no" : $M.getValue("s_inout_doc_no"),
					"s_item_id" : $M.getValue("s_item_id"),
					"s_item_name" : $M.getValue("s_item_name"),
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_inout_org_code" : $M.getValue("s_inout_org_code"),
					"s_end_yn" : $M.getValue("s_end_yn"),
					"s_delivery_yin" : $M.getValue("s_delivery_yin"),
					"page" : page,
					"rows" : $M.getValue("s_rows")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			);
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				// 체크박스 표시 설정	(21.08.03 기획 마감기능 제외하므로 체크박스 제거)
// 				showRowCheckColumn : true,
				// 전체 선택 체크박스가 독립적인 역할을 할지 여부
// 				independentAllCheckBox : true,
				//전체선택 체크박스 표시 여부
// 				showRowAllCheckBox : false,
				rowCheckVisibleFunction : function(rowIndex, isChecked, item) {
					if(item.part_trans_req_no != "") { 
						return true;
					}
					return false;
				}
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "전표일자",
				    dataField: "inout_dt",
					style : "aui-center",
				    dataType : "date",   
					width : "70",
					minWidth : "70",
					formatString : "yy-mm-dd"
				},
				{
				    headerText: "전표번호",
				    dataField: "inout_doc_no",
					style : "aui-center",
					width : "85",
					minWidth : "85",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo == "" ? "" : docNo.substring(4, 16);
					}
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "130",
					minWidth : "130",
					style : "aui-center",
				},
				{ 
					headerText : "품명", 
					dataField : "count_name", 
					width : "300",
					minWidth : "300",
					style : "aui-left aui-popup",
// 			     	styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
// 			     		if(item["acct_yn"] == "완료") {
// 							return "aui-left aui-popup";
// 						}
// 			     		return "aui-left";
// 					},
				},
				{
				    headerText: "비고",
				    dataField: "remark",
					width : "120",
					minWidth : "120",
					style : "aui-left"
				},
				{ 
					headerText : "금액", 
					dataField : "doc_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "85",
					minWidth : "85",
					style : "aui-right",
					xlsxTextConversion : true,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var amt = value;
						return amt == "0" ? "" : $M.setComma(amt);
					}
				},
				{ 
					headerText : "부가세포함", 
					dataField : "total_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "85",
					minWidth : "85",
					style : "aui-right",
					xlsxTextConversion : true,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var amt = value;
						return amt == "0" ? "" : $M.setComma(amt);
					}
				},
				{ 
					headerText : "입금여부", 
					dataField : "acct_yn",
					width : "55",
					minWidth : "55",
					style : "aui-center",
                    renderer : {
			            type : "TemplateRenderer",
			     	},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						if(value == "완료"){
							return value;
						} else {
							var template = '<div class="aui-grid-renderer-base" style="white-space: nowrap; display: inline-block; width: 100%; max-height: 24px;">';
							template += '<span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:goInoutDetail(\'' + item["inout_doc_no"] + '\')">미입금</span></div>'
							
							return template;
						}
					}
				},
				{ 
					headerText : "입금일", 
					dataField : "acct_dt", 
					dataType : "date",  
					formatString : "yy-mm-dd",
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "작성자",
				    dataField: "mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{
				    headerText: "처리센터",
				    dataField: "inout_org_name",
					width : "75",
					minWidth : "75",
					style : "aui-center"
				},
				{
				    headerText: "전표마감여부",
				    dataField: "end_yn",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var endYn = value;
						if(endYn == "Y") {
							endYn = "마감";
						} else {
							endYn = "미마감";
						}
				    	return endYn;
					},
					width : "80",
					minWidth : "80",
					style : "aui-center"
				},
				{
				    headerText: "배송상태",
				    dataField: "preorder_status",
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{
				    dataField: "part_trans_status_cd",
				    visible : false,
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(event.dataField == "count_name") {
 					if(event.item["acct_yn"] == "완료") {
						var popupOption = "";
						var param = {
								"inout_doc_no" : event.item["inout_doc_no"]
							};
						var popupOption = "";
						$M.goNextPage('/part/part0204p01', $M.toGetParam(param), {popupStatus : popupOption});
 					} else {
 						alert("입금완료 후 처리 가능합니다.");
 					}
				}
			});
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_inout_doc_no", "s_item_id", "s_item_name", "s_cust_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 미입금 시 매출상세 연결
		function goInoutDetail(inoutDocNo) {
			var popupOption = "";
			var param = {
					"inout_doc_no" : inoutDocNo
				};
			var popupOption = "";
			$M.goNextPage('/cust/cust0202p01', $M.toGetParam(param), {popupStatus : popupOption});
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
									<col width="85px">
									<col width="260px">
									<col width="60px">
									<col width="90px">
									<col width="60px">
									<col width="100px">
									<col width="60px">
									<col width="100px">
									<col width="60px">
									<col width="100px">
									<col width="60px">
									<col width="90px">
									<col width="90px">
									<col width="90px">
									<col width="60px">
									<col width="90px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th>발행일자</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col-5">
													<div class="input-group">
														<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="${searchDtMap.s_start_dt}">
													</div>
												</div>
												<div class="col-auto text-center">~</div>
												<div class="col-5">
													<div class="input-group">
														<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${searchDtMap.s_end_dt}">
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
										<th>전표번호</th>
										<td>
											<input type="text" class="form-control" id="s_inout_doc_no" name="s_inout_doc_no">
										</td>
										<th>부품번호</th>
										<td>
											<input type="text" class="form-control" id="s_item_id" name="s_item_id">
										</td>
										<th>부품명</th>
										<td>
											<input type="text" class="form-control" id="s_item_name" name="s_item_name">
										</td>
										<th>고객명</th>
										<td>
											<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
										</td>
										<th>센터</th>
										<td>
										<!-- 본사가 아닐 경우 소속 부서만 조회가능하므로 셀렉트박스로 안함. -->
										<c:if test="${page.fnc.F03100_001 ne 'Y'}">
											<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
											<input type="hidden" value="${SecureUser.org_code}" id="s_inout_org_code" name="s_inout_org_code" readonly="readonly"> 
										</c:if>
										<!-- 본사일 경우, 전체 센터목록 선택가능 -->
										<c:if test="${page.fnc.F03100_001 eq 'Y'}">
											<select class="form-control" id="s_inout_org_code" name="s_inout_org_code">
												<option value="">- 전체 -</option>
												<c:forEach var="item" items="${codeMap['WAREHOUSE']}">
													<c:if test="${item.code_value ne '4000' && item.code_value ne '5010' && item.code_value ne '4124'}"><option value="${item.code_value}">${item.code_name}</c:if></option>
												</c:forEach>
											</select>
										</c:if>
										</td>
										<th>전표마감여부</th>
										<td>
											<select class="form-control" id="s_end_yn" name="s_end_yn">
												<option value="" selected="selected">- 전체 -</option>
												<option value="Y">마감</option>
												<option value="N">미마감</option>
											</select>
										</td>
										<th>배송상태</th>
										<td>
											<select class="form-control" id="s_delivery_yin" name="s_delivery_yin">
											<option value="">- 전체 -</option>
											<option value="Y">배송완료</option>
											<option value="I">부분배송</option>
											<option value="N">미배송</option>
											</select>
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
							<h4>이동요청내역</h4>
							<div class="btn-group">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
								</div>
							</div>
						</div>
						<!-- /그리드 타이틀, 컨트롤 영역 -->					
						<div style="margin-top: 5px; height: 555px;" id="auiGrid"></div>
						<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="left">				
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
							</div>
							<div class="right">
<%-- 								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include> --%>
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